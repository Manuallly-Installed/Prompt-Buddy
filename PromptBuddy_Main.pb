;- Top
; -----------------------------------------------------------------------------
;           Name: Prompt Buddy
;    Description: An easy to use program to write prompts. You can save and search them in an organized manner.
;         Author: Brian JaQuay
;           Date: 2026-08-30
;        Version: 1.0
;     PB-Version: 6.41 LTS
;             OS: Windows 10 64 bit
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
  #BackButton
  #BackButton_1
  #BtnImg_1
  #BtnImg_2
  #Check_Stay_on_top
  #Edit_Prompt
  #Edit_ScratchPad
  #Fleet
  #Forward
  #Forward_1
  #Panel_PromptScratch
  #Slack
  #String_Fleet
  #String_Slack
  #Txt_Prompt
  #Txt_ScratchPad
EndEnumeration

Enumeration Images
  #Imag_Home
  #Imag_rightarrow_24
  #Imag_leftarrow_24
EndEnumeration

Enumeration Fonts
  #Font_Default_10_B
  #Font_Default_10
EndEnumeration

;- Load Images
UsePNGImageDecoder()

CatchImage(#Imag_Home, ?Imag_Home)
CatchImage(#Imag_rightarrow_24, ?Imag_rightarrow_24)
CatchImage(#Imag_leftarrow_24, ?Imag_leftarrow_24)

;- Load Fonts
LoadFont(#Font_Default_10_B, "", 10, #PB_Font_Bold)
LoadFont(#Font_Default_10, "", 10)

Global Quit

;- Declare
Declare Event_Panel_PromptScratch()
Declare Event_Check_Stay_on_top()
Declare Event_Edit_Prompt()
Declare Event_Edit_ScratchPad()
Declare Event_BackButton()
Declare Event_Forward()
Declare Event_BtnImg_1()
Declare Event_String_Fleet()
Declare Event_Fleet()
Declare Event_BackButton_1()
Declare Event_Forward_1()
Declare Event_BtnImg_2()
Declare Event_String_Slack()
Declare Event_Slack()
Declare Event_Menu_Window_main()
Declare Resize_Window_main()
Declare Event_Close_Window_main()
Declare Menu_Window_main()
Declare Open_Window_main(X = 0, Y = 0, Width = 1000, Height = 720)

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
  If GetGadgetState(#Check_Stay_on_top) = #True
    StickyWindow(#Window_main, #True)
  Else
    StickyWindow(#Window_main, #False)
  EndIf
  
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

Procedure Event_BackButton()
  MessageRequester("Information", "Button Image Name : #BackButton")
EndProcedure

Procedure Event_Forward()
  MessageRequester("Information", "Button Image Name : #Forward")
EndProcedure

Procedure Event_BtnImg_1()
  MessageRequester("Information", "Button Image Name : #BtnImg_1")
EndProcedure

Procedure Event_String_Fleet()
  Select EventType()
    Case #PB_EventType_Focus
    Case #PB_EventType_Change
    Case #PB_EventType_LostFocus
  EndSelect
EndProcedure

Procedure Event_Fleet()
  Select EventType()
    Case #PB_EventType_TitleChange
    Case #PB_EventType_StatusChange
    Case #PB_EventType_DownloadStart
    Case #PB_EventType_DownloadProgress
    Case #PB_EventType_DownloadEnd
    Case #PB_EventType_PopupWindow
    Case #PB_EventType_PopupMenu
  EndSelect
EndProcedure

Procedure Event_BackButton_1()
  MessageRequester("Information", "Button Image Name : #BackButton_1")
EndProcedure

Procedure Event_Forward_1()
  MessageRequester("Information", "Button Image Name : #Forward_1")
EndProcedure

Procedure Event_BtnImg_2()
  MessageRequester("Information", "Button Image Name : #BtnImg_2")
EndProcedure

Procedure Event_String_Slack()
  Select EventType()
    Case #PB_EventType_Focus
    Case #PB_EventType_Change
    Case #PB_EventType_LostFocus
  EndSelect
EndProcedure

Procedure Event_Slack()
  Select EventType()
    Case #PB_EventType_TitleChange
    Case #PB_EventType_StatusChange
    Case #PB_EventType_DownloadStart
    Case #PB_EventType_DownloadProgress
    Case #PB_EventType_DownloadEnd
    Case #PB_EventType_PopupWindow
    Case #PB_EventType_PopupMenu
  EndSelect
EndProcedure

Procedure Event_Menu_Window_main()
  Select EventMenu()
    Case #Menu_Quit
      Quit = #True
    Case #Menu_New
    Case #Menu_Open
    Case #Menu_Save
    Case #Menu_Quit
    Case #Menu_About
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
  ResizeGadget(#BackButton, ScaleX * 3, ScaleY * 0, ScaleX * 50, ScaleY * 28)
  ResizeGadgetImage(#BackButton)
  ResizeGadget(#Forward, ScaleX * 63, ScaleY * 0, ScaleX * 50, ScaleY * 28)
  ResizeGadgetImage(#Forward)
  ResizeGadget(#BtnImg_1, ScaleX * 124, ScaleY * 0, ScaleX * 50, ScaleY * 28)
  ResizeGadgetImage(#BtnImg_1)
  ResizeGadget(#String_Fleet, ScaleX * 184, ScaleY * 2, ScaleX * 545, ScaleY * 25)
  ResizeGadget(#Fleet, ScaleX * 0, ScaleY * 30, ScaleX * 992, ScaleY * 615)
  ResizeGadget(#BackButton_1, ScaleX * 3, ScaleY * 0, ScaleX * 50, ScaleY * 28)
  ResizeGadgetImage(#BackButton_1)
  ResizeGadget(#Forward_1, ScaleX * 63, ScaleY * 0, ScaleX * 50, ScaleY * 28)
  ResizeGadgetImage(#Forward_1)
  ResizeGadget(#BtnImg_2, ScaleX * 124, ScaleY * 0, ScaleX * 50, ScaleY * 28)
  ResizeGadgetImage(#BtnImg_2)
  ResizeGadget(#String_Slack, ScaleX * 185, ScaleY * 2, ScaleX * 545, ScaleY * 25)
  ResizeGadget(#Slack, ScaleX * 0, ScaleY * 30, ScaleX * 992, ScaleY * 615)
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
        SetGadgetFont(#Txt_Prompt, FontID(#Font_Default_10_B))
      CheckBoxGadget(#Check_Stay_on_top, 700, 10, 271, 20, "Stay on top")
      EditorGadget(#Edit_Prompt, 0, 34, 992, 303, #PB_Editor_WordWrap)
        AddGadgetItem(#Edit_Prompt, -1, "Editor Line 1")
        AddGadgetItem(#Edit_Prompt, -1, "Editor Line 2")
        AddGadgetItem(#Edit_Prompt, -1, "Editor Line 3")
        SetGadgetFont(#Edit_Prompt, FontID(#Font_Default_10))
      TextGadget(#Txt_ScratchPad, 0, 351, 355, 20, "Scratch Pad:")
        SetGadgetFont(#Txt_ScratchPad, FontID(#Font_Default_10_B))
      EditorGadget(#Edit_ScratchPad, 0, 375, 992, 260, #PB_Editor_WordWrap)
        AddGadgetItem(#Edit_ScratchPad, -1, "Editor Line 1")
        AddGadgetItem(#Edit_ScratchPad, -1, "Editor Line 2")
        AddGadgetItem(#Edit_ScratchPad, -1, "Editor Line 3")
        SetGadgetFont(#Edit_ScratchPad, FontID(#Font_Default_10))
      AddGadgetItem(#Panel_PromptScratch, -1, "Fleetai")
      ButtonImageGadget(#BackButton, 3, 0, 50, 28, ImageID(#Imag_leftarrow_24))
      ButtonImageGadget(#Forward, 63, 0, 50, 28, ImageID(#Imag_rightarrow_24))
      ButtonImageGadget(#BtnImg_1, 124, 0, 50, 28, ImageID(#Imag_Home))
      StringGadget(#String_Fleet, 184, 2, 545, 25, "http://fleetai.com")
        SetGadgetFont(#String_Fleet, FontID(#Font_Default_10))
      WebGadget(#Fleet, 0, 30, 992, 615, "https://fleetai.com/", #PB_Web_Edge)
      AddGadgetItem(#Panel_PromptScratch, -1, "Slack")
      ButtonImageGadget(#BackButton_1, 3, 0, 50, 28, ImageID(#Imag_leftarrow_24))
      ButtonImageGadget(#Forward_1, 63, 0, 50, 28, ImageID(#Imag_rightarrow_24))
      ButtonImageGadget(#BtnImg_2, 124, 0, 50, 28, ImageID(#Imag_Home))
      StringGadget(#String_Slack, 185, 2, 545, 25, "https://app.slack.com/client/")
      WebGadget(#Slack, 0, 30, 992, 615, "https://app.slack.com/client/", #PB_Web_Edge)
    CloseGadgetList()   ; #Panel_PromptScratch

    BindGadgetEvent(#Panel_PromptScratch, @Event_Panel_PromptScratch())
    BindGadgetEvent(#Check_Stay_on_top, @Event_Check_Stay_on_top())
    BindGadgetEvent(#Edit_Prompt, @Event_Edit_Prompt())
    BindGadgetEvent(#Edit_ScratchPad, @Event_Edit_ScratchPad())
    BindGadgetEvent(#BackButton, @Event_BackButton())
    BindGadgetEvent(#Forward, @Event_Forward())
    BindGadgetEvent(#BtnImg_1, @Event_BtnImg_1())
    BindGadgetEvent(#String_Fleet, @Event_String_Fleet())
    BindGadgetEvent(#Fleet, @Event_Fleet())
    BindGadgetEvent(#BackButton_1, @Event_BackButton_1())
    BindGadgetEvent(#Forward_1, @Event_Forward_1())
    BindGadgetEvent(#BtnImg_2, @Event_BtnImg_2())
    BindGadgetEvent(#String_Slack, @Event_String_Slack())
    BindGadgetEvent(#Slack, @Event_Slack())
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
    Select WaitWindowEvent()
    EndSelect
  Until Quit
  ;EndIceKeepEventLoop
EndIf
CompilerEndIf

;- DataSection
DataSection
  Imag_Home: : IncludeBinary "C:\Users\Brian\Documents\PureBasic Projects\Prompt Buddy\Home.png"
  Imag_rightarrow_24: : IncludeBinary "C:\Users\Brian\Documents\PureBasic Projects\Prompt Buddy\rightarrow_24.png"
  Imag_leftarrow_24: : IncludeBinary "C:\Users\Brian\Documents\PureBasic Projects\Prompt Buddy\leftarrow_24.png"
EndDataSection

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 3
; Folding = ----
; EnableXP
; DPIAware