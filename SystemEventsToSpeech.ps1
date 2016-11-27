<#
.Synopsis
   Monitor critcal system state changes and verbally notify user using windows SpeechSynthesizer 
   version 1.0.0
#>


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

# notify users of application startup
$SpeechSynth.Speak('The system event notification service has started.')

# cleanup any subscriptions hanging around from previous sessions.
Get-EventSubscriber  | Where-Object -Property SourceIdentifier -Like 'AssistiveSystem_*' | Unregister-Event
Get-Event | Where-Object -Property SourceIdentifier -Like 'AssistiveSystem_*' | Remove-Event

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
Register-WmiEvent -SourceIdentifier 'AssistiveSystem_NTLogEvent_Crash' -Query $WQL_NTLogEvent_Crash


do{

    sleep  1

    # enumerate any new events arriving from event subscriptions
    $Events = Get-Event | Where-Object -Property SourceIdentifier -Like 'AssistiveSystem_*'

    foreach ($event in $events) {

        # Handle Crash related events
        if ($event.SourceIdentifier -eq 'AssistiveSystem_NTLogEvent_Crash') {
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
Get-EventSubscriber  | Where-Object -Property SourceIdentifier -Like 'AssistiveSystem_*' | Unregister-Event

# Dispose of speech object
$SpeechSynth.Dispose()
