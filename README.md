
Synopsis:
-----------------------------------
Powershell script providing audible notifications of application crash or hang incidents.

UserEventToSpeech Usage:  
powershell.exe -file .\UserEventToSpeech.ps1			(must run as interactive user)


SystemEventToSpeech Usage:  
powershell.exe -file .\SystemEventToSpeech.ps1			(must run as system or admin)


Requirements:
-----------------------------------

	Windows 7 (or higher) operating system
	Powershell execution enabled

Notes:
-----------------------------------
The "Hang this UI" and "Crash This App On Exit" features of [VirMemTest](https://blogs.msdn.microsoft.com/aaron_margosis/2013/06/14/virtmemtest-a-utility-to-exercise-memory-and-other-operations/) can be used to create conditions which induce SystemEventToSpeech project notifications.  I reccomend configuring VirMemTest to hang it's UI for around 15 seconds in order to best understand latencies involved in unresponsive window detection and notification.

SystemEventToSpeech Update History:
-----------------------------------

	1.0.0
	--------
	Initial version (forked from UserEventsToSpeach v1.4.0)
	

UserEventToSpeech Update History:
-----------------------------------

	1.6.0
	Consolidated on single event log monitoring strategy [Issue 13](https://github.com/dstaulcu/EventsToSpeech/issues/13)
	Reduced timing risk that even log records would be missed which speech is invoked between polling intervals. [Issue 14](https://github.com/dstaulcu/EventsToSpeech/issues/14)
	Added incident details to stdout [Issue 15](https://github.com/dstaulcu/EventsToSpeech/issues/15)


	1.5.2
	--------
	Added notification when network is connected or reconnected
	
	Previous
	--------
	Added timestamps to console output
	Added process id of crashed process to console output
	Renamed project and powershell scripts as necessary to allow for user and system components
	Add support for hung window detection using isHungAppWindow API. (requires exectuion as user)
	Improve organization of script to simplify addition of new features
	Add support for appliction crash notification (issue #4)
	Add support for mapping of process names to friendly names (issue #3)
	Add support for multiple NT Event Log subscriptions
