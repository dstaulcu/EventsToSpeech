<#
.Synopsis
   Monitor critcal system/application state changes and verbally notify user using windows SpeechSynthesizer 
#>

# Helper functions for building the class
$script:nativeMethods = @();
function Register-NativeMethod([string]$dll, [string]$methodSignature)
{
    $script:nativeMethods += [PSCustomObject]@{ Dll = $dll; Signature = $methodSignature; }
}
function Add-NativeMethods()
{
    $nativeMethodsCode = $script:nativeMethods | % { "
        [DllImport(`"$($_.Dll)`")]
        public static extern $($_.Signature);
    " }

    Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        public static class NativeMethods {
            $nativeMethodsCode
        }
"@
}
# Add methods here
Register-NativeMethod "user32.dll" "bool IsHungAppWindow(IntPtr hWnd)"

# This builds the class and registers them (you can only do this one-per-session, as the type cannot be unloaded?)
Add-NativeMethods

function Get-ProcessFriendlyName($ProcessName)
{
    switch -Wildcard ($ProcessName)
    {
        notepad*     {$ProcessName="Note Pad"}
        winword*     {$ProcessName="Microsoft Word"}
        powerpnt*    {$ProcessName="Microsoft Power Point"}
        excel*       {$ProcessName="Microsoft Excel"}
        notes*       {$ProcessName="Lotus Notes"}
        VirtMemTest* {$ProcessName="Testing Application"}
        EventCreate* {$ProcessName="Testing Application"}
    }
    return $ProcessName
}

# cleanup any subscriptions hanging around from previous sessions.
Get-EventSubscriber  | Where-Object -Property SourceIdentifier -Like 'Assistive_*' | Unregister-Event
Get-Event | Where-Object -Property SourceIdentifier -Like 'Assistive_*' | Remove-Event

# create SpeechSynth object
Add-Type -AssemblyName System.speech
$SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer

# notify users of application startup
$SpeechSynth.Speak('The system event notification service has started.')

# Application Error log event subscription
$WQL_NTLogEvent_Crash = @"
SELECT * 
FROM __InstanceCreationEvent 
WITHIN 5 
WHERE TargetInstance isa 'Win32_NTLogEvent' 
    AND TargetInstance.Logfile = 'Application' 
    AND TargetInstance.SourceName = 'Application Error' 
    AND TargetInstance.EventCode = '1000'
"@
Register-WmiEvent -SourceIdentifier 'Assistive_NTLogEvent_Crash' -Query $WQL_NTLogEvent_Crash


do{

    sleep  1

    # pInvoke user32.dll isHungAppWindow API
    $processes = Get-Process | Where-Object {($_.MainWindowHandle -ne 0) -and ($_.Name -ne 'dwm')}
    foreach ($process in $processes) {
        $status = [NativeMethods]::IsHungAppWindow($process.MainWindowHandle)
        if ($status -eq $true) {            
            if ($hungprocesses.Contains($process.Name + ':' + $process.Id) -eq $false) {
                $hungprocesses.Add($process.Name + ':' + $process.Id) | Out-Null
                $hungprocess = Get-ProcessFriendlyName($process.Name)
                $message = $hungprocess + ' entered an unresponsive state.'
                write-host $message
                $SpeechSynth.Speak($message)

            }
        }
        else {
            if ($hungprocesses.Contains($process.Name + ':' + $process.Id) -eq $true) {
                $hungprocesses.Remove($process.Name + ':' + $process.Id)
                $hungprocess = Get-ProcessFriendlyName($process.Name)
                $message = $hungprocess + ' returned to a responsive state.'
                write-host $message
                $SpeechSynth.Speak($message)

            }
        }        
    }

    # enumerate any new events arriving from event subscriptions
    $Events = Get-Event | Where-Object -Property SourceIdentifier -Like 'Assistive_*'

    foreach ($event in $events) {

        # Handle Crash related events
        if ($event.SourceIdentifier -eq 'Assistive_NTLogEvent_Crash') {
            # if a crash event
            if ($event.SourceArgs.newevent.TargetInstance.EventCode -eq '1000') {
                
                $process = ([regex]"(\w+).exe,").match($event.SourceArgs.newevent.targetinstance.message).Groups[1].Value
                $process = Get-ProcessFriendlyName($process)
                $message = $process + ' crashed and must be restarted.'

                # Remove notification event now that necessary information has been extracted
                $event | Remove-Event

                # notify user
                write-host $message
                $SpeechSynth.Speak($message)

            }
        }          
    }  
}
while ($True)

# Dispose of event subscriptions
Get-EventSubscriber  | Where-Object -Property SourceIdentifier -Like 'Assistive_*' | Unregister-Event

# Dispose of speech object
$SpeechSynth.Dispose()