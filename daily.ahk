#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory

; Variables
Increments 			:= 10 ; < lower for a more granular change, higher for larger jump in brightness 
CurrentBrightness 	:= GetCurrentBrightNess()

;txt
`::Send console.log("tst");

;Volume
NumpadSub::Send {Volume_Up}
NumpadAdd::Send {Volume_Down}


;brightness
NumpadDiv::ChangeBrightness( CurrentBrightness -= Increments ) ; decrease brightness
NumpadMult::ChangeBrightness( CurrentBrightness += Increments ) ; increase brightness


; Functions
ChangeBrightness( ByRef brightness, timeout = 1 )
{
	if ( brightness > 0 && brightness < 100 )
	{
		For property in ComObjGet( "winmgmts:\\.\root\WMI" ).ExecQuery( "SELECT * FROM WmiMonitorBrightnessMethods" )
			property.WmiSetBrightness( timeout, brightness )	
	}
 	else if ( brightness >= 100 )
 	{
 		brightness := 100
 	}
 	else if ( brightness <= 0 )
 	{
 		brightness := 0
 	}
}

GetCurrentBrightNess()
{
	For property in ComObjGet( "winmgmts:\\.\root\WMI" ).ExecQuery( "SELECT * FROM WmiMonitorBrightness" )
		currentBrightness := property.CurrentBrightness	

	return currentBrightness
}