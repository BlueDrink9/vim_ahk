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

; NOTE: Currently, any mode that isn't otherwise specially handled will
; send letters through as if in insert mode.
; However, they may not trigger insert-specific mappings.
VimSetMode(Mode="", g=0, n=0, LineCopy=-1){
  global
  if(Mode != ""){
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
VimMode(){
  Global VimMode
  return VimMode
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
  IniRead, VimRestoreIME, %VimIni%, %VimSection%, VimRestoreIME, %VimRestoreIME%
  IniRead, VimJJ, %VimIni%, %VimSection%, VimJJ, %VimJJ%
  IniRead, VimKV, %VimIni%, %VimSection%, VimKV, %VimKV%
  IniRead, VimJK, %VimIni%, %VimSection%, VimJK, %VimJK%
  IniRead, VimLongEscNormal, %VimIni%, %VimSection%, VimLongEscNormal, %VimLongEscNormal%
  IniRead, VimIcon, %VimIni%, %VimSection%, VimIcon, %VimIcon%
  IniRead, VimIconCheck, %VimIni%, %VimSection%, VimIconCheck, %VimIconCheck%
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
  IniWrite, % VimRestoreIME, % VimIni, % VimSection, VimRestoreIME
  IniWrite, % VimJJ, % VimIni, % VimSection, VimJJ
  IniWrite, % VimJK, % VimIni, % VimSection, VimJK
  IniWrite, % VimKV, % VimIni, % VimSection, VimKV
  IniWrite, % VimLongEscNormal, % VimIni, % VimSection, VimLongEscNormal
  IniWrite, % VimIcon, % VimIni, % VimSection, VimIcon
  IniWrite, % VimIconCheck, % VimIni, % VimSection, VimIconCheck
  IniWrite, % VimIconCheckInterval, % VimIni, % VimSection, VimIconCheckInterval
  IniWrite, % VimVerbose, % VimIni, % VimSection, VimVerbose
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
; }}}
; vim: foldmethod=marker
; vim: foldmarker={{{,}}}
; vim: ts=2:sw=2:sts=2:et
