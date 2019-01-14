; Autorun section {{{
possibleVimModes := []
possibleVimModes.Push("Vim_Normal", "Insert", "Replace", "Vim_ydc_y"
, "Vim_ydc_c", "Vim_ydc_d", "Vim_VisualLine", "Vim_VisualFirst"
, "Vim_VisualChar", "Command", "Command_w", "Command_q", "Z", "")

#include %A_LineFile%\..\settings.ahk
; Autorun section }}}
Return ; Prevents commands below here from auto-running
#include %A_LineFile%\..\settingsUI.ahk
#include %A_LineFile%\..\IME.ahk
#include %A_LineFile%\..\vim_ahk_library.ahk
; Directives to include the up and down exes when compiling to exe.
FileInstall, sendDown.exe, sendDown.exe
FileInstall, sendUp.exe, sendUp.exe

; Vim mode {{{
#If
; Launch Settings {{{
^!+v::
  Gosub, MenuVimSettings
Return

; }}}

#If WinActive("ahk_group " . VimGroupName)
; Check Mode {{{
^!+c::
  VimCheckMode(VimVerboseMax, VimMode)
Return
; }}}

; Enter vim normal mode {{{
Esc:: ; Just send Esc at converting, long press for normal Esc (depending on options)
  KeyWait, Esc, T0.5
  if (ErrorLevel){ ; long press
    if VimLongEscNormal {
      checkIMENormal()
    }else{
      Send,{Esc}
    }
    Return
  }else{
    if not VimLongEscNormal {
      checkIMENormal()
    }else{
      Send,{Esc}
    }
  }
Return

; Set normal-mode hotkeys to high priority, so they can interrupt any other thread.
hotkey,Esc,,P50
hotkey,^],,P50

checkIMENormal(){
  L_VimLastIME:=VIM_IME_Get()
  if(L_VimLastIME){
    if(VIM_IME_GetConverting(A)){
      Send,{Esc}
    }else{
      VIM_IME_SET()
      VimSetMode("Vim_Normal")
    }
  }else{
    VimSetMode("Vim_Normal")
  }
}

#If WinActive("ahk_group " . VimGroupName)
^[:: ; Go to Normal mode (for vim) with IME off even at converting.
  KeyWait, [, T0.5
  if(ErrorLevel){ ; long press to Esc
    Send, {Esc}
    Return
  }
  checkIMENormal()
Return


#If WinActive("ahk_group " . VimGroupName) and (isCurrentVimMode("Insert"))
~k::
  ; kv: go to Normal mode.
  if (VimKV == 1){
    if expectSingleLetterFromGroup("v"){
      SendInput, {BackSpace 2}
      VimSetMode("Vim_Normal")
    }
  }
Return

; jj/jk: go to Normal mode.
~j::
  ; Prevent kv also triggering input command
  if (VimKV){
    oldKV = 1
    VimKV = 0
  }else{
    oldKV=0
  }
  if (VimJJ){
    if (VimJK){
      goNorm := expectSingleLetterFromGroup("jk")
    }else{
      gonorm := expectsingleletterfromgroup("j")
    }
  }else if (vimJK) {
    goNorm := expectSingleLetterFromGroup("k")
  }else{
    goNorm := False
  }
  if goNorm {
    SendInput, {BackSpace 2}
    VimSetMode("Vim_Normal")
  }
  if (oldKV){
    VimKV=1
  }
Return
; }}}

; Enter vim insert mode (Exit vim normal mode) {{{
#If WinActive("ahk_group " . VimGroupName) && (isCurrentVimMode("Vim_Normal"))
i::VimSetMode("Insert")

; MS Office lets you interact with "the ribbon" (toolbar) via keyboard by 
; pressing and releasing the Alt key, then pressing additional shortcut keys
; that appear on the ribbon.
$Alt::
    Send {Alt}
    VimSetMode("Insert")
Return

+i::
  Send, {Home}
  ; Sleep, 200
  VimSetMode("Insert")
Return

a::
  Send, {Right}
  VimSetMode("Insert")
Return

+a::
  Send, {End}
  ; Sleep, 200
  VimSetMode("Insert")
Return

o::
  Send,{End}{Enter}
  VimSetMode("Insert")
Return

+o::
  Send, {Up}{End}{Enter}
  ; Sleep, 200
  VimSetMode("Insert")
Return
; }}}

; Repeat {{{
#If InActiveWindow() and (strIsInCurrentVimMode("Vim_"))
1::
2::
3::
4::
5::
6::
7::
8::
9::
  n_repeat := Vim_n*10 + A_ThisHotkey
  VimSetMode("", 0, n_repeat)
Return

#If WinActive("ahk_group " . VimGroupName) and (strIsInCurrentVimMode("Vim_")) and (Vim_n > 0)
0:: ; 0 is used as {Home} for Vim_n=0
  n_repeat := Vim_n*10 + A_ThisHotkey
  VimSetMode("", 0, n_repeat)
Return
; }}}

; Normal Mode Basic {{{
#If WinActive("ahk_group " . VimGroupName) and (strIsInCurrentVimMode("Vim_Normal"))
; Undo/Redo
u::Send,^z
^r::Send,^y

; Combine lines
+j::Send, {Down}{Home}{BS}{Space}{Left}

; Change case {{{
~::
  tooltip, hello
  bak := ClipboardAll
  Clipboard =
  Send, +{Right}^x
  ClipWait, 1
  if(Clipboard is lower){
    StringUpper, Clipboard, Clipboard
  }else if(Clipboard is upper){
    StringLower, Clipboard, Clipboard
  }
  Send, ^v
  Clipboard := bak
Return ; }}}

+z::VimSetMode("Z")
#If WinActive("ahk_group " . VimGroupName) and isCurrentVimMode("Z")
+z::
  Send, ^s
  Send, !{F4}
  VimSetMode("Vim_Normal")
Return

+q::
  Send, !{F4}
  VimSetMode("Vim_Normal")
Return

#If WinActive("ahk_group " . VimGroupName) and isCurrentVimMode("Vim_Normal")
Space::Send, {Right}

; period
.::Send, +^{Right}{BS}^v
; }}}

; Replace {{{
r::replace()
+r::replace(true)
replace(continue=false){
  ; I: ignore AHK-generated input.
  ; V: Key entered is sent through to window.
  ; L1: End after 1 letter entered
  ; Mode "Replace" has no special function, but it allows us to keep track of
  ; the state here, and won't trigger insert-mode mappings.
  VimSetMode("Replace")
  if continue {
    loop {
      Input, out, V L1,{esc}
      ; Check if we have been interrupted (eg by some other escape method) before continuing.
      if not isCurrentVimMode("Replace") {
        return
      }
      ; Esc must be handled separately.
      if inStr(ErrorLevel,"EndKey"){
        break
      }
      ; Check if a character was typed, rather than another button.
      if (out != "") {
        send {del}
      }
    }
  }else{
    Input, out, V L1, {Esc}
    send {del}
  }
  VimSetMode("Vim_Normal")
}
; }}}


; Move {{{
; g {{{
#If WinActive("ahk_group " . VimGroupName) and (strIsInCurrentVimMode("Vim_")) and (not Vim_g)
g::VimSetMode("", 1)
; }}}

VimMove(key="", shift=0){
  global
  if(strIsInCurrentVimMode("Visual") or strIsInCurrentVimMode("ydc") or shift == 1){
    Send, {Shift Down}
  }
  ; Left/Right
  if(not isCurrentVimMode("Vim_VisualLine")){
    ; 1 character
    if(key == "h"){
      Send, {Left}
    }else if(key == "l"){
      Send, {Right}
    ; Home/End
    }else if(key == "0"){
      Send, {Home}
    }else if(key == "$"){
      Send, {End}
    }else if(key == "^"){
      Send, {Home}^{Right}^{Left}
    ; Words
    }else if(key == "w"){
      Send, ^{Right}
    }else if(key == "b"){
      Send, ^{Left}
    }
  }
  ; Up/Down
  if(isCurrentVimMode("Vim_VisualLineFirst")) and (key == "k" or key == "^u" or key == "^b" or key == "g"){
    Send, {Shift Up}{End}{Home}{Shift Down}{Up}
    VimSetMode("Vim_VisualLine")
  }
  if(isCurrentVimMode("Vim_VisualLineFirst")) and (key == "j" or key == "^d" or key == "^f" or key == "+g"){
    VimSetMode("Vim_VisualLine")
  }
  if(strIsInCurrentVimMode("Vim_ydc")) and (key == "k" or key == "^u" or key == "^b" or key == "g"){
    VimLineCopy := 1
    Send,{Shift Up}{Home}{Down}{Shift Down}{Up}
  }
  if(strIsInCurrentVimMode("Vim_ydc")) and (key == "j" or key == "^d" or key == "^f" or key == "+g"){
    VimLineCopy := 1
    Send,{Shift Up}{Home}{Shift Down}{Down}
  }

  ; 1 character
  if(key == "j"){
    ; Only for OneNote of less than windows 10?
    if WinActive("ahk_group VimOneNoteGroup"){
      run %A_ScriptDir%\sendDown.exe
    } else {
      Send,{Down}
    }
  }else if(key="k"){
    if WinActive("ahk_group VimOneNoteGroup"){
      run %A_ScriptDir%\sendUp.exe
    }else{
      Send,{Up}
    }
  ; Page Up/Down
  }else if(key == "^u"){
    Send, {Up 10}
  }else if(key == "^d"){
    Send, {Down 10}
  }else if(key == "^b" or key == "PgUp"){
    Send, {PgUp}
  }else if(key == "^f" or key == "PgDn"){
    Send, {PgDn}
  }else if(key == "g"){
    Send, ^{Home}
  }else if(key == "+g"){
    Send, ^{End}{Home}
    ; Send, ^{End}
  }
  Send,{Shift Up}

  if(isCurrentVimMode("Vim_ydc_y")){
    Clipboard :=
    Send, ^c
    ClipWait, 1
    VimSetMode("Vim_Normal")
  }else if(isCurrentVimMode("Vim_ydc_d")){
    Clipboard :=
    Send, ^x
    ClipWait, 1
    VimSetMode("Vim_Normal")
  }else if(isCurrentVimMode("Vim_ydc_c")){
    Clipboard :=
    Send, ^x
    ClipWait, 1
    VimSetMode("Insert")
  }
  VimSetMode("", 0, 0)
}
VimMoveLoop(key="", shift=0){
  global
  if(Vim_n == 0){
    Vim_n := 1
  }
  Loop, %Vim_n%{
    VimMove(key, shift)
  }
}
#If WinActive("ahk_group " . VimGroupName) and (strIsInCurrentVimMode("Vim_"))
; 1 character
h::VimMoveLoop("h")
j::VimMoveLoop("j")
k::VimMoveLoop("k")
l::VimMoveLoop("l")
^h::VimMoveLoop("h")
^j::VimMoveLoop("j")
^k::VimMoveLoop("k")
^l::VimMoveLoop("l")
; Home/End
0::VimMove("0")
$::VimMove("$")
^a::VimMove("0") ; Emacs like
^e::VimMove("$") ; Emacs like
^::VimMove("^")
; Words
w::VimMoveLoop("w")
+w::VimMoveLoop("w") ; +w/e/+e are same as w
e::VimMoveLoop("w")
+e::VimMoveLoop("w")
b::VimMoveLoop("b")
+b::VimMoveLoop("b") ; +b = b
; Page Up/Down
^u::VimMoveLoop("^u")
^d::VimMoveLoop("^d")
^b::VimMoveLoop("^b")
^f::VimMoveLoop("^f")
PgDn::VimMoveLoop("PgDn")
PgUp::VimMoveLoop("PgUp")
; G
+g::VimMove("+g")
; gg
#If WinActive("ahk_group " . VimGroupName) and (strIsInCurrentVimMode("Vim_")) and (Vim_g)
g::VimMove("g")
; }}} Move

; Copy/Cut/Paste (ydcxp){{{
; YDC
#If WinActive("ahk_group " . VimGroupName) and (isCurrentVimMode("Vim_Normal"))
y::VimSetMode("Vim_ydc_y", 0, -1, 0)
d::VimSetMode("Vim_ydc_d", 0, -1, 0)
c::VimSetMode("Vim_ydc_c", 0, -1, 0)
; TODO reduce code duplication here
+y::
  VimSetMode("Vim_ydc_y", 0, 0, 1)
  Sleep, 150 ; Need to wait (For variable change?)
  if WinActive("ahk_group VimDoubleHomeGroup"){
    Send, {Home}
  }
  Send, {Home}+{End}
  if not WinActive("ahk_group VimLBSelectGroup"){
    VimMove("l")
  }else{
    VimMove("")
  }
  Send, {Left}{Home}
Return

+d::
  VimSetMode("Vim_ydc_d", 0, 0, 0)
  if not WinActive("ahk_group VimLBSelectGroup"){
    VimMove("$")
  }else{
    Send, {Shift Down}{End}{Left}
    VimMove("")
  }
Return

+c::
  VimSetMode("Vim_ydc_c",0,0,0)
  if not WinActive("ahk_group VimLBSelectGroup"){
    VimMove("$")
  }else{
    Send, {Shift Down}{End}{Left}
    VimMove("")
  }
Return

#If WinActive("ahk_group " . VimGroupName) and (isCurrentVimMode("Vim_ydc_y"))
y::
  VimLineCopy := 1
  if WinActive("ahk_group VimDoubleHomeGroup"){
    Send, {Home}
  }
  Send, {Home}+{End}
  if not WinActive("ahk_group VimLBSelectGroup"){
    VimMove("l")
  }else{
    VimMove("")
  }
  Send, {Left}{Home}
Return

#If WinActive("ahk_group " . VimGroupName) and (isCurrentVimMode("Vim_ydc_d"))
d::
  VimLineCopy := 1
  if WinActive("ahk_group DoubleHome"){
    Send, {Home}
  }
  Send, {Home}+{End}
  if not WinActive("ahk_group VimLBSelectGroup"){
    VimMove("l")
  }else{
    VimMove("")
  }
Return

#If WinActive("ahk_group " . VimGroupName) and (isCurrentVimMode("Vim_ydc_c"))
c::
  VimLineCopy := 1
  if WinActive("ahk_group DoubleHome"){
    Send, {Home}
  }
  Send, {Home}+{End}
  if not WinActive("ahk_group VimLBSelectGroup"){
    VimMove("l")
  }else{
    VimMove("")
  }
Return

#If WinActive("ahk_group " . VimGroupName) and (isCurrentVimMode("Vim_Normal"))
; X
x::Send, {Delete}
+x::Send, {BS}

; Paste
#If WinActive("ahk_group " . VimGroupName) and (isCurrentVimMode("Vim_Normal"))
p::
  ;i:=0
  ;;Send, {p Up}
  ;Loop {
  ;  if !GetKeyState("p", "P"){
  ;    break
  ;  }
  ;  if(VimLineCopy == 1){
  ;    Send, {End}{Enter}^v{BS}{Home}
  ;  }else{
  ;    Send, {Right}
  ;    Send, ^v
  ;    ;Sleep, 1000
  ;    Send, ^{Left}
  ;  }
  ;  ;TrayTip,i,%i%,
  ;  if(i == 0){
  ;    Sleep, 500
  ;  }else if(i > 100){
  ;    Msgbox, , Vim Ahk, Stop at 100!!!
  ;    break
  ;  }else{
  ;    Sleep, 0
  ;  }
  ;  i+=1
  ;  break
  ;}
  if(VimLineCopy == 1){
    Send, {End}{Enter}^v{BS}{Home}
  }else{
    Send, {Right}
    Send, ^v
    ;Sleep, 1000
    Send, {Left}
    ;;Send, ^{Left}
  }
  KeyWait, p ; To avoid repeat, somehow it calls <C-p>, print...
Return

+p::
  if(VimLineCopy == 1){
    Send, {Up}{End}{Enter}^v{BS}{Home}
  }else{
    Send, ^v
    ;Send,^{Left}
  }
  KeyWait, p
Return
; }}} Copy/Cut/Paste (ydcxp)

; Vim visual mode {{{

; Visual Char/Block/Line
#If WinActive("ahk_group " . VimGroupName) and (isCurrentVimMode("Vim_Normal"))
v::VimSetMode("Vim_VisualChar")
^v::
  Send, ^b
  VimSetMode("Vim_VisualChar")
Return

+v::
  VimSetMode("Vim_VisualLineFirst")
  Send, {Home}+{Down}
Return

; ydc
#If WinActive("ahk_group " . VimGroupName) and (strIsInCurrentVimMode("Visual"))
y::
  Clipboard :=
  Send, ^c
  Send, {Right}
  Send, {Left}
  ClipWait, 1
  if(strIsInCurrentVimMode("Line")){
    VimSetMode("Vim_Normal", 0, 0, 1)
  }else{
    VimSetMode("Vim_Normal", 0, 0, 0)
  }
Return

d::
  Clipboard :=
  Send, ^x
  ClipWait, 1
  if(strIsInCurrentVimMode("Line")){
    VimSetMode("Vim_Normal", 0, 0, 1)
  }else{
    VimSetMode("Vim_Normal", 0, 0, 0)
  }
Return

x::
  Clipboard :=
  Send, ^x
  ClipWait, 1
  if(strIsInCurrentVimMode("Line")){
    VimSetMode("Vim_Normal", 0, 0, 1)
  }else{
    VimSetMode("Vim_Normal", 0, 0, 0)
  }
Return

c::
  Clipboard :=
  Send, ^x
  ClipWait, 1
  if(strIsInCurrentVimMode("Line")){
    VimSetMode("Insert", 0, 0, 1)
  }else{
    VimSetMode("Insert", 0, 0, 0)
  }
Return

; MS Office lets you interact with "the ribbon" (toolbar) via keyboard by 
; pressing and releasing the Alt key, then pressing additional shortcut keys
; that appear on the ribbon.
$Alt::
    Send {Alt}
    VimSetMode("Insert")
Return

*::
  bak := ClipboardAll
  Clipboard :=
  Send, ^c
  ClipWait, 1
  Send, ^f
  Send, ^v!f
  clipboard := bak
  VimSetMode("Vim_Normal")
Return
; }}} Vim visual mode

; Search {{{
#If WinActive("ahk_group " . VimGroupName) and (isCurrentVimMode("Vim_Normal"))
/::
  Send, ^f
  VimSetMode("Insert")
Return

*::
  bak := ClipboardAll
  Clipboard=
  Send, ^{Left}+^{Right}^c
  ClipWait, 1
  Send, ^f
  Send, ^v!f
  clipboard := bak
  VimSetMode("Insert")
Return

n::Send, {F3}
+n::Send, +{F3}
; }}} Search

; Vim comamnd mode {{{
#If WinActive("ahk_group " . VimGroupName) and (isCurrentVimMode("Vim_Normal"))
:::VimSetMode("Command") ;(:)
`;::VimSetMode("Command") ;(;)
#If WinActive("ahk_group " . VimGroupName) and (isCurrentVimMode("Command"))
w::VimSetMode("Command_w")
q::VimSetMode("Command_q")
h::
  Send, {F1}
  VimSetMode("Vim_Normal")
Return

#If WinActive("ahk_group " . VimGroupName) and (isCurrentVimMode("Command_w"))
Return::
  Send, ^s
  VimSetMode("Vim_Normal")
Return

q::
  Send, ^s
  Send, !{F4}
  VimSetMode("Insert")
Return

Space::
  Send, !fa
  VimSetMode("Insert")
Return

#If WinActive("ahk_group " . VimGroupName) and (isCurrentVimMode("Command_q"))
Return::
  Send, !{F4}
  VimSetMode("Insert")
Return
; }}} Vim command mode

; Disable other keys {{{
#If WinActive("ahk_group " . VimGroupName) and (strIsInCurrentVimMode("ydc") or strIsInCurrentVimMode("Command") or (isCurrentVimMode("Z")))
*a::
*b::
*c::
*d::
*e::
*f::
*g::
*h::
*i::
*j::
*k::
*l::
*m::
*n::
*o::
*p::
*q::
*r::
*s::
*t::
*u::
*v::
*w::
*x::
*y::
*z::
0::
1::
2::
3::
4::
5::
6::
7::
8::
9::
`::
~::
!::
@::
#::
$::
%::
^::
&::
*::
(::
)::
-::
_::
=::
+::
[::
{::
]::
}::
\::
|::
:::
`;::
'::
"::
,::
<::
.::
>::
Space::
  VimSetMode("Vim_Normal")
Return

#If WinActive("ahk_group " . VimGroupName) and strIsInCurrentVimMode("Vim_") and (VimDisableUnused == 2)
a::
b::
c::
d::
e::
f::
g::
h::
i::
j::
k::
l::
m::
n::
o::
p::
q::
r::
s::
t::
u::
v::
w::
x::
y::
z::
+a::
+b::
+c::
+d::
+e::
+f::
+g::
+h::
+i::
+j::
+k::
+l::
+m::
+n::
+o::
+p::
+q::
+r::
+s::
+t::
+u::
+v::
+w::
+x::
+y::
+z::
0::
1::
2::
3::
4::
5::
6::
7::
8::
9::
`::
~::
!::
@::
#::
$::
%::
^::
&::
*::
(::
)::
-::
_::
=::
+::
[::
{::
]::
}::
\::
|::
:::
`;::
'::
"::
,::
<::
.::
>::
Space::
Return

#If WinActive("ahk_group " . VimGroupName) and strIsInCurrentVimMode("Vim_") and (VimDisableUnused == 3)
*a::
*b::
*c::
*d::
*e::
*f::
*g::
*h::
*i::
*j::
*k::
*l::
*m::
*n::
*o::
*p::
*q::
*r::
*s::
*t::
*u::
*v::
*w::
*x::
*y::
*z::
0::
1::
2::
3::
4::
5::
6::
7::
8::
9::
`::
~::
!::
@::
#::
$::
%::
^::
&::
*::
(::
)::
-::
_::
=::
+::
[::
{::
]::
}::
\::
|::
:::
`;::
'::
"::
,::
<::
.::
>::
Space::
Return
; }}}
; }}} Vim Mode

; Reset the condition
#If

; vim: foldmethod=marker
; vim: foldmarker={{{,}}}
; vim: ts=2:sw=2:sts=2:et
