<#
.Synopsis
   Monitor IsHungAppWindow state changes and verbally notify user of situation using Microsoft SpeechSynthesizer 
   https://msdn.microsoft.com/en-us/library/windows/desktop/ms633526(v=vs.85).aspx
.DESCRIPTION
   This is a test harness.  You can trigger test messages using the EventCreate command line tool

   # to simulate the beginning of a hang event for notepad.exe:
   eventcreate.exe /T Information /ID 50 /L Application /D ""ProcessName":"notepad","

   # to simulate the end of a hang event for notepad.exe:
   eventcreate.exe /T Information /ID 51 /L Application /D ""ProcessName":"notepad","
#>

$sourceid = 'Assistive_Hangs'
$classname  = 'win32_ntlogevent'
$eventlog_logfile = 'Application'
$eventlog_sourcename = 'EventCreate'
$eventlog_eventcode_hang_begin = '50'
$eventlog_eventcode_hang_end = '51'

$query = "SELECT * FROM __instancecreationevent WITHIN 5"
$query += " WHERE targetinstance isa '" + $classname + "'"
$query += " AND TargetInstance.Logfile = '" + $eventlog_logfile + "'"
$query += " AND TargetInstance.SourceName = '" + $eventlog_sourcename + "'"
$query += " AND (TargetInstance.EventCode = '" + $eventlog_eventcode_hang_begin + "'"
$query += " OR TargetInstance.EventCode = '" + $eventlog_eventcode_hang_end + "')"


# create handle to speech engine
Add-Type -AssemblyName System.speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer

#optional method to alter voice gender to female (Windows 10 Only)
$speak.SelectVoice('Microsoft Zira Desktop')

# Register for event subscription
Register-WmiEvent -SourceIdentifier $sourceid -Query $query

# Loop for some time looking for new events
$number = 20
$i = 1

do{
    write-host "loop $i of $number"
    sleep  1
    $i++ 

    # List events occurring between loop and associated with our subscription
    $Events = Get-Event | Where-Object -Property SourceIdentifier -EQ $sourceid 
    foreach ($event in $events) {

        
        $hung_process = ([regex]"ProcessName:(\w+),").match($event.SourceArgs.newevent.targetinstance.message).Groups[1].Value
        $event_code = $event.SourceArgs.newevent.TargetInstance.EventCode

        # if a hang start event
        if ($event_code -eq $eventlog_eventcode_hang_begin) {
            $message = 'The ' + $hung_process + ' process has entered an unresponsive state.'
        }

        # if a hang end event
        if ($event_code -eq $eventlog_eventcode_hang_end) {
            $message = 'The ' + $hung_process + ' process has returned to a responsive state.'
        }

        # Remove the events now needed information has been extracted
        $event | Remove-Event

        write-host $message
        $speak.Speak($message)
    }  
}
while ($i -le $number)

# Remove event subscriptions
Get-EventSubscriber  | Where-Object -Property SourceIdentifier -EQ $sourceid | Unregister-Event

# Remove handle to speech object
$speak.Dispose() 

