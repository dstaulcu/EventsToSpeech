<#
.Synopsis
   Monitor critcal system/application state changes and verbally notify user using windows SpeechSynthesizer 
#>


function Get-ProcessFriendlyName ($ProcessName)
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

# Hang detector log event subscription
$WQL_NTLogEvent_Hang = @"
SELECT * 
FROM __InstanceCreationEvent 
WITHIN 5 
WHERE TargetInstance isa 'Win32_NTLogEvent' 
    AND TargetInstance.Logfile = 'Application' 
    AND TargetInstance.SourceName = 'EventCreate' 
    AND (TargetInstance.EventCode = '50' OR TargetInstance.EventCode = '51')
"@
Register-WmiEvent -SourceIdentifier 'Assistive_NTLogEvent_Hang' -Query $WQL_NTLogEvent_Hang


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


# Logon/Logoff log event subscription
$WQL_NTLogEvent_Logon = @"
SELECT * 
FROM __InstanceCreationEvent 
WITHIN 5 
WHERE TargetInstance isa 'Win32_NTLogEvent' 
    AND TargetInstance.Logfile = 'Security' 
    AND TargetInstance.SourceName = 'Microsoft Windows security auditing.' 
    AND (TargetInstance.EventCode = '4634' OR TargetInstance.EventCode= '4647' OR TargetInstance.EventCode= '4624' OR TargetInstance.EventCode= '4625')
"@
#Register-WmiEvent -SourceIdentifier 'Assistive_NTLogEvent_Logon' -Query $WQL_NTLogEvent_Logon


do{
    sleep  1

    # enumerate any new events which have occured since last check
    $Events = Get-Event | Where-Object -Property SourceIdentifier -Like 'Assistive_*'

    foreach ($event in $events) {

        $blnHandledEvent = $False

        # Handle hange related events
        if ($event.SourceIdentifier -eq 'Assistive_NTLogEvent_Hang') {

            # if a hang start event
            if ($event.SourceArgs.newevent.TargetInstance.EventCode -eq '50') {
                $blnHandledEvent = $True
                $process = ([regex]"(\w+).exe,").match($event.SourceArgs.newevent.targetinstance.message).Groups[1].Value
                $process = Get-ProcessFriendlyName($process)
                $message = $process + ' entered an unresponsive state.'
            }
 
            # if a hang end event
            if ($event.SourceArgs.newevent.TargetInstance.EventCode -eq '51') {
                $blnHandledEvent = $True
                $process = ([regex]"(\w+).exe,").match($event.SourceArgs.newevent.targetinstance.message).Groups[1].Value
                $process = Get-ProcessFriendlyName($process)
                $message = $process + ' returned to a responsive state.'
            }
        }

        # Handle Crash related events
        if ($event.SourceIdentifier -eq 'Assistive_NTLogEvent_Crash') {

            # if a crash event
            if ($event.SourceArgs.newevent.TargetInstance.EventCode -eq '1000') {
                $blnHandledEvent = $True
                $process = ([regex]"(\w+).exe,").match($event.SourceArgs.newevent.targetinstance.message).Groups[1].Value
                $process = Get-ProcessFriendlyName($process)
                $message = $process + ' crashed and must be restarted.'
            }

        }

        # Handle Logon related events
        <#
        if ($event.SourceIdentifier -eq 'Assistive_NTLogEvent_Logon') {

            # if account logoff event
            if ($event.SourceArgs.newevent.TargetInstance.EventCode -eq '4634') {
                $blnHandledEvent = $True
                $message = 'some account was logged off.'
            }

            # if user initiated logoff event
            if ($event.SourceArgs.newevent.TargetInstance.EventCode -eq '4647') {
                $blnHandledEvent = $True
                $message = 'some user initiated logoff.'
            }

            # if account success logon
            if ($event.SourceArgs.newevent.TargetInstance.EventCode -eq '4624') {
                $blnHandledEvent = $True
                $message = 'account success logon.'
            }

            # if account failed logon
            if ($event.SourceArgs.newevent.TargetInstance.EventCode -eq '4625') {
                $blnHandledEvent = $True
                $message = 'account failed logon.'
            }

        }
        #>

        # Remove notification event now that necessary information has been extracted
        $event | Remove-Event

        # Print and speak the system information to user
        if ($blnHandledEvent = $True) {
            write-host $message
            $SpeechSynth.Speak($message)
        }

        if ($blnHandledEvent = $False) {
            Write-Host 'Unhandled Event:'
            Write-Host 'SourceIdentifier = ' + $event.SourceIdentifier
        }
          
    }  
}
while ($True)

# Dispose of event subscriptions
Get-EventSubscriber  | Where-Object -Property SourceIdentifier -Like 'Assistive_*' | Unregister-Event

# Dispose of speech object
$SpeechSynth.Dispose()