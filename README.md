
Synopsis:
-----------------------------------
Powershell script providing audible notifications of application crash or hang incidents.

![alt tag](https://github.com/dstaulcu/EventsToSpeech/blob/master/screenshot.jpg)

Notes:
-----------------------------------
The "Hang this UI" and "Crash This App On Exit" features of [VirMemTest](https://blogs.msdn.microsoft.com/aaron_margosis/2013/06/14/virtmemtest-a-utility-to-exercise-memory-and-other-operations/) can be used to create conditions which induce EventToSpeech project notifications.  I reccomend configuring VirMemTest to hang it's UI for around 15 seconds in order to best understand latencies involved in unresponsive window detection.

UserEventToSpeech Update History:
-----------------------------------
	
	1.6.0
	--------

	Consolidated on single event log monitoring strategy 
	See: https://github.com/dstaulcu/EventsToSpeech/issues/13

	Reduced risk that event log records would be missed when speak method is invoked between
	See: https://github.com/dstaulcu/EventsToSpeech/issues/14

	Added informational events to stdout
	https://github.com/dstaulcu/EventsToSpeech/issues/15


	1.5.2
	--------

	Added notification when network interface enters a disconnected or connected state
	See: https://github.com/dstaulcu/EventsToSpeech/issues/12
	
