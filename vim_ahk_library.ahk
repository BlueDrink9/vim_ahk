; Basic Functions {{{

VimSetGroup() {
  global
  VimGroupN++
  VimGroupName := "VimGroup" . VimGroupN
  Loop, Parse, VimGroup, % VimGroupDel
  {
    if(A_LoopField != ""){
      GroupAdd, %VimGroupName%, %A_LoopField%
    }
  }
}

VimSetIcon(Mode=""){
  global VimIcon, VimIconNormal, VimIconInsert, VimIconVisual, VimIconCommand, VimIconDisabled, VimIconDefault
  icon :=
  if InStr(Mode, "Normal"){
    icon := VimIconNormal
  }else if InStr(Mode, "Insert"){
    icon := VimIconInsert
  }else if InStr(Mode, "Visual"){
    icon := VimIconVisual
  }else if InStr(Mode, "Command"){
    icon := VimIconCommand
  }else if InStr(Mode, "Disabled"){
    icon := VimIconDisabled
  }else if InStr(Mode, "Default"){
    icon := VimIconDefault
  }
  if FileExist(icon){
    if(InStr(Mode, "Default")){
      Menu, Tray, Icon, %icon%
    }else{
      Menu, VimSubMenu, Icon, Status, %icon%
      if(VimIcon == 1){
        Menu, Tray, Icon, %icon%
      }
    }
  }
}

checkValidMode(mode, full_match = true){
  Global possibleVimModes
  try {
    inOrBlank:= (not full_match) ? "in " : ""
    if not hasValue(possibleVimModes, mode, full_match) {
      throw Exception("Invalid mode specified",-2,
      ( Join
"'" mode "' is not " inOrBlank "a valid mode as defined by the possibleVimModes
 array at the top of vim_ahk_library. This may be a typo.
 Fix this error by using an existing mode,
 or adding your mode to the array.")
      )
    }
  } catch e {
    MsgBox % "Warning: " e.Message "`n" e.Extra "`n`n Called in " e.What " at line " e.Line
  }
}

; NOTE: Currently, any mode that isn't otherwise specially handled will
; send letters through as if in insert mode.
; However, they may not trigger insert-specific mappings.
VimSetMode(Mode="", g=0, n=0, LineCopy=-1){
  global
  if warn {
    checkValidMode(mode)
  }
  if(Mode != ""){
    if (Mode = "Vim_Normal" and VimMode != Mode){
      ; Send left to drop you "on" the letter you were in front of.
      send {left}
    }
    VimMode := Mode
    If(Mode == "Insert") and (VimRestoreIME == 1){
      VIM_IME_SET(VimLastIME)
    }
    VimSetIcon(VimMode)
  }
  if(g != -1){
    Vim_g := g
  }
  if(n != -1){
    Vim_n := n
  }
  if(LineCopy!=-1){
    VimLineCopy := LineCopy
  }
  VimCheckMode(VimVerbose, Mode, g, n, LineCopy)
  Return
}

isCurrentVimMode(mode){
  global VimMode
  if warn {
    checkValidMode(mode)
  }
  return (mode == VimMode)
}

strIsInCurrentVimMode(str){
  global VimMode
  if warn {
    checkValidMode(str, false)
  }
  return (inStr(VimMode, str))
}

VimCheckMode(verbose=1, Mode="", g=0, n=0, LineCopy=-1, force=0){
  global

  if(force == 0) and ((verbose <= 1) or ((Mode == "") and (g == 0) and (n == 0) and (LineCopy == -1))){
    Return
  }else if(verbose == 2){
    VimStatus(VimMode, 1) ; 1 sec is minimum for TrayTip
  }else if(verbose == 3){
    VimStatus(VimMode "`r`ng=" Vim_g "`r`nn=" Vim_n "`r`nLineCopy=" VimLineCopy, 4)
  }
  if(verbose >= 4){
    Msgbox, , Vim Ahk, VimMode: %VimMode%`nVim_g: %Vim_g%`nVim_n: %Vim_n%`nVimLineCopy: %VimLineCopy%
  }
  Return
}

VimStatus(Title, lines=1){
  WinGetPos, , , W, H, A
  Tooltip, %Title%, W - 110, H - 30 - (lines) * 20
  SetTimer, VimRemoveStatus, 1000
}

VimRemoveStatus:
  SetTimer, VimRemoveStatus, off
  Tooltip
Return

; Wait for a single letter to be inputted.
; Returns true if that letter was inputted, false if anything else was or it times out.
expectSingleLetterFromGroup(lettergroup){
  ; I: ignore AHK-generated input.
  ; T0.1: Timeout after 0.1 seconds.
  ; V: Key entered is sent through to window.
  ; L1: End after 1 letter entered
  ; Ends when %letter% is entered
  ; Input, out, I T0.2 V L1, %lettergroup%
  Input, out, T0.3 V L1, %lettergroup%
  return inStr(ErrorLevel,"EndKey")
}

VimReadIni(){
  global
  IniRead, VimGroup, %VimIni%, %VimSection%, VimGroup, %VimGroup%
  IniRead, VimDisableUnused, %VimIni%, %VimSection%, VimDisableUnused, %VimDisableUnused%

  for i, s in settings {
    if (testing and s["name"] = "VimLongEscNormal") {
      ; Only use default for this if testing
      continue
    }
    name := s["name"]
    value := %name%
    IniRead, %name%, %VimIni%, %VimSection%, %name%, %value%
  }
  IniRead, VimIconCheckInterval, %VimIni%, %VimSection%, VimIconCheckInterval, %VimIconCheckInterval%
  IniRead, VimVerbose, %VimIni%, %VimSection%, VimVerbose, %VimVerbose%
}

VimWriteIni(){
  global
  IfNotExist, %VimIniDir%
    FileCreateDir, %VimIniDir%

  VimGroup := ""
  Loop, Parse, VimGroupList, `n
  {
    if(! InStr(VimGroup, A_LoopField)){
      if(VimGroup == ""){
        VimGroup := A_LoopField
      }else{
        VimGroup := VimGroup . VimGroupDel . A_LoopField
      }
    }
  }
  VimSetGroup()
  IniWrite, % VimGroup, % VimIni, % VimSection, VimGroup
  IniWrite, % VimDisableUnused, % VimIni, % VimSection, VimDisableUnused

  for i, s in settings {
    name := s["name"]
    value := %name%
    IniWrite, %value%, %VimIni%, %VimSection%, %name%
  }

  IniWrite, % VimIconCheckInterval, % VimIni, % VimSection, VimIconCheckInterval
  IniWrite, % VimVerbose, % VimIni, % VimSection, VimVerbose
}

InActiveWindow(){
  if WinActive("ahk_group " . VimGroupName) or (AllowOverrideNormal == 1 and !WinActive(vim))
    return true
  else
    return false
}

VimSetGuiOffset(offset=0){
  VimGuiAbout := offset + 1
  VimGuiSettings := offset + 2
  VimGuiVerbose := offset + 3
}

VimStatusCheckTimer:
  if WinActive("ahk_group " . VimGroupName)
  {
    VimSetIcon(VimMode)
  }else{
    VimSetIcon("Disabled")
  }
Return

VimStartStatusCheck:
  SetTimer, VimStatusCheckTimer, off
Return

VimStopStatusCheck:
  SetTimer, VimStatusCheckTimer, off
Return

hasValue(haystack, needle, full_match = true) {
  if(!isObject(haystack)){
    return false
  }else if(haystack.Length()==0){
    return false
  }
  for index,value in haystack{
    if full_match{
      if (value==needle){
        return true
      }
    }else{
      if (inStr(value, needle)){
        return true
      }
    }
  }
  return false
}

; class checkboxSetting {
;   }

; Adds a setting to the UI and default ini.
; name: name to use for the setting
; DefaultVal: The value to use before setting and when resetting
; descriptionShort: Label in the UI
; descriptionLong: Tooltip text in UI.
addSetting(name, defaultVal, descriptionShort, descriptionLong, type="checkbox"){
  ; global %name%
  global
  ; msgbox % "Y = "Y
  ; msgbox % "XS = "XS
  %name%Ini := defaultVal
  ; Blank variables are unset
  if (%name% = ""){
    %name% := defaultVal
  }
  %name%_TT := descriptionLong

  ; if (type = "checkbox"){
  ;   addCheckbox(name, defaultVal, descriptionShort, descriptionLong)
  ; }else{
  ;   if warn
  ;     msgbox % "Warning: Invalid setting type specified"
  ; }
}

addCheckbox(name, defaultVal, descriptionShort, descriptionLong){
  global boxCreated
  global settings
  checkboxRows := settings.Length() + 1
  if boxCreated=false
  {
  Gui, VimGuiSettings:Add, GroupBox, w320 R%checkboxRows% Section, Settings
  boxCreated=true
  }

  Gui, VimGuiSettings:Add, Checkbox, xs+10 yp+20 v%name%, %descriptionShort%
  if(%name% == 1){
    GuiControl, VimGuiSettings:, %name%, 1
  }
}



; }}}
; vim: foldmethod=marker
; vim: foldmarker={{{,}}}
; vim: ts=2:sw=2:sts=2:et
