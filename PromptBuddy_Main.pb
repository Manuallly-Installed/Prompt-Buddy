;- Top
; -----------------------------------------------------------------------------
;           Name:
;    Description:
;         Author:
;           Date: 2026-09-04
;        Version:
;     PB-Version:
;             OS:
;         Credit:
;          Forum:
;     Created by: IceDesign
; -----------------------------------------------------------------------------

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
CompilerEndIf

;- Enumerations
Enumeration Window
  #Window_main
  #Window_history
EndEnumeration

Enumeration MenuToolStatusBar
  #MainMenu
EndEnumeration

Enumeration MenuItems
  #Menu_New
  #Menu_Open
  #Menu_Save
  #Menu_Quit
  #Menu_About
  #Menu_AddPrompt
  #Menu_AddEnvironment
  #Menu_EditPrompt
  #Menu_EditScratchPad
  #Menu_SearchPrompt
  #Menu_SearchScratchPad
  #Menu_SearchEnvironment
EndEnumeration

Enumeration Gadgets
  #BackButton_Fleet
  #BackButton_Slack
  #Check_Stay_on_top
  #Edit_Prompt
  #Edit_ScratchPad
  #ForwardButton_Fleet
  #ForwardButton_Slack
  #HomeButton_Fleet
  #HomeButton_Slack
  #Panel_PromptScratch
  #Settings_Fleet
  #Settings_Slack
  #String_Fleet
  #String_Slack
  #Txt_Prompt
  #Txt_ScratchPad
  #WebGadget_Fleet
  #WebGadget_Slack
  #ListIcon_history
  #Button_History_Close
EndEnumeration

Enumeration Images
  #Imag_Settings
  #Imag_Home
  #Imag_rightarrow_24
  #Imag_leftarrow_24
EndEnumeration

Enumeration Fonts
  #Font_Default_12_B
  #Font_Default_12
EndEnumeration

;- Load Images
UsePNGImageDecoder()

