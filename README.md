
Synopsis:
-------------------------------
Powershell script providing audible notifications of application crash or hang incidents.

Usage:  powershell.exe -file .\SystemEventToSpeech.ps1

Requirements:
-------------------------------

	Windows 7 (or higher) operating system
	Powershell execution enabled
	Execution as standard user

Notes:
-------------------------------
The "Hang this UI" and "Crash This App On Exit" features of [VirMemTest](https://blogs.msdn.microsoft.com/aaron_margosis/2013/06/14/virtmemtest-a-utility-to-exercise-memory-and-other-operations/) can be used to create conditions which induce SystemEventToSpeech project notifications.  I reccomend configuring VirMemTest to hang it's UI for around 15 seconds in order to best understand latencies involved in unresponsive window detection and notification.

Update History:
-------------------------------

	1.4.0
	--------
	Add support for hung window detection using isHungAppWindow API (requires exectuion as user)

	1.3.0
	--------
	Improve organization of script to simplify addition of new features

	1.2.0
	--------
	Add support for appliction crash notification (issue #4)
	Add support for mapping of process names to friendly names (issue #3)

	1.1.0
	--------
	Add support for multiple NT Event Log subscriptions

	1.0.0
	--------
	Initial Version
