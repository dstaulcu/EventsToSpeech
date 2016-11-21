@echo off

REM remapped example
eventcreate.exe /T Information /ID 50 /L Application /D ""ProcessName":"VirtMemTest64.exe"," 
eventcreate.exe /T Information /ID 51 /L Application /D ""ProcessName":"VirtMemTest64.exe"," 

REM default example
eventcreate.exe /T Information /ID 50 /L Application /D ""ProcessName":"calc.exe"," 
eventcreate.exe /T Information /ID 51 /L Application /D ""ProcessName":"calc.exe"," 