CatchImage(#Imag_Settings, ?Imag_Settings)
CatchImage(#Imag_Home, ?Imag_Home)
CatchImage(#Imag_rightarrow_24, ?Imag_rightarrow_24)
CatchImage(#Imag_leftarrow_24, ?Imag_leftarrow_24)

;- Load Fonts
LoadFont(#Font_Default_12_B, "", 12, #PB_Font_Bold)
LoadFont(#Font_Default_12, "", 12)

Global Quit

;- Website History
Structure WebHistoryEntry
  Website.s
  Date.s
  Time.s
EndStructure

Structure WebHistoryHitTest
  pt.POINT
  flags.l
  iItem.l
  iSubItem.l
EndStructure

CompilerIf Not Defined(LVM_FIRST, #PB_Constant)
  #LVM_FIRST = $1000
CompilerEndIf
CompilerIf Not Defined(LVM_HITTEST, #PB_Constant)
  #LVM_HITTEST = #LVM_FIRST + 18
CompilerEndIf
CompilerIf Not Defined(VK_ENTER, #PB_Constant)
  #VK_ENTER = 13
CompilerEndIf

Global NewList History_Fleet.WebHistoryEntry()
Global NewList History_Slack.WebHistoryEntry()

Global LastHistory_Url.s
Global LastHistory_Time.q
Global HomePage_Fleet.s = "https://fleetai.com/"
Global HomePage_Slack.s = "https://app.slack.com/client/"
Global HistoryTarget.i
Global HistoryWindow_Open.i = #False

;- Declare
Declare Event_Panel_PromptScratch()
Declare Event_Check_Stay_on_top()
Declare Event_Edit_Prompt()
Declare Event_Edit_ScratchPad()
Declare Event_BackButton_Fleet()
Declare Event_ForwardButton_Fleet()
Declare Event_HomeButton_Fleet()
Declare Event_Settings_Fleet()
Declare Event_String_Fleet()
Declare Event_WebGadget_Fleet()
Declare Event_BackButton_Slack()
Declare Event_ForwardButton_Slack()
Declare Event_HomeButton_Slack()
Declare Event_Settings_Slack()
Declare Event_String_Slack()
Declare Event_WebGadget_Slack()
Declare Event_Menu_Window_main()
Declare Resize_Window_main()
Declare Event_Close_Window_main()
Declare Menu_Window_main()
Declare Open_Window_main(X = 0, Y = 0, Width = 1000, Height = 720)
Declare.s Normalize_Url(Url.s)
Declare Add_To_History(List History.WebHistoryEntry(), Website.s)
Declare Refresh_WebHistory_List()
Declare Sync_Web_Browsers()
Declare Navigate_Fleet(Url.s)
Declare Navigate_Slack(Url.s)
Declare Event_ListIcon_history()
Declare Event_Button_History_Close()
Declare Event_Close_History()
Declare Open_History_Window(Target)
Declare Handle_Enter_Navigation()

XIncludeFile "ObjectTheme.pbi"
UseModule ObjectTheme
XIncludeFile "ResizeHelper.pbi"

Procedure Event_Panel_PromptScratch()
  Select EventType()
    Case #PB_EventType_Change
    Case #PB_EventType_Resize
  EndSelect
EndProcedure

Procedure Event_Check_Stay_on_top()
  MessageRequester("Information", "CheckBox Name : #Check_Stay_on_top" +#CRLF$+#CRLF$+ "State : " + GetGadgetState(EventGadget()))
EndProcedure

Procedure Event_Edit_Prompt()
  Select EventType()
    Case #PB_EventType_Focus
    Case #PB_EventType_Change
    Case #PB_EventType_LostFocus
  EndSelect
EndProcedure

Procedure Event_Edit_ScratchPad()
  Select EventType()
    Case #PB_EventType_Focus
    Case #PB_EventType_Change
    Case #PB_EventType_LostFocus
  EndSelect
EndProcedure

Procedure Event_BackButton_Fleet()
  SetGadgetState(#WebGadget_Fleet, #PB_Web_Back)
EndProcedure

Procedure Event_ForwardButton_Fleet()
  SetGadgetState(#WebGadget_Fleet, #PB_Web_Forward)
EndProcedure

Procedure Event_HomeButton_Fleet()
  Navigate_Fleet(HomePage_Fleet)
EndProcedure

Procedure Event_Settings_Fleet()
  Open_History_Window(1)
EndProcedure

Procedure Event_String_Fleet()
  Select EventType()
    Case #PB_EventType_Focus
    Case #PB_EventType_Change
    Case #PB_EventType_LostFocus
  EndSelect
EndProcedure

Procedure Event_WebGadget_Fleet()
  Select EventType()
    Case #PB_EventType_TitleChange
      Sync_Web_Browsers()
    Case #PB_EventType_StatusChange
    Case #PB_EventType_DownloadStart
    Case #PB_EventType_DownloadProgress
    Case #PB_EventType_DownloadEnd
    Case #PB_EventType_PopupWindow
    Case #PB_EventType_PopupMenu
  EndSelect
EndProcedure

Procedure Event_BackButton_Slack()
  SetGadgetState(#WebGadget_Slack, #PB_Web_Back)
EndProcedure

Procedure Event_ForwardButton_Slack()
  SetGadgetState(#WebGadget_Slack, #PB_Web_Forward)
EndProcedure

Procedure Event_HomeButton_Slack()
  Navigate_Slack(HomePage_Slack)
EndProcedure

Procedure Event_Settings_Slack()
  Open_History_Window(2)
EndProcedure

Procedure Event_String_Slack()
  Select EventType()
    Case #PB_EventType_Focus
    Case #PB_EventType_Change
    Case #PB_EventType_LostFocus
  EndSelect
EndProcedure

Procedure Event_WebGadget_Slack()
  Select EventType()
    Case #PB_EventType_TitleChange
      Sync_Web_Browsers()
    Case #PB_EventType_StatusChange
    Case #PB_EventType_DownloadStart
    Case #PB_EventType_DownloadProgress
    Case #PB_EventType_DownloadEnd
    Case #PB_EventType_PopupWindow
    Case #PB_EventType_PopupMenu
  EndSelect
EndProcedure

;- Browser Navigation and History
Procedure.s Normalize_Url(Url.s)
  Url = Trim(Url)
  If Url <> "" And FindString(Url, "://", 1) = 0
    Url = "https://" + Url
  EndIf
  ProcedureReturn Url
EndProcedure

Procedure Handle_Enter_Navigation()
  Static LastEnterState.i
  Protected EnterState.i
  EnterState = GetAsyncKeyState_(#VK_ENTER) & $8000
  If EnterState And LastEnterState = #False
    If GetActiveGadget() = #String_Fleet
      Navigate_Fleet(Normalize_Url(GetGadgetText(#String_Fleet)))
    ElseIf GetActiveGadget() = #String_Slack
      Navigate_Slack(Normalize_Url(GetGadgetText(#String_Slack)))
    EndIf
  EndIf
  LastEnterState = EnterState
EndProcedure

Procedure Add_To_History(List History.WebHistoryEntry(), Website.s)
  Protected Now.q = Date()
  If Website <> "" And Website = LastHistory_Url And Now - LastHistory_Time < 3
    ProcedureReturn
  EndIf
  LastHistory_Url = Website
  LastHistory_Time = Now
  AddElement(History())
  History()\Website = Website
  History()\Date = FormatDate("%yyyy/%mm/%dd", Now)
  History()\Time = FormatDate("%hh:%ii:%ss", Now)
  Refresh_WebHistory_List()
EndProcedure

Procedure Refresh_WebHistory_List()
  If HistoryWindow_Open = #False
    ProcedureReturn
  EndIf
  ClearGadgetItems(#ListIcon_history)
  If HistoryTarget = 1
    ForEach History_Fleet()
      AddGadgetItem(#ListIcon_history, -1, History_Fleet()\Website + Chr(10) + History_Fleet()\Date + Chr(10) + History_Fleet()\Time)
    Next
  ElseIf HistoryTarget = 2
    ForEach History_Slack()
      AddGadgetItem(#ListIcon_history, -1, History_Slack()\Website + Chr(10) + History_Slack()\Date + Chr(10) + History_Slack()\Time)
    Next
  EndIf
EndProcedure

Procedure Sync_Web_Browsers()
  Protected Url.s
  If GetGadgetAttribute(#WebGadget_Fleet, #PB_Web_Busy) = 0
    Url = GetGadgetText(#WebGadget_Fleet)
    If Url <> "" And Url <> GetGadgetText(#String_Fleet) And FindString(Url, "about:", 1) = 0 And GetActiveGadget() <> #String_Fleet
      SetGadgetText(#String_Fleet, Url)
      Add_To_History(History_Fleet(), Url)
    EndIf
  EndIf
  If GetGadgetAttribute(#WebGadget_Slack, #PB_Web_Busy) = 0
    Url = GetGadgetText(#WebGadget_Slack)
    If Url <> "" And Url <> GetGadgetText(#String_Slack) And FindString(Url, "about:", 1) = 0 And GetActiveGadget() <> #String_Slack
      SetGadgetText(#String_Slack, Url)
      Add_To_History(History_Slack(), Url)
    EndIf
  EndIf
EndProcedure

Procedure Navigate_Fleet(Url.s)
  If Url = ""
    ProcedureReturn
  EndIf
  SetGadgetText(#String_Fleet, Url)
  SetGadgetText(#WebGadget_Fleet, Url)
  Add_To_History(History_Fleet(), Url)
  SetActiveGadget(#WebGadget_Fleet)
EndProcedure

Procedure Navigate_Slack(Url.s)
  If Url = ""
    ProcedureReturn
  EndIf
  SetGadgetText(#String_Slack, Url)
  SetGadgetText(#WebGadget_Slack, Url)
  Add_To_History(History_Slack(), Url)
  SetActiveGadget(#WebGadget_Slack)
EndProcedure

Procedure Event_ListIcon_history()
  Select EventType()
    Case #PB_EventType_LeftClick, #PB_EventType_LeftDoubleClick
      Protected pt.POINT
      Protected hti.WebHistoryHitTest
      Protected MsgPos.i = GetMessagePos_()
      Protected Url.s
      pt\x = MsgPos & $FFFF
      pt\y = (MsgPos >> 16) & $FFFF
      ScreenToClient_(GadgetID(#ListIcon_history), @pt)
      SendMessage_(GadgetID(#ListIcon_history), #LVM_HITTEST, 0, @hti)
      If hti\iItem >= 0 And hti\iSubItem = 0
        Url = GetGadgetItemText(#ListIcon_history, hti\iItem, 0)
        If Url <> ""
          If HistoryTarget = 1
            SetGadgetText(#String_Fleet, Url)
            SetGadgetText(#WebGadget_Fleet, Url)
            Add_To_History(History_Fleet(), Url)
          ElseIf HistoryTarget = 2
            SetGadgetText(#String_Slack, Url)
            SetGadgetText(#WebGadget_Slack, Url)
            Add_To_History(History_Slack(), Url)
          EndIf
          SetWindowState(#Window_main, #PB_Window_Normal)
          SetActiveWindow(#Window_main)
        EndIf
      EndIf
  EndSelect
EndProcedure

Procedure Event_Button_History_Close()
  HideWindow(#Window_history, #True)
EndProcedure

Procedure Event_Close_History()
  HideWindow(#Window_history, #True)
EndProcedure

Procedure Open_History_Window(Target)
  HistoryTarget = Target
  If HistoryWindow_Open = #False
    If OpenWindow(#Window_history, 0, 0, 660, 460, "Website History", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_WindowCentered)
      ListIconGadget(#ListIcon_history, 10, 10, 640, 400, "website", 340, #PB_ListIcon_GridLines | #PB_ListIcon_FullRowSelect)
      AddGadgetColumn(#ListIcon_history, 1, "Date", 150)
      AddGadgetColumn(#ListIcon_history, 2, "Time", 120)
      ButtonGadget(#Button_History_Close, 510, 420, 140, 30, "Close")
      BindGadgetEvent(#ListIcon_history, @Event_ListIcon_history(), #Window_history)
      BindGadgetEvent(#Button_History_Close, @Event_Button_History_Close(), #Window_history)
      BindEvent(#PB_Event_CloseWindow, @Event_Close_History(), #Window_history)
      HistoryWindow_Open = #True
    EndIf
  EndIf
  If HistoryTarget = 1
    SetWindowTitle(#Window_history, "Website History - Fleetai")
  Else
    SetWindowTitle(#Window_history, "Website History - Slack")
  EndIf
  HideWindow(#Window_history, #False)
  Refresh_WebHistory_List()
  SetActiveWindow(#Window_history)
EndProcedure

Procedure Event_Menu_Window_main()
  Select EventMenu()
    Case #Menu_Quit
      Quit = #True
    Case #Menu_AddPrompt
    Case #Menu_AddEnvironment
    Case #Menu_EditPrompt
    Case #Menu_EditScratchPad
    Case #Menu_SearchPrompt
    Case #Menu_SearchScratchPad
    Case #Menu_SearchEnvironment
      
    Default
      MessageRequester("Information", "ToolBar or Menu ID : " + Str(EventMenu()) +#CRLF$+#CRLF$+ "Text : " + GetMenuItemText(#MainMenu, EventMenu()), 0)
  EndSelect
EndProcedure

Procedure Resize_Window_main()
  Static MenuHeight
  Protected Window_main_WidthIni = 1000, Window_main_HeightIni = 720
  Protected Panel_PromptScratch_WidthIni = 992, Panel_PromptScratch_HeightIni = 671   ; #PB_Panel_ItemWidth(Height) Attribute
  Protected ScaleX.f, ScaleY.f
  If MenuHeight = 0
    MenuHeight = MenuHeight()
  EndIf
  Window_main_HeightIni - MenuHeight

  ScaleX = WindowWidth(#Window_main) / Window_main_WidthIni : ScaleY = (WindowHeight(#Window_main) - MenuHeight) / Window_main_HeightIni
  ResizeGadget(#Panel_PromptScratch, ScaleX * 0, ScaleY * 0, ScaleX * 1000, ScaleY * 700)
  ScaleX = GetGadgetAttribute(#Panel_PromptScratch, #PB_Panel_ItemWidth) / Panel_PromptScratch_WidthIni : ScaleY = GetGadgetAttribute(#Panel_PromptScratch, #PB_Panel_ItemHeight) / Panel_PromptScratch_HeightIni
  ResizeGadget(#Txt_Prompt, ScaleX * 0, ScaleY * 10, ScaleX * 173, ScaleY * 20)
  ResizeGadget(#Check_Stay_on_top, ScaleX * 700, ScaleY * 10, ScaleX * 271, ScaleY * 20)
  ResizeGadget(#Edit_Prompt, ScaleX * 0, ScaleY * 34, ScaleX * 992, ScaleY * 303)
  ResizeGadget(#Txt_ScratchPad, ScaleX * 0, ScaleY * 351, ScaleX * 355, ScaleY * 20)
  ResizeGadget(#Edit_ScratchPad, ScaleX * 0, ScaleY * 375, ScaleX * 992, ScaleY * 260)
  ResizeGadget(#BackButton_Fleet, ScaleX * 3, ScaleY * 0, ScaleX * 50, ScaleY * 28)
  ResizeGadgetImage(#BackButton_Fleet)
  ResizeGadget(#ForwardButton_Fleet, ScaleX * 63, ScaleY * 0, ScaleX * 50, ScaleY * 28)
  ResizeGadgetImage(#ForwardButton_Fleet)
  ResizeGadget(#HomeButton_Fleet, ScaleX * 124, ScaleY * 0, ScaleX * 50, ScaleY * 28)
  ResizeGadgetImage(#HomeButton_Fleet)
  ResizeGadget(#Settings_Fleet, ScaleX * 825, ScaleY * 0, ScaleX * 25, ScaleY * 28)
  ResizeGadgetImage(#Settings_Fleet)
  ResizeGadget(#String_Fleet, ScaleX * 184, ScaleY * 2, ScaleX * 545, ScaleY * 25)
  ResizeGadget(#WebGadget_Fleet, ScaleX * 0, ScaleY * 30, ScaleX * 992, ScaleY * 615)
  ResizeGadget(#BackButton_Slack, ScaleX * 3, ScaleY * 0, ScaleX * 50, ScaleY * 28)
  ResizeGadgetImage(#BackButton_Slack)
  ResizeGadget(#ForwardButton_Slack, ScaleX * 63, ScaleY * 0, ScaleX * 50, ScaleY * 28)
  ResizeGadgetImage(#ForwardButton_Slack)
  ResizeGadget(#HomeButton_Slack, ScaleX * 124, ScaleY * 0, ScaleX * 50, ScaleY * 28)
  ResizeGadgetImage(#HomeButton_Slack)
  ResizeGadget(#Settings_Slack, ScaleX * 825, ScaleY * 0, ScaleX * 25, ScaleY * 28)
  ResizeGadgetImage(#Settings_Slack)
  ResizeGadget(#String_Slack, ScaleX * 185, ScaleY * 2, ScaleX * 545, ScaleY * 25)
  ResizeGadget(#WebGadget_Slack, ScaleX * 0, ScaleY * 30, ScaleX * 992, ScaleY * 615)
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows : RedrawWindow_(WindowID(#Window_main), #Null, #Null, #RDW_INVALIDATE | #RDW_ERASE | #RDW_ALLCHILDREN | #RDW_UPDATENOW) : CompilerEndIf
EndProcedure

Procedure Event_Close_Window_main()
  Quit = #True
EndProcedure

Procedure Menu_Window_main()
  If CreateMenu(#MainMenu, WindowID(#Window_main))
    MenuTitle("File")
    MenuItem(#Menu_New, "New")
    MenuItem(#Menu_Open, "Open...")
    MenuItem(#Menu_Save, "Save")
    MenuBar()
    MenuItem(#Menu_Quit, "&Quit")
    MenuTitle("Edit")
    MenuItem(#Menu_EditPrompt, "Prompt")
    MenuItem(#Menu_EditScratchPad, "Scratch Pad")
    MenuTitle("Add")
    MenuItem(#Menu_AddPrompt, "Prompt")
    MenuItem(#Menu_AddEnvironment, "Environment")
    MenuTitle("Search")
    MenuItem(#Menu_SearchPrompt, "Prompt")
    MenuItem(#Menu_SearchScratchPad, "Scratch Pad")
    MenuItem(#Menu_SearchEnvironment, "Environment")
    MenuTitle("List")
    MenuTitle("Help")
    MenuItem(#Menu_About, "About")
  EndIf
EndProcedure

Procedure Open_Window_main(X = 0, Y = 0, Width = 1000, Height = 720)
  If OpenWindow(#Window_main, X, Y, Width, Height, "Prompt Buddy", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_ScreenCentered)

    Menu_Window_main()

    PanelGadget(#Panel_PromptScratch, 0, 0, 1000, 700)
      AddGadgetItem(#Panel_PromptScratch, -1, "Prompt / Scratch Pad")
      TextGadget(#Txt_Prompt, 0, 10, 173, 20, "Prompt:")
        SetGadgetFont(#Txt_Prompt, FontID(#Font_Default_12_B))
      CheckBoxGadget(#Check_Stay_on_top, 700, 10, 271, 20, "Stay on top")
      EditorGadget(#Edit_Prompt, 0, 34, 992, 303, #PB_Editor_WordWrap)
        AddGadgetItem(#Edit_Prompt, -1, "Editor Line 1")
        AddGadgetItem(#Edit_Prompt, -1, "Editor Line 2")
        AddGadgetItem(#Edit_Prompt, -1, "Editor Line 3")
        SetGadgetFont(#Edit_Prompt, FontID(#Font_Default_12))
      TextGadget(#Txt_ScratchPad, 0, 351, 355, 20, "Scratch Pad:")
        SetGadgetFont(#Txt_ScratchPad, FontID(#Font_Default_12_B))
      EditorGadget(#Edit_ScratchPad, 0, 375, 992, 260, #PB_Editor_WordWrap)
        AddGadgetItem(#Edit_ScratchPad, -1, "Editor Line 1")
        AddGadgetItem(#Edit_ScratchPad, -1, "Editor Line 2")
        AddGadgetItem(#Edit_ScratchPad, -1, "Editor Line 3")
        SetGadgetFont(#Edit_ScratchPad, FontID(#Font_Default_12))
      AddGadgetItem(#Panel_PromptScratch, -1, "Fleetai")
      ButtonImageGadget(#BackButton_Fleet, 3, 0, 50, 28, ImageID(#Imag_leftarrow_24))
      ButtonImageGadget(#ForwardButton_Fleet, 63, 0, 50, 28, ImageID(#Imag_rightarrow_24))
      ButtonImageGadget(#HomeButton_Fleet, 124, 0, 50, 28, ImageID(#Imag_Home))
      ButtonImageGadget(#Settings_Fleet, 825, 0, 25, 28, ImageID(#Imag_Settings))
      StringGadget(#String_Fleet, 184, 2, 545, 25, "http://fleetai.com")
        SetGadgetFont(#String_Fleet, FontID(#Font_Default_12))
      WebGadget(#WebGadget_Fleet, 0, 30, 992, 615, "https://fleetai.com/", #PB_Web_Edge)
      AddGadgetItem(#Panel_PromptScratch, -1, "Slack")
      ButtonImageGadget(#BackButton_Slack, 3, 0, 50, 28, ImageID(#Imag_leftarrow_24))
      ButtonImageGadget(#ForwardButton_Slack, 63, 0, 50, 28, ImageID(#Imag_rightarrow_24))
      ButtonImageGadget(#HomeButton_Slack, 124, 0, 50, 28, ImageID(#Imag_Home))
      ButtonImageGadget(#Settings_Slack, 825, 0, 25, 28, ImageID(#Imag_Settings))
      StringGadget(#String_Slack, 185, 2, 545, 25, "https://app.slack.com/client/")
      WebGadget(#WebGadget_Slack, 0, 30, 992, 615, "https://app.slack.com/client/", #PB_Web_Edge)
    CloseGadgetList()   ; #Panel_PromptScratch

    BindGadgetEvent(#Panel_PromptScratch, @Event_Panel_PromptScratch())
    BindGadgetEvent(#Check_Stay_on_top, @Event_Check_Stay_on_top())
    BindGadgetEvent(#Edit_Prompt, @Event_Edit_Prompt())
    BindGadgetEvent(#Edit_ScratchPad, @Event_Edit_ScratchPad())
    BindGadgetEvent(#BackButton_Fleet, @Event_BackButton_Fleet())
    BindGadgetEvent(#ForwardButton_Fleet, @Event_ForwardButton_Fleet())
    BindGadgetEvent(#HomeButton_Fleet, @Event_HomeButton_Fleet())
    BindGadgetEvent(#Settings_Fleet, @Event_Settings_Fleet())
    BindGadgetEvent(#String_Fleet, @Event_String_Fleet())
    BindGadgetEvent(#WebGadget_Fleet, @Event_WebGadget_Fleet())
    BindGadgetEvent(#BackButton_Slack, @Event_BackButton_Slack())
    BindGadgetEvent(#ForwardButton_Slack, @Event_ForwardButton_Slack())
    BindGadgetEvent(#HomeButton_Slack, @Event_HomeButton_Slack())
    BindGadgetEvent(#Settings_Slack, @Event_Settings_Slack())
    BindGadgetEvent(#String_Slack, @Event_String_Slack())
    BindGadgetEvent(#WebGadget_Slack, @Event_WebGadget_Slack())
    BindEvent(#PB_Event_Menu, @Event_Menu_Window_main(), #Window_main)
    BindEvent(#PB_Event_SizeWindow, @Resize_Window_main(), #Window_main)
    PostEvent(#PB_Event_SizeWindow, #Window_main, 0)
    BindEvent(#PB_Event_CloseWindow, @Event_Close_Window_main(), #Window_main)

    WindowBounds(#Window_main, 300, 600, #PB_Ignore, #PB_Ignore)
    ProcedureReturn #True
  EndIf
EndProcedure

CompilerIf #PB_Compiler_IsMainFile
;- Main Program
SetObjectTheme(#ObjectTheme_DarkBlue)

If Open_Window_main()

  ;IceKeepEventLoop
  Repeat
    WaitWindowEvent(100)
    Sync_Web_Browsers()
    Handle_Enter_Navigation()
  Until Quit
  ;EndIceKeepEventLoop
EndIf
CompilerEndIf

;- DataSection
DataSection
  Imag_Settings: : IncludeBinary "C:\Users\Brian\Documents\PureBasic Projects\Prompt Buddy\Settings.png"
  Imag_Home: : IncludeBinary "C:\Users\Brian\Documents\PureBasic Projects\Prompt Buddy\Home.png"
  Imag_rightarrow_24: : IncludeBinary "C:\Users\Brian\Documents\PureBasic Projects\Prompt Buddy\rightarrow_24.png"
  Imag_leftarrow_24: : IncludeBinary "C:\Users\Brian\Documents\PureBasic Projects\Prompt Buddy\leftarrow_24.png"
EndDataSection

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 371
; FirstLine = 351
; Folding = -----
; EnableXP
; DPIAware