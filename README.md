
Synopsis:
-------------------------------
Audible notifications of critical system events, including the following:

	unresponsive applications
	application crashes
	failed logons

Requirements:
-------------------------------

	Windows 7 operating system
	Powershell execution enabled
	Execute with local system or admin creds

Update History:
-------------------------------

	1.2.1
	--------
	Modularization of code simplify addition of new features

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

Testing Notes:
-------------------------------

	VirMemTest can be used to induce hangs, crashes and high CPU states for testing
	https://blogs.msdn.microsoft.com/aaron_margosis/2013/06/14/virtmemtest-a-utility-to-exercise-memory-and-other-operations/
