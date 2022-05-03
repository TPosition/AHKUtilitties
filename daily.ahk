#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory

; Variables
Increments 			:= 10 ; < lower for a more granular change, higher for larger jump in brightness 
CurrentBrightness 	:= GetCurrentBrightNess()

;txt
!NumpadDot::Send console.log("tst");

;always on top
!w::  Winset, Alwaysontop, , A

;Volume
Alt & NumpadSub::Send {Volume_Up}
Alt & NumpadAdd::Send {Volume_Down}

; toggle press
RShift & d::
wtog:=!wtog
if wtog
Send {d Down}
else 
Send {d Up}
return

RShift & a::
atog:=!atog
if wtog
Send {a Down}
else 
Send {a Up}
return


;brightness
Alt & NumpadDiv::ChangeBrightness( CurrentBrightness -= Increments ) ; decrease brightness
Alt & NumpadMult::ChangeBrightness( CurrentBrightness += Increments ) ; increase brightness


; Functions
ChangeBrightness( ByRef brightness, timeout = 1 )
{
	if ( brightness >= 0 && brightness <= 100 )
	{
		For property in ComObjGet( "winmgmts:\\.\root\WMI" ).ExecQuery( "SELECT * FROM WmiMonitorBrightnessMethods" )
			property.WmiSetBrightness( timeout, brightness )	
	}
 	else if ( brightness >= 100 )
 	{
 		brightness := 100
 	}
 	else if ( brightness < 0 )
 	{
 		brightness := 0
 	}

BrightnessOSD()

}

GetCurrentBrightNess()
{
	For property in ComObjGet( "winmgmts:\\.\root\WMI" ).ExecQuery( "SELECT * FROM WmiMonitorBrightness" )
		currentBrightness := property.CurrentBrightness	

	return currentBrightness
}

BrightnessOSD() {
	static PostMessagePtr := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "PostMessageW" : "PostMessageA", "Ptr")
	 ,WM_SHELLHOOK := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK", "UInt")
	static FindWindow := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "FindWindowW" : "FindWindowA", "Ptr")
	HWND := DllCall(FindWindow, "Str", "NativeHWNDHost", "Str", "", "Ptr")
	IF !(HWND) {
		try IF ((shellProvider := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}"))) {
			try IF ((flyoutDisp := ComObjQuery(shellProvider, "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}", "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}"))) {
				DllCall(NumGet(NumGet(flyoutDisp+0)+3*A_PtrSize), "Ptr", flyoutDisp, "Int", 0, "UInt", 0)
				 ,ObjRelease(flyoutDisp)
			}
			ObjRelease(shellProvider)
		}
		HWND := DllCall(FindWindow, "Str", "NativeHWNDHost", "Str", "", "Ptr")
	}
	DllCall(PostMessagePtr, "Ptr", HWND, "UInt", WM_SHELLHOOK, "Ptr", 0x37, "Ptr", 0)
}


#SingleInstance force

PgUp::hk(1,0)              ; Disable all keyboard keys
PgDn::hk(0,0)              ; Enable all keyboard keys and mouse buttons
;!F3::hk(1,1,"KEYBOARD MOUSE AND SCREEN LOCKED!  -  ALT+F2 TO UNLOCK",,,1,"teal")   ; Disable keyboard mouse and screen


hk(keyboard:=false, mouse:=0, message:="", timeout:=3, displayonce:=false,screen:=false, screencolor:="blue") { 

;keyboard (true/false).......................... disable/enable keyboard
;mouse=1........................................ disable all mouse buttons
;mouse=2........................................ disable right mouse button only
;msessage....................................... display a message
;timeout........................................ how long to display the message in sec
;displayonce (true/false) ...................... display a message only once or always
;hide the screen (true/false)................... hide or show everything
;ScreenColor ................................... RGB Hex background color for the hiding GUI 


   static AllKeys, z, d, kb, ms, sc
   z:=message, d:=displayonce, kb:=keyboard, ms:=mouse, sc:=screen

      For k,v in AllKeys {
           Hotkey, *%v%, Block_Input, off         ; initialisation
      }
   if !AllKeys {
      s := "||NumpadEnter|Home|End|PgUp|PgDn|Left|Right|Up|Down|Del|Ins|"
      Loop, 254
         k := GetKeyName(Format("VK{:0X}", A_Index))
       , s .= InStr(s, "|" k "|") ? "" : k "|"
      For k,v in {Control:"Ctrl",Escape:"Esc"}
         AllKeys := StrReplace(s, k, v)
      AllKeys := StrSplit(Trim(AllKeys, "|"), "|")
   }
   ;------------------
   if (mouse!=2)  ; if mouse=1 disable right and left mouse buttons  if mouse=0 don't disable mouse buttons
    {
        For k,v in AllKeys {
           IsMouseButton := Instr(v, "Wheel") || Instr(v, "Button")
           Hotkey, *%v%, Block_Input, % (keyboard && !IsMouseButton) || (mouse && IsMouseButton) ? "On" : "Off"
        }
    }
   if (mouse=2)   ;disable right mouse button (but not left mouse)
    {                
     ExcludeKeys:="LButton"
      For k,v in AllKeys {
           IsMouseButton := Instr(v, "Wheel") || Instr(v, "Button")
           if v not in %ExcludeKeys%
           Hotkey, *%v%, Block_Input, % (keyboard && !IsMouseButton) || (mouse && IsMouseButton) ? "On" : "Off"
        }
    }
   if d
    {
   if (z != "") {
      Progress, +AlwaysOnTop W2000 H43 b zh0 cwFF0000 FM20 CTFFFFFF,, %z%
      SetTimer, TimeoutTimer, % -timeout*1000
   }
   else
      Progress, Off
     }
   Block_Input:
   if (d!=1)
    {
   if (z != "") {
	    if (kb || ms)
			Progress, W2000 H43 b zh0 cwFF0000 FM20 CTFFFFFF,, %z%
		else
			Progress, W2000 H43 b zh0 cw009F00 FM20 CTFFFFFF,, %z%
		SetTimer, TimeoutTimer, % -timeout*1000
   }
   else
      Progress, Off
     }


if (sc=1)
   { 
     Gui screen:  -Caption
     Gui screen: Color,  % screencolor
     Gui screen: Show, x0 y0 h74 w%a_screenwidth% h%a_screenheight%, New GUI Window
   }
   else
      gui screen: Hide


   Return
   TimeoutTimer:
   Progress, Off
   Return
}
