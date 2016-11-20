Monitor critical system or application state changes and verbally notify blind users with windows speech synthesizer.

Contributors:
David Staulcup, [Your Name Here!]

Implementation:
-target platforms are windows 7 and windows 10 desktop
-develop/deploy as PowerShell script to enable customization by local administrators
-script to be invoked by scheduled task at user logon and to run as local system
-script to close itself at user logoff

Notification types:
-when assistive technology applications (screen readers, etc.) close or crash
-when any user mode application enters or exits a Not Responding state (aka UI delay, aka IsHungAppWindow ) 
-during periods of excessive CPU utilization, disk queing, network retransmits, etc.
