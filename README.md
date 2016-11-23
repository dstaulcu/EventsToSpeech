
Synopsis:
-------------------------------

Provides audible notification for application crash or hang state changes.

Requirements:
-------------------------------

	Windows 7 operating system
	Powershell execution enabled
	Execution as standard user

Update History:
-------------------------------

	1.4.0
	--------
	Add support for hung window detection using isHungAppWindow API (requires exectuion as user)

	1.3.0
	--------
	Improve organization of script to simplify addition new features

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

Notes:
-------------------------------

	Use VirMemTest[64].exe to induce hangs/crashes for testing of notifications. 
	https://blogs.msdn.microsoft.com/aaron_margosis/2013/06/14/virtmemtest-a-utility-to-exercise-memory-and-other-operations/
	
