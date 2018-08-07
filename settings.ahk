; AutohHotkey settings {{{

#Warn ; Provides code warnings when running
; #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#UseHook On ; Make it a bit slow, but can avoid infinitude loop
            ; Same as "$" for each hotkey
#InstallKeybdHook ; For checking key history
                  ; Use ~500kB memory?
#HotkeyInterval 2000 ; Hotkey inteval (default 2000 milliseconds).
#MaxHotkeysPerInterval 70 ; Max hotkeys per interval (default 50).
#SingleInstance force ; Automatically reload script when run, don't ask about duplicates.
;}}}

; Auto-execute section {{{
; Auto execute section is the region before any return/hotkey
; About vim_ahk
VimVersion := "v0.3.0"
VimDate := "15/Apr/2018"
VimAuthor := "rcmdnk"
VimDescription := "Vim emulation with AutoHotkey, everywhere in Windows."
VimHomepage := "https://github.com/rcmdnk/vim_ahk"

; Ini file
VimIniDir := % A_AppData . "\AutoHotkey"
VimIni := % VimIniDir . "\vim_ahk.ini"

VimSection := "Vim Ahk Settings"

; Icon places
VimIconNormal := % A_LineFile . "\..\icons\normal.ico"
VimIconInsert := % A_LineFile . "\..\icons\insert.ico"
VimIconVisual := % A_LineFile . "\..\icons\visual.ico"
VimIconCommand := % A_LineFile . "\..\icons\command.ico"
VimIconDisabled := % A_LineFile . "\..\icons\disabled.ico"
VimIconDefault := % A_AhkPath

; Application groups {{{

VimGroupDel := ","
VimGroupN := 0

; Enable vim mode for following applications
VimGroup_TT := "Set one application per line.`n`nIt can be any of Window Title, Class or Process.`nYou can check these values by Window Spy (in the right click menu of tray icon)."
;VimGroupList_TT := VimGroup_TT
VimGroupText_TT := VimGroup_TT
VimGroupIni :=                             "ahk_exe notepad.exe"   ; NotePad
VimGroupIni := VimGroupIni . VimGroupDel . "ahk_exe wordpad.exe"   ; WordPad
VimGroupIni := VimGroupIni . VimGroupDel . "ahk_exe notepad++.exe" ; notepad++
VimGroupIni := VimGroupIni . VimGroupDel . "ahk_exe TeraPad.exe"   ; TeraPad
VimGroupIni := VimGroupIni . VimGroupDel . "ahk_exe explorer.exe"  ; Explorer
VimGroupIni := VimGroupIni . VimGroupDel . "作成"                  ;Thunderbird, 日本語
VimGroupIni := VimGroupIni . VimGroupDel . "Write:"                ;Thuderbird, English
VimGroupIni := VimGroupIni . VimGroupDel . "ahk_exe POWERPNT.exe"  ; PowerPoint
VimGroupIni := VimGroupIni . VimGroupDel . "ahk_exe WINWORD.exe"   ; Word
VimGroupIni := VimGroupIni . VimGroupDel . "ahk_exe Evernote.exe"  ; Evernote
VimGroupIni := VimGroupIni . VimGroupDel . "ahk_exe Code.exe"      ; Visual Studio Code
VimGroupIni := VimGroupIni . VimGroupDel . "ahk_exe onenote.exe"   ; OneNote Desktop
VimGroupIni := VimGroupIni . VimGroupDel . "OneNote"               ; OneNote in Windows 10
VimGroupIni := VimGroupIni . VimGroupDel . "ahk_exe texworks.exe"  ; TexWork
VimGroupIni := VimGroupIni . VimGroupDel . "ahk_exe texstudio.exe" ; TexStudio

VimGroup := VimGroupIni

; Following application select the line break at Shift + End.
GroupAdd, VimLBSelectGroup, ahk_exe POWERPNT.exe ; PowerPoint
GroupAdd, VimLBSelectGroup, ahk_exe WINWORD.exe  ; Word
GroupAdd, VimLBSelectGroup, ahk_exe wordpad.exe  ; WordPad

; OneNote before Windows 10
GroupAdd, VimOneNoteGroup, ahk_exe onenote.exe ; OneNote Desktop

; Need Home twice
GroupAdd, VimDoubleHomeGroup, ahk_exe Code.exe ; Visual Studio Code
; }}}

; Setting variables {{{
; First check if they are already set (in mother script).
; Second read settings if it exits.

; If IME status is restored or not at entering insert mode. 1 for restoring. 0 for not to restore (always IME off at enterng insert mode).
VimRestoreIMEIni := 1
if VimRestoreIME is not integer
  VimRestoreIME := VimRestoreIMEIni
VimRestoreIME_TT := "Restore IME status at entering Insert mode."

; Set 1 to asign jj to enter Normal mode
VimJJIni := 0
if VimJJ is not integer
  VimJJ := VimJJIni
VimJJ_TT := "Asign jj to enter Normal mode"
; Set 1 to asign jk to enter Normal mode
VimJKIni := 0
if VimJK is not integer
  VimJK := VimJKIni
VimJK_TT := "Asign jk to enter Normal mode"
; Set 1 to asign kv to enter Normal mode
VimKVIni := 0
if VimKV is not integer
  VimKV := VimKVIni
VimKV_TT := "Asign kv to enter Normal mode"

; Set 1 to make holding esc enter normal mode and single press send through esc
VimLongEscNormalIni := 0
if VimLongEscNormal is not integer
  VimLongEscNormal := VimLongEscNormalIni
VimLongEscNormal_TT := "Hold esc to enter normal, single press to send esc to window"


; Set 1 to enable Tray Icon for Vim Modes`nSet 0 for original Icon
VimIconIni := 1
if VimIcon is not integer
  VimIcon := VimIconIni
VimIcon_TT := "Enable tray icon for Vim Modes"

; Set 1 to enable Tray Icon check
VimIconCheckIni := 1
if VimIconCheck is not integer
  VimIconCheck := VimIconCheckIni
VimIconCheck_TT := "Enable tray icon check"

; Disable unused keys in Normal mode
VimDisableUnusedIni := 3
if VimDisableUnused is not integer
  VimDisableUnused := VimDisableUnusedIni
VimDisableUnused1 := "1: Do not disable unused keys"
VimDisableUnused2 := "2: Disable alphabets (+shift) and symbols"
VimDisableUnused3 := "3: Disable all including keys with modifiers (e.g. Ctrl+Z)"
vimDisableUnusedMax := 3
VimDisableUnusedValue := ""
VimDisableUnusedValue_TT := "Disable unused keys in Normal mode"
VimDisableUnusedLevel_TT := VimDisableUnusedValue_TT

; Tray Icon check interval
VimIconCheckIntervalIni := 1000
if VimIconCheckInterval is not integer
  VimIconCheckInterval := VimIconCheckIntervalIni
VimIconCheckInterval_TT := "Interval (ms) to check if current window is for Ahk Vim or not,`nand set tray icon."
VimIconCheckIntervalText_TT := VimIconCheckInterval_TT
VimIconCheckIntervalEdit_TT := VimIconCheckInterval_TT

; Verbose level, 1: No pop up, 2: Minimum tool tips of status, 3: More info in tool tips, 4: Debug mode with a message box, which doesn't disappear automatically
VimVerboseIni := 1
if VimVerbose is not integer
  VimVerbose := VimVerboseIni
VimVerbose1 := "1: No pop up"
VimVerbose2 := "2: Minimum tool tips"
VimVerbose3 := "3: Tool tips"
VimVerbose4 := "4: Popup message"
vimVerboseMax := 4
VimVerboseValue := ""
VimVerboseValue_TT := "Verbose level`n`n1: No pop up`n2: Minimum tool tips of status`n: More info in tool tips`n4: Debug mode with a message box, which doesn't disappear automatically"
VimVerboseLevel_TT := VimVerboseValue_TT

; Other explanations for settings
VimGuiSettingsOK_TT := "Reflect changes and exit"
VimGuiSettingsReset_TT := "Reset to the default values"
VimGuiSettingsCancel_TT := "Don't change and exit"
VimAhkGitHub_TT := VimHomepage

; Read Ini
VimReadIni()

; Set group
VimSetGroup()

; Starting variables
VimMode := "Insert"
Vim_g := 0
Vim_n := 0
VimLineCopy := 0
VimLastIME := 0

VimCurrControl := ""
VimPrevControl := ""

; }}}

; Menu
;Menu, VimSubMenu, Add, Vim Check, MenuVimCheck
Menu, VimSubMenu, Add, Settings, MenuVimSettings
Menu, VimSubMenu, Add
Menu, VimSubMenu, Add, Status, MenuVimStatus
Menu, VimSubMenu, Add, About vim_ahk, MenuVimAbout

Menu, Tray, Add
Menu, Tray, Add, VimMenu, :VimSubMenu

; Set initial icon
VimSetIcon(VimMode)

; Set Timer for status check
if(VimIconCheck == 1){
  SetTimer, VimStatusCheckTimer, %VimIconCheckInterval%
}

Return

; }}}
; vim: foldmethod=marker
; vim: foldmarker={{{,}}}
; vim: ts=2:sw=2:sts=2:et
