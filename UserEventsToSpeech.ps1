<#
.Synopsis
   Monitor user state changes and verbally notify user using windows SpeechSynthesizer 
   version 1.6.0
   # [issue x] - Consolidate onto Get-WinEvent cmdlet to check for eventlog state changes. [done]
   # [issue y] - Add print of speak action statements to stdout. [done]
   # [issue z] - Correct timing issue where events can be missed due to wait times associated with speak commands [done]
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

# create SpeechSynth object
Add-Type -AssemblyName System.speech
$SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer

if ([Environment]::UserInteractive -eq $False ) {
    $SpeechSynth.Speak('The user event notification service must run as interactive user. Exiting.')
    $SpeechSynth.Dispose()
    Exit
}
else
{
    # notify users of application startup
    $SpeechSynth.Speak('The user event notification service has started.')
}


# Add methods here
Register-NativeMethod "user32.dll" "bool IsHungAppWindow(IntPtr hWnd)"

# This builds the class and registers them (you can only do this one-per-session, as the type cannot be unloaded?)
Add-NativeMethods

# initialize hung processes collection
$spokenevents = [System.Collections.ArrayList]@()

do{

    sleep  1

    $datetime = get-date -Format "yyyy-MM-dd @ hh:mm:ss"            

    # pInvoke user32.dll isHungAppWindow API
    $processes = Get-Process | Where-Object {($_.MainWindowHandle -ne 0) -and ($_.Name -ne 'dwm')}
    foreach ($process in $processes) {
        $status = [NativeMethods]::IsHungAppWindow($process.MainWindowHandle)
        
        if ($status -eq $true) {

            Write-Host ('[' + $datetime + ']' + ' - PRINT - ' + 'Process ' + $process.name + ' with id ' + $process.Id + ' is not responding.')
            
            if ($spokenevents.Contains($process.Name + ':' + $process.Id) -eq $false) {
                $spokenevents.Add($process.Name + ':' + $process.Id) | Out-Null
                $hungprocess = Get-ProcessFriendlyName($process.Name)
                $message = $hungprocess + ' entered an unresponsive state.'
                write-host ('[' + $datetime + ']' + ' - SPEAK - ' +  $message)
                $SpeechSynth.Speak($message)

            }
        }
        else {
            if ($spokenevents.Contains($process.Name + ':' + $process.Id) -eq $true) {
                $spokenevents.Remove($process.Name + ':' + $process.Id)
                $hungprocess = Get-ProcessFriendlyName($process.Name)
                $message = $hungprocess + ' returned to a responsive state.'
                write-host ('[' + $datetime + ']' + ' - SPEAK - ' + $message)
                $SpeechSynth.Speak($message)

            }
        } 
    }


    # Handle crash events 
    $events = Get-WinEvent -FilterHashtable @{Logname="Application";ProviderName="Application Error";Id=1000;StartTime=(Get-Date).AddSeconds(-30)} -ErrorAction SilentlyContinue

    foreach ($event in $events) {

        if ($spokenevents.Contains($event.LogName + ':' + $event.RecordID) -eq $false) {
            $spokenevents.Add($event.LogName + ':' + $event.RecordID) | Out-Null

            if ($event.Id -eq 1000) {
                $process = ([regex]"(\w+).exe,").match($event.Message).Groups[1].Value
                $process_id = ([regex]"Faulting process id: (\S+)").match($event.Message).Groups[1].Value
                $process_id = [int]$process_id

                $process_friendly = Get-ProcessFriendlyName($process)
                $message = $process_friendly + ' crashed and must be restarted.'

                # notify user
                Write-Host ('[' + $datetime + ']' + ' - PRINT - ' + 'Process ' + $process + ' with id ' + [string]$process_id + ' crashed.')
                write-host ('[' + $datetime + ']' + ' - SPEAK - ' + $message)
                $SpeechSynth.Speak($message)
            }

        }
    }

    # Handle networkprofile (disconnect/connect) events.
    $events = Get-WinEvent -FilterHashtable @{Logname="Microsoft-Windows-NetworkProfile/Operational";ProviderName="Microsoft-Windows-NetworkProfile";Id=10000,10001;StartTime=(Get-Date).AddSeconds(-30)} -ErrorAction SilentlyContinue

    foreach ($event in $events) {

        if ($spokenevents.Contains($event.LogName + ':' + $event.RecordID) -eq $false) {
            $spokenevents.Add($event.LogName + ':' + $event.RecordID) | Out-Null

            $connection_name = ([regex]"Name:\s+(\S+)\r\n").match($event.Message).Groups[1].Value
            if ($event.Id -eq 10001) {
                write-host ('[' + $datetime + ']' + ' - PRINT - ' + 'Network interface ' + $connection_name + ' disconnected.')
                $message = 'Network interface disconnected.'
                write-host ('[' + $datetime + ']' + ' - SPEAK - ' + $message)
                $SpeechSynth.Speak($message)
            }
            if ($event.Id -eq 10000) {
                if ($event.message -like "*Identifying*") {
                    write-host ('[' + $datetime + ']' + ' - PRINT - ' + 'Network interface in profile identification state.')
                } else {
                    write-host ('[' + $datetime + ']' + ' - PRINT - ' + 'Network interface ' + $connection_name + ' connected.')
                    $message = 'Network interface connected.'
                    write-host ('[' + $datetime + ']' + ' - SPEAK - ' + $message)
                    $SpeechSynth.Speak($message)
                }

            }
        }
    }

}
while ($True)

# Dispose of event subscriptions
Get-EventSubscriber  | Where-Object -Property SourceIdentifier -Like 'AssistiveUser_*' | Unregister-Event

# Dispose of speech object
$SpeechSynth.Dispose()
