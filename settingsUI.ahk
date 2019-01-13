; Menu functions {{{
;MenuVimCheck:
;  ; Additional message is necessary before checking current window.
;  ; Otherwise process name cannot be retrieved...?
;  Msgbox, , Vim Ahk, Checking current window...
;  WinGet, process, PID, A
;  WinGet, name, ProcessName, ahk_pid %process%
;  WinGetClass, class, ahk_pid %process%
;  WinGetTitle, title, ahk_pid %process%
;  if WinActive("ahk_group VimGroup"){
;    Msgbox, 0x40, Vim Ahk,
;    (
;      Supported
;      Process name: %name%
;      Class       : %class%
;      Title       : %title%
;    )
;  }else{
;    Msgbox, 0x10, Vim Ahk,
;    (
;      Not supported
;      Process name: %name%
;      Class       : %class%
;      Title       : %title%
;    )
;  }
;Return

MenuVimStatus:
  VimCheckMode(VimVerboseMax, , , , 1)
Return

MenuVimSettings:
  global boxCreated
  Gui, VimGuiSettings:+LabelVimGuiSettings
  Gui, VimGuiSettings:-MinimizeBox
  Gui, VimGuiSettings:-Resize
  boxCreated=false
  for i, s in settings {
    ; if (s["type"] = "checkbox"){
      addCheckbox(s["name"], s["default"], s["descriptionShort"], s["descriptionLong"])
    ; }else{
    ;   if warn
    ;     msgbox % "Warning: Invalid setting type specified"
    ; }
  }
  Gui, VimGuiSettings:Add, Text, XS+10 Y+20 gVimDisableUnusedLevel vVimDisableUnusedLevel, Disable unused keys in Normal mode
  Gui, VimGuiSettings:Add, DropDownList, W320 vVimDisableUnusedValue Choose%VimDisableUnused%, %VimDisableUnused1%|%VimDisableUnused2%|%VimDisableUnused3%
  Gui, VimGuiSettings:Add, Text, XS+10 Y+20 gVimIconCheckIntervalText vVimIconCheckIntervalText, Icon check interval (ms)
  Gui, VimGuiSettings:Add, Edit, gVimIconCheckIntervalEdit vVimIconCheckIntervalEdit
  Gui, VimGuiSettings:Add, UpDown, vVimIconCheckInterval Range100-1000000, %VimIconCheckInterval%
  Gui, VimGuiSettings:Add, Text, XS+10 Y+20 gVimVerboseLevel vVimVerboseLevel, Verbose level
  Gui, VimGuiSettings:Add, DropDownList, vVimVerboseValue Choose%VimVerbose%, %VimVerbose1%|%VimVerbose2%|%VimVerbose3%|%VimVerbose4%
  Gui, VimGuiSettings:Add, Text, XS+10 Y+20 gVimGroupText vVimGroupText, Applications
  StringReplace, VimGroupList, VimGroup, %VimGroupDel%, `n, All
  Gui, VimGuiSettings:Add, Edit, XS+10 Y+10 R10 W300 Multi vVimGroupList, %VimGroupList%
  Gui, VimGuiSettings:Add, Text, XM+20 Y+35, Check
  Gui, VimGuiSettings:Font, Underline
  Gui, VimGuiSettings:Add, Text, X+5 cBlue gVimAhkGitHub vVimAhkGitHub, HELP
  Gui, VimGuiSettings:Font, Norm
  Gui, VimGuiSettings:Add, Text, X+5, for further information.
  Gui, VimGuiSettings:Add, Button, gVimGuiSettingsOK vVimGuiSettingsOK xm W100 X45 Y+30 Default, &OK
  Gui, VimGuiSettings:Add, Button, gVimGuiSettingsReset vVimGuiSettingsReset W100 X+10, &Reset
  Gui, VimGuiSettings:Add, Button, gVimGuiSettingsCancel vVimGuiSettingsCancel W100 X+10, &Cancel
  Gui, VimGuiSettings:Show, W410, Vim Ahk Settings
  OnMessage(0x200, "VimMouseMove")
Return

VimMouseMove(){
  global VimCurrControl, VimPrevControl
  VimCurrControl := A_GuiControl
  if(VimCurrControl != VimPrevControl){
    VimPrevControl := VimCurrControl
    ToolTip
    if(VimCurrControl != "" && InStr(VimCurrControl, " ") == 0){
      SetTimer, VimDisplayToolTip, 1000
      VimPrevControl := VimCurrControl
    }
  }
  Return
}

VimDisplayToolTip:
  SetTimer, VimDisplayToolTip, Off
  ToolTip % %VimCurrControl%_TT
  SetTimer, VimRemoveToolTip, 60000
Return

VimRemoveToolTip:
  SetTimer, VimRemoveToolTip, Off
  ToolTip
Return

VimGuiSettingsApply:
  VimSetGroup()
  Loop, %VimDisableUnusedMax% {
    if(VimDisableUnusedValue == VimDisableUnused%A_Index%){
      VimDisableUnused := A_Index
      Break
    }
  }
  Loop, %VimVerboseMax% {
    if(VimVerboseValue == VimVerbose%A_Index%){
      VimVerbose := A_Index
      Break
    }
  }
  if(VimIcon == 1){
     VimSetIcon(VimMode)
  }else{
     VimSetIcon("Default")
  }
  if(VimIconCheck == 1){
    SetTimer, VimStatusCheckTimer, %VimIconCheckInterval%
  }else{
    SetTimer, VimStatusCheckTimer, OFF
  }
Return

VimGuiSettingsOK:
  Gui, VimGuiSettings:Submit
  Gosub, VimGuiSettingsApply
  VimWriteIni()
VimGuiSettingsCancel:
VimGuiSettingsClose:
VimGuiSettingsEscape:
  SetTimer, VimDisplayToolTip, Off
  ToolTip
  Gui, VimGuiSettings:Destroy
Return

VimGuiSettingsReset:
  IfExist, %VimIni%
    FileDelete, %VimIni%

  for i, s in settings {
    name := s["name"]
    %name% := s["default"]
  }
  VimGroup := VimGroupIni
  VimDisableUnused := VimDisableUnusedIni
  VimIconCheckInterval := VimIconCheckIntervalIni
  VimVerbose := VimVerboseIni

  Gosub, VimGuiSettingsApply

  SetTimer, VimDisplayToolTip, Off
  ToolTip
  Gui, VimGuiSettings:Destroy
  Gosub, MenuVimSettings
Return

VimGroupText: ; Dummy to assign Gui Control
Return

VimIconCheckIntervalText: ; Dummy to assign Gui Control
Return

VimIconCheckIntervalEdit: ; Dummy to assign Gui Control
Return

VimDisableUnusedLevel: ; Dummy to assign Gui Control
Return

VimVerboseLevel: ; Dummy to assign Gui Control
Return

VimAhkGitHub:
  Run %VimHomepage%
Return

MenuVimAbout:
  Gui, VimGuiAbout:+LabelVimGuiAbout
  Gui, VimGuiAbout:-MinimizeBox
  Gui, VimGuiAbout:-Resize
  Gui, VimGuiAbout:Add, Text, , Vim Ahk (vim_ahk):`n%VimDescription%
  Gui, VimGuiAbout:Font, Underline
  Gui, VimGuiAbout:Add, Text, Y+0 cBlue gVimAhkGitHub, Homepage
  Gui, VimGuiAbout:Font, Norm
  Gui, VimGuiAbout:Add, Text, , Author: %VimAuthor%
  Gui, VimGuiAbout:Add, Text, , Version: %VimVersion%
  Gui, VimGuiAbout:Add, Text, Y+0, Last update: %VimDate%
  Gui, VimGuiAbout:Add, Text, , Script path:`n%A_LineFile%
  Gui, VimGuiAbout:Add, Text, , Setting file:`n%VimIni%
  Gui, VimGuiAbout:Add, Button, gVimGuiAboutOK X200 W100 Default, &OK
  Gui, VimGuiAbout:Show, W500, Vim Ahk
Return

VimGuiAboutOK:
VimGuiAboutClose:
VimGuiAboutEscape:
  Gui, VimGuiAbout:Destroy
Return
; }}}
; vim: foldmethod=marker
; vim: foldmarker={{{,}}}
; vim: ts=2:sw=2:sts=2:et
