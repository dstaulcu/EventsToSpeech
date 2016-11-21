
Synopsis:
-------------------------------
Provides audible notification of critical system events, including:

	unresponsive applications
	application errors
	failed logons

Requirements:
-------------------------------

	Windows 7 operating system
	Powershell execution enabled
	Script execution with local system or admin credentials

Update History:
-------------------------------

	1.3.0
	--------
	Improve organization of script to simplify addition of planned features

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

	CreateTestHangEvents.cmd included to create logs written by hangdetecter.exe (not public).
	VirMemTest64.exe (published by Aaron Margosis) included to induce crashes and high CPU states for testing.
