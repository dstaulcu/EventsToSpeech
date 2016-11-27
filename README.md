
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

	1.5.0
	--------
	Renamed project and powershell scripts as necessary to allow for user and system components
	
	Previous
	--------
	Add support for hung window detection using isHungAppWindow API. (requires exectuion as user)
	Improve organization of script to simplify addition of new features
	Add support for appliction crash notification (issue #4)
	Add support for mapping of process names to friendly names (issue #3)
	Add support for multiple NT Event Log subscriptions
