
Name: SystemEventsToSpeech.ps1
Description: Monitor critcal system/application state changes and verbally notify user using windows SpeechSynthesizer
Version/Date: 1.0.1 11/19/2016
Requirements: Windows 7 Desktop, Powershell Enabled, Run-as Admin or Local System

Original Author: David Staulcup 
Current maintainers: David Staulcup 
Contributors:	https://github.com/akahn16

Note:  VirMemTest can be used to induce hangs, crashes and high CPU states for testing
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
