class VimGui{
  __New(title){
    this.Hwnd := 0
    this.Title := title
  }

  ShowGui(){
    if(this.hwnd == 0){
      Gui, New, +HwndGuiHwnd
      this.Hwnd := GuiHwnd
      this.MakeGui()
      Gui, % this.Hwnd ":Show", , % this.Title
      OnMessage(0x112, ObjBindMethod(this, "OnClose"))
      OnMessage(0x100, ObjBindMethod(this, "OnEscape"))
      OnMessage(0x200, ObjBindMethod(this, "OnMouseMove"))
    }
    this.UpdateGui()
    Gui, % this.Hwnd . ":Show", , % this.Title
    Return
  }

  MakeGui(){
    Gui, % this.Hwnd ":Add", Button, +HwndOKHwnd X200 W100 Default, &OK
    this.OKHwnd := OKHwnd
    ok := ObjBindMethod(this, "OK")
    GuiControl, +G, % OKHwnd, % ok
  }

  UpdateGui(){
  }

  Hide(){
    ToolTip
    Gui, % this.Hwnd ":Hide"
  }

  OK(){
    this.Hide()
  }

  OnClose(wp, lp, msg, hwnd){
    if(hwnd == this.Hwnd && wp == 0xF060){
      this.Hide()
    }
  }

  OnEscape(wp, lp, msg, hwnd){
    if((hwnd == this.Hwnd || hwnd == this.OKHwnd) && wp == 27){
      this.Hide()
    }
  }

  OnMouseMove(wp, lp, msg, hwnd){
  }
}
