#include %A_ScriptDir%\settings.ahk
#include %A_ScriptDir%\settingsUI.ahk
#include %A_ScriptDir%\IME.ahk
#include %A_ScriptDir%\vim_ahk_library.ahk
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
Esc:: ; Just send Esc at converting, long press for normal Esc.
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

^[:: ; Go to Normal mode (for vim) with IME off even at converting.
  KeyWait, [, T0.5
  if(ErrorLevel){ ; long press to Esc
    Send, {Esc}
    Return
  }
  checkIMENormal()
Return

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

#If WinActive("ahk_group " . VimGroupName) and (InStr(VimMode, "Insert"))
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
  if (VimJJ == 1){
    if (VimJK == 1){
      goNorm := expectSingleLetterFromGroup("jk")
    }else{
      gonorm := expectsingleletterfromgroup("j")
    }
  }else if (vimJK == 1) {
    goNorm := expectSingleLetterFromGroup("k")
  }else{
    goNorm := False
  }
  if goNorm {
    SendInput, {BackSpace 2}
    VimSetMode("Vim_Normal")
  }
Return
; }}}

; Enter vim insert mode (Exit vim normal mode) {{{
#If WinActive("ahk_group " . VimGroupName) && (VimMode == "Vim_Normal")
i::VimSetMode("Insert")

; MS Office lets you interact with "the ribbon" (toolbar) via keyboard by 
; pressing and releaseing the Alt key, then pressing additional shortcut keys
; that appear on the ribbon.
$Alt::
    Send {Alt}
    VimSetMode("Insert")
Return

+i::
  Send, {Home}
  Sleep, 200
  VimSetMode("Insert")
Return

a::
  Send, {Right}
  VimSetMode("Insert")
Return

+a::
  Send, {End}
  Sleep, 200
  VimSetMode("Insert")
Return

o::
  Send,{End}{Enter}
  VimSetMode("Insert")
Return

+o::
  Send, {Up}{End}{Enter}
  Sleep, 200
  VimSetMode("Insert")
Return
; }}}

; Repeat {{{
#If WinActive("ahk_group " . VimGroupName) and (InStr(VimMode,"Vim_"))
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

#If WinActive("ahk_group " . VimGroupName) and (InStr(VimMode,"Vim_")) and (Vim_n > 0)
0:: ; 0 is used as {Home} for Vim_n=0
  n_repeat := Vim_n*10 + A_ThisHotkey
  VimSetMode("", 0, n_repeat)
Return
; }}}

; Normal Mode Basic {{{
#If WinActive("ahk_group " . VimGroupName) and (VimMode == "Vim_Normal")
; Undo/Redo
u::Send,^z
^r::Send,^y

; Combine lines
+j::Send, {Down}{Home}{BS}{Space}{Left}

; Change case
~::
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
Return

+z::VimSetMode("Z")
#If WinActive("ahk_group " . VimGroupName) and (VimMode == "Z")
+z::
  Send, ^s
  Send, !{F4}
  VimSetMode("Vim_Normal")
Return

+q::
  Send, !{F4}
  VimSetMode("Vim_Normal")
Return

#If WinActive("ahk_group " . VimGroupName) and (VimMode == "Vim_Normal")
Space::Send, {Right}

; period
.::Send, +^{Right}{BS}^v
; }}}

; Replace {{{
#If WinActive("ahk_group " . VimGroupName) and (VimMode == "Vim_Normal")
r::VimSetMode("r_once")
+r::VimSetMode("r_repeat")

#If WinActive("ahk_group " . VimGroupName) and (VimMode == "r_once")
~a::
~b::
~c::
~d::
~e::
~f::
~g::
~h::
~i::
~j::
~k::
~l::
~m::
~n::
~o::
~p::
~q::
~r::
~s::
~t::
~u::
~v::
~w::
~x::
~y::
~z::
~0::
~1::
~2::
~3::
~4::
~5::
~6::
~7::
~8::
~9::
~`::
~~::
~!::
~@::
~#::
~$::
~%::
~^::
~&::
~*::
~(::
~)::
~-::
~_::
~=::
~+::
~[::
~{::
~]::
~}::
~\::
~|::
~;::
~'::
~"::
~,::
~<::
~.::
~>::
~Space::
  Send, {Del}
  VimSetMode("Vim_Normal")
Return

::: ; ":" can't be used with "~"?
  Send, {:}{Del}
  VimSetMode("Vim_Normal")
Return

#If WinActive("ahk_group " . VimGroupName) and (VimMode == "r_repeat")
~a::
~b::
~c::
~d::
~e::
~f::
~g::
~h::
~i::
~j::
~k::
~l::
~m::
~n::
~o::
~p::
~q::
~r::
~s::
~t::
~u::
~v::
~w::
~x::
~y::
~z::
~0::
~1::
~2::
~3::
~4::
~5::
~6::
~7::
~8::
~9::
~`::
~~::
~!::
~@::
~#::
~$::
~%::
~^::
~&::
~*::
~(::
~)::
~-::
~_::
~=::
~+::
~[::
~{::
~]::
~}::
~\::
~|::
~;::
~'::
~"::
~,::
~<::
~.::
~>::
~Space::
  Send, {Del}
Return

:::
  Send, {:}{Del}
Return
; }}}

; Move {{{
; g {{{
#If WinActive("ahk_group " . VimGroupName) and (InStr(VimMode,"Vim_")) and (not Vim_g)
g::VimSetMode("", 1)
; }}}

VimMove(key="", shift=0){
  global
  if(InStr(VimMode, "Visual") or InStr(VimMode, "ydc") or shift == 1){
    Send, {Shift Down}
  }
  ; Left/Right
  if(not InStr(VimMode, "Line")){
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
      Send, {End}^{Right}
    ; Words
    }else if(key == "w"){
      Send, ^{Right}
    }else if(key == "b"){
      Send, ^{Left}
    }
  }
  ; Up/Down
  if(VimMode == "Vim_VisualLineFirst") and (key == "k" or key == "^u" or key == "^b" or key == "g"){
    Send, {Shift Up}{End}{Home}{Shift Down}{Up}
    VimSetMode("Vim_VisualLine")
  }
  if(VimMode == "Vim_VisualLineFirst") and (key == "j" or key == "^d" or key == "^f" or key == "+g"){
    VimSetMode("Vim_VisualLine")
  }
  if(InStr(VimMode, "Vim_ydc")) and (key == "k" or key == "^u" or key == "^b" or key == "g"){
    VimLineCopy := 1
    Send,{Shift Up}{Home}{Down}{Shift Down}{Up}
  }
  if(InStr(VimMode,"Vim_ydc")) and (key == "j" or key == "^d" or key == "^f" or key == "+g"){
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

  if(VimMode == "Vim_ydc_y"){
    Clipboard :=
    Send, ^c
    ClipWait, 1
    VimSetMode("Vim_Normal")
  }else if(VimMode == "Vim_ydc_d"){
    Clipboard :=
    Send, ^x
    ClipWait, 1
    VimSetMode("Vim_Normal")
  }else if(VimMode == ="Vim_ydc_c"){
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
#If WinActive("ahk_group " . VimGroupName) and (InStr(VimMode,"Vim_"))
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
#If WinActive("ahk_group " . VimGroupName) and (InStr(VimMode, "Vim_")) and (Vim_g)
g::VimMove("g")
; }}} Move

; Copy/Cut/Paste (ydcxp){{{
; YDC
#If WinActive("ahk_group " . VimGroupName) and (VimMode == "Vim_Normal")
y::VimSetMode("Vim_ydc_y", 0, -1, 0)
d::VimSetMode("Vim_ydc_d", 0, -1, 0)
c::VimSetMode("Vim_ydc_c", 0, -1, 0)
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

#If WinActive("ahk_group " . VimGroupName) and (VimMode == "Vim_ydc_y")
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

#If WinActive("ahk_group " . VimGroupName) and (VimMode == "Vim_ydc_d")
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

#If WinActive("ahk_group " . VimGroupName) and (VimMode == "Vim_ydc_c")
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

#If WinActive("ahk_group " . VimGroupName) and (VimMode == "Vim_Normal")
; X
x::Send, {Delete}
+x::Send, {BS}

; Paste
#If WinActive("ahk_group " . VimGroupName) and (VimMode == "Vim_Normal")
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
#If WinActive("ahk_group " . VimGroupName) and (VimMode == "Vim_Normal")
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
#If WinActive("ahk_group " . VimGroupName) and (InStr(VimMode, "Visual"))
y::
  Clipboard :=
  Send, ^c
  Send, {Right}
  Send, {Left}
  ClipWait, 1
  if(InStr(VimMode, "Line")){
    VimSetMode("Vim_Normal", 0, 0, 1)
  }else{
    VimSetMode("Vim_Normal", 0, 0, 0)
  }
Return

d::
  Clipboard :=
  Send, ^x
  ClipWait, 1
  if(InStr(VimMode,"Line")){
    VimSetMode("Vim_Normal", 0, 0, 1)
  }else{
    VimSetMode("Vim_Normal", 0, 0, 0)
  }
Return

x::
  Clipboard :=
  Send, ^x
  ClipWait, 1
  if(InStr(VimMode, "Line")){
    VimSetMode("Vim_Normal", 0, 0, 1)
  }else{
    VimSetMode("Vim_Normal", 0, 0, 0)
  }
Return

c::
  Clipboard :=
  Send, ^x
  ClipWait, 1
  if(InStr(VimMode, "Line")){
    VimSetMode("Insert", 0, 0, 1)
  }else{
    VimSetMode("Insert", 0, 0, 0)
  }
Return

; MS Office lets you interact with "the ribbon" (toolbar) via keyboard by 
; pressing and releaseing the Alt key, then pressing additional shortcut keys
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
#If WinActive("ahk_group " . VimGroupName) and (VimMode == "Vim_Normal")
/::
  Send, ^f
  VimSetMode("Inseret")
Return

*::
  bak := ClipboardAll
  Clipboard=
  Send, ^{Left}+^{Right}^c
  ClipWait, 1
  Send, ^f
  Send, ^v!f
  clipboard := bak
  VimSetMode("Inseret")
Return

n::Send, {F3}
+n::Send, +{F3}
; }}} Search

; Vim comamnd mode {{{
#If WinActive("ahk_group " . VimGroupName) and (VimMode == "Vim_Normal")
:::VimSetMode("Command") ;(:)
`;::VimSetMode("Command") ;(;)
#If WinActive("ahk_group " . VimGroupName) and (VimMode == "Command")
w::VimSetMode("Command_w")
q::VimSetMode("Command_q")
h::
  Send, {F1}
  VimSetMode("Vim_Normal")
Return

#If WinActive("ahk_group " . VimGroupName) and (VimMode == "Command_w")
Return::
  Send, ^s
  VimSetMode("Insert")
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

#If WinActive("ahk_group " . VimGroupName) and (VimMode == "Command_q")
Return::
  Send, !{F4}
  VimSetMode("Insert")
Return
; }}} Vim command mode

; Disable other keys {{{
#If WinActive("ahk_group " . VimGroupName) and (InStr(VimMode, "ydc") or InStr(VimMode, "Command") or (VimMode == "Z"))
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

#If WinActive("ahk_group " . VimGroupName) and InStr(VimMode,"Vim_") and (VimDisableUnused == 2)
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

#If WinActive("ahk_group " . VimGroupName) and InStr(VimMode,"Vim_") and (VimDisableUnused == 3)
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

; vim: foldmethod=marker
; vim: foldmarker={{{,}}}
; vim: ts=2:sw=2:sts=2:et
