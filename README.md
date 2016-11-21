
Monitor critcal system/application state changes and verbally notify user using windows SpeechSynthesizer

Requirements: 
Windows 7 Desktop
Powershell Enabled
Run-as Admin or Local System

Notes:
VirMemTest can be used to induce hangs, crashes and high CPU states for testing
https://blogs.msdn.microsoft.com/aaron_margosis/2013/06/14/virtmemtest-a-utility-to-exercise-memory-and-other-operations/

Update History:
-------------------------------

	1.2.0
	--------
	Add support for appliction crash notification (issue #4)
	Add support for mapping of process names to friendly names (issue #3)

	1.1.0
	--------
	Add support for multiple NT Event Log subscriptions (Hang Begin/End)

	1.0.0
	--------
	Initial Version
