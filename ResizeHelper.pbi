;-Top
; -----------------------------------------------------------------------------
;             Title: Resize Gadget Image and Font Helper
;       Source Name: ResizeHelper.pbi
;            Author: ChrisR
;     Creation Date: 2024-12-04
;           Version: 1.2.0
;                OS: Windows only
;        PB-Version: 5.73 and Up
;              Note: Call FreeWindowBackground(#Window) to Delete a Window's Background Brush
;             Usage: ResizeGadgetImage(#Gadget), ResizeWindowBackground(#Window, OriginalImage, Width, Height), ResizeGadgetFont(#Gadget, ScaleY.f)
;         History02: 2025-11-22 (ChrisR)
;                    Add font size resizing as a sub-option to proportional size for all Gadgets
;                    By calling the ResizeGadgetFont(#Gadget, ScaleY.f) procedure from the Resize_Window() procedure for each gadget with text
;                    The font size is proportional to the Gadget's vertical resizing
;                    When creating a font with a resized size, check whether a font with the same name, size, and style already exists. If so, reuse it
;                    and release the previous one if it is not used by another gadget and not an original font of the calling program
;         History01: 2025-01-08 (ChrisR) 
;                    Resize ImageGadget or ButtonImage even If Image or Pressed Image are changed with: 
;                    SetGadgetState(#Gadget, ImageID(#NewImage)) Or SetGadgetAttribute(#Gadget, #PB_Button_(Pressed)Image, ImageID(#NewPressedImage))
;                    (*) Note: After changing the Image, you must send "PostEvent(#PB_Event_SizeWindow, #Window, 0)" to have the new Images resized to the Gadget size.
;                    The original edited image is saved during the first resize and is then used for further resizes.
; -----------------------------------------------------------------------------

Structure GadgetImages
  OriginalImage.i
  Image.i
  OriginalPressedImage.i
  PressedImage.i
  Width.i
  Height.i
EndStructure

Declare WindowPBfromWindowID(WindowID)
Declare FontPBfromFontID(FontID)
Declare ImagePBfromImageID(ImageID)
Declare ResizeGadgetImage(Gadget)
Declare ResizeGadgetImages(Gadget, OriginalImage, OriginalPressedImage = #PB_Default)

; Force the call to the original PB function
Macro PB(_Function_)
  _Function_
EndMacro

;---------------------------------------
;------ Import internal PB function
; --------------------------------------

Import ""
  CompilerIf Not(Defined(PB_Object_EnumerateStart, #PB_Procedure)) : PB_Object_EnumerateStart(PB_Objects)                 : CompilerEndIf
  CompilerIf Not(Defined(PB_Object_EnumerateNext,  #PB_Procedure)) : PB_Object_EnumerateNext(PB_Objects, *Object.Integer) : CompilerEndIf
  CompilerIf Not(Defined(PB_Object_EnumerateAbort, #PB_Procedure)) : PB_Object_EnumerateAbort(PB_Objects)                 : CompilerEndIf
  CompilerIf Not(Defined(PB_Window_Objects, #PB_Variable))         : PB_Window_Objects.i                                  : CompilerEndIf
  CompilerIf Not(Defined(PB_Image_Objects,  #PB_Variable))         : PB_Image_Objects.i                                   : CompilerEndIf
  CompilerIf Not(Defined(PB_Font_Objects,   #PB_Variable))         : PB_Font_Objects.i                                    : CompilerEndIf
EndImport

Procedure WindowPBfromWindowID(WindowID)
  Protected Window, ResultWindow = #PB_Default 
  PB_Object_EnumerateStart(PB_Window_Objects)
  While PB_Object_EnumerateNext(PB_Window_Objects, @Window)
    If WindowID = WindowID(Window)
      ResultWindow = Window
      Break
    EndIf
  Wend
  PB_Object_EnumerateAbort(PB_Window_Objects)
  ProcedureReturn ResultWindow
EndProcedure

Procedure FontPBfromFontID(FontID)
  Protected Font, ResultFont = #PB_Default
  PB_Object_EnumerateStart(PB_Font_Objects)
  While PB_Object_EnumerateNext(PB_Font_Objects, @Font)
    If FontID = FontID(Font)
      ResultFont = Font
      Break
    EndIf
  Wend
  PB_Object_EnumerateAbort(PB_Font_Objects)
  ProcedureReturn ResultFont
EndProcedure

Procedure ImagePBfromImageID(ImageID)
  Protected Image, ResultImage = #PB_Default
  PB_Object_EnumerateStart(PB_Image_Objects)
  While PB_Object_EnumerateNext(PB_Image_Objects, @Image)
    If ImageID = ImageID(Image)
      ResultImage = Image
      Break
    EndIf
  Wend
  PB_Object_EnumerateAbort(PB_Image_Objects)
  ProcedureReturn ResultImage
EndProcedure

;---------------------------------------
;------ Resize Gadget Font
; --------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  
  Structure GadgetFonts
    FontID.i
    FontPB.i
    FontName.s
    FontSize.u
    NewFontSize.u
    FontStyle.u
    OriginalFontPB.i
  EndStructure
  
  Declare FreeGadgetFont(Font)
  Declare FreePreviousFont(FontPB)
  Declare ReloadGadgetFont(Gadget)
  Declare GetGadgetFontInfo(Gadget, *GadgetFont.GadgetFonts)
  Declare GetDefaultFont(*GadgetFont.GadgetFonts)
  Declare ResizeGadgetFont(Gadget, ScaleY.f)
  
  Global NewMap GadgetFont.GadgetFonts()
  
  Macro FreeFont(_Font_)
    PB(FreeFont)(_Font_)
    FreeGadgetFont(_Font_)
  EndMacro
  
  Macro SetGadgetFont(_Gadget_, _FontID_)
    PB(SetGadgetFont)(_Gadget_, _FontID_)
    ReloadGadgetFont(_Gadget_)
  EndMacro
  
  Procedure FreeGadgetFont(Font)
    Protected Gadget
    ForEach GadgetFont()
      If GadgetFont()\OriginalFontPB = Font
        Gadget = Val(MapKey(GadgetFont()))
        If IsGadget(Gadget)
          SetGadgetFont(Gadget, #PB_Default)
        EndIf
      EndIf
    Next
  EndProcedure
  
  Procedure FreePreviousFont(FontPB)
    Protected Found
    If FontPB <> #PB_Default And IsFont(FontPB)
      With GadgetFont()
        ForEach GadgetFont()
          If \FontPB = FontPB Or \OriginalFontPB = FontPB
            Found = 1
            Break
          EndIf
        Next
      EndWith
      If Found = 0
        PB(FreeFont)(FontPB)
        ;Debug "FreeFont(" + FontPB + ")"
      EndIf
    EndIf   ; If FontPB <> #PB_Default And IsFont(FontPB)
  EndProcedure
  
  Procedure ReloadGadgetFont(Gadget)
    Protected Window, PreviousFontPB, OriginalFontPB
    If IsGadget(Gadget)
      If FindMapElement(GadgetFont(), Str(Gadget))
        ; Save the current font to free it up after Deleting Map Element
        PreviousFontPB = GadgetFont()\FontPB
        OriginalFontPB = GadgetFont()\OriginalFontPB
        DeleteMapElement(GadgetFont())
        ; Free previous font if it is not used by another Gadget and not an original font loaded by the calling program
        If PreviousFontPB <> OriginalFontPB
          FreePreviousFont(PreviousFontPB)
        EndIf
        
        Window = WindowPBfromWindowID(GetAncestor_(GadgetID(Gadget), #GA_ROOT))
        If IsWindow(Window)
          PostEvent(#PB_Event_SizeWindow, Window, #PB_Default)
        EndIf
      EndIf
    EndIf
  EndProcedure
  
  Procedure GetGadgetFontInfo(Gadget, *GadgetFont.GadgetFonts)
    Protected hDC, LogFont.LOGFONT
    With *GadgetFont
      \FontID = GetGadgetFont(Gadget)
      \FontPB = FontPBfromFontID(\FontID)
      If GetObject_(\FontID, SizeOf(LOGFONT), @LogFont)
        \FontName =  PeekS(@LogFont\lfFaceName[0])
        
        hDC = GetDC_(GadgetID(Gadget))
        If hDC
          \FontSize = Int(Round((-LogFont\lfHeight * 72 / GetDeviceCaps_(hDC, #LOGPIXELSY)), #PB_Round_Down))
          ReleaseDC_(GadgetID(Gadget), hDC)
        EndIf
        
        \FontStyle = 0
        If LogFont\lfWeight > #FW_NORMAL         : \FontStyle | #PB_Font_Bold        : EndIf
        If LogFont\lfItalic                      : \FontStyle | #PB_Font_Italic      : EndIf
        If LogFont\lfStrikeOut                   : \FontStyle | #PB_Font_StrikeOut   : EndIf
        If LogFont\lfUnderline                   : \FontStyle | #PB_Font_Underline   : EndIf
        If LogFont\lfQuality <> #DEFAULT_QUALITY : \FontStyle | #PB_Font_HighQuality : EndIf
      EndIf   ; If GetObject_(\FontID, SizeOf(LOGFONT), @LogFont)
    EndWith
  EndProcedure
  
  Procedure GetDefaultFont(*GadgetFont.GadgetFonts)
    Protected DummyGadget
    Static DefaultGadgetFont.GadgetFonts
    
    With *GadgetFont
      If DefaultGadgetFont\FontSize = 0
        DummyGadget = TextGadget(#PB_Any, -10, -10, 0, 0, "Abc123")
        GetGadgetFontInfo(DummyGadget, *GadgetFont)
        \NewFontSize = \FontSize
        DefaultGadgetFont\FontID         = \FontID
        DefaultGadgetFont\FontPB         = \FontPB
        DefaultGadgetFont\FontName       = \FontName
        DefaultGadgetFont\FontSize       = \FontSize
        DefaultGadgetFont\NewFontSize    = \NewFontSize 
        DefaultGadgetFont\FontStyle      = \FontStyle
        DefaultGadgetFont\OriginalFontPB = \FontPB
        FreeGadget(DummyGadget)
      Else
        \FontID                          = DefaultGadgetFont\FontID
        \FontPB                          = DefaultGadgetFont\FontPB
        \FontName                        = DefaultGadgetFont\FontName
        \FontSize                        = DefaultGadgetFont\FontSize
        \NewFontSize                     = DefaultGadgetFont\NewFontSize
        \FontStyle                       = DefaultGadgetFont\FontStyle
        \OriginalFontPB                  = DefaultGadgetFont\OriginalFontPB
      EndIf   ; If DefaultGadgetFont\FontSize = 0
    EndWith
  EndProcedure
  
  Procedure ResizeGadgetFont(Gadget, ScaleY.f)
    Protected FontPB, FontID, PreviousFontPB, FontName.s, NewFontSize.u, FontStyle.u
    
    If IsGadget(Gadget) And ScaleY
      With GadgetFont()
        ; If the Gadget does not exist in the map, add it with its font information.
        If Not FindMapElement(GadgetFont(), Str(Gadget))
          AddMapElement(GadgetFont(), Str(Gadget))
          GetGadgetFontInfo(Gadget, @GadgetFont())
          ; Use the Gadget's font or Call GetDefaultFont() if the Gadget's font has not been retrieved (GetObject Font API fails if a Gadget use a font that has been freed)
          If \FontSize
            \NewFontSize = \FontSize
            \OriginalFontPB = \FontPB
            ;Debug "GagdetFont(" + Gadget + ", " + \FontName + ", "  + \NewFontSize + ", "  + \FontStyle + ") = " + \FontPB
          Else
            GetDefaultFont(@GadgetFont())
            ;Debug "DefaultGagdetFont(" + Gadget + ", " + \FontName + ", "  + \NewFontSize + ", "  + \FontStyle + ") = " + \FontPB
          EndIf   ; If \FontSize
        EndIf     ; If Not FindMapElement(GadgetFont(), Str(Gadget))
        
        NewFontSize = Round(\FontSize * ScaleY, #PB_Round_Nearest)
        ; Resize the font only if the size is different from the previous one
        If NewFontSize <> \NewFontSize
          ; Save the current font to free it up after resizing if not used by another gadget
          PreviousFontPB = \FontPB
          FontName       = \FontName
          FontStyle      = \FontStyle
          ; Use the existing font if it is already defined for another Gadget
          PushMapPosition(GadgetFont())
          ForEach GadgetFont()
            If \FontName = FontName And \NewFontSize = NewFontSize And \FontStyle = FontStyle
              FontID = \FontID
              FontPB = \FontPB
              Break
            EndIf
          Next
          PopMapPosition(GadgetFont())
          
          ; If the font is not already defined, load it
          If Not FontID
            FontPB = LoadFont(#PB_Any, \FontName, NewFontSize, \FontStyle)
            ;Debug "LoadFont(" + \FontName + ",  " + NewFontSize + ",  " + \FontStyle + ") = " + FontPB
            FontID = FontID(FontPB)
          EndIf
          
          If FontID
            ; Change the gadget's font with its new size
            PB(SetGadgetFont)(Gadget, FontID)
            ;Debug "SetGadgetFont(" + Gadget + ",  " + \FontName + ",  " + NewFontSize + ",  " + \FontStyle + ") = " + FontPB
            \FontID      = FontID
            \FontPB      = FontPB
            \NewFontSize = NewFontSize
            
            ; Free previous font if it is not used by another Gadget and not an original font loaded by the calling program
            If \OriginalFontPB <> PreviousFontPB
              FreePreviousFont(PreviousFontPB)
            EndIf
            
          EndIf       ; If FontID
        EndIf         ; If NewFontSize <> \NewFontSize
      EndWith
    EndIf             ; If IsGadget(Gadget) And ScaleY
  EndProcedure
CompilerEndIf

;---------------------------------------
;------ Resize Gadget Image
; --------------------------------------

Procedure ResizeGadgetImage(Gadget)
  Protected Image, PressedImage
  If IsGadget(Gadget)
    Select GadgetType(Gadget)
      Case #PB_GadgetType_Image
        Image        = ImagePBfromImageID(GetGadgetState(Gadget))
        If Image <>  #PB_Default
          ResizeGadgetImages(Gadget, Image)
        EndIf
      Case #PB_GadgetType_ButtonImage
        Image        = ImagePBfromImageID(GetGadgetAttribute(Gadget, #PB_Button_Image))
        PressedImage = ImagePBfromImageID(GetGadgetAttribute(Gadget, #PB_Button_PressedImage))
        If Image <>  #PB_Default
          ResizeGadgetImages(Gadget, Image, PressedImage)
        EndIf
    EndSelect
  EndIf   ; If IsGadget(Gadget)
EndProcedure

Procedure ResizeGadgetImages(Gadget, OriginalImage, OriginalPressedImage = #PB_Default)
  Protected Image, Width, Height
  Static NewMap GadgetImage.GadgetImages()
  
  If IsGadget(Gadget) And IsImage(OriginalImage)
    Width = DesktopScaledX(GadgetWidth(Gadget)) : Height = DesktopScaledY(GadgetHeight(Gadget))
    If Width > 0 And Height > 0
      If Not FindMapElement(GadgetImage(), Str(Gadget))
        AddMapElement(GadgetImage(), Str(Gadget))
        GadgetImage()\OriginalImage = OriginalImage
        GadgetImage()\OriginalPressedImage = OriginalPressedImage
        GadgetImage()\Width = 0 : GadgetImage()\Height = 0
        ;Debug "Init Image Gagdet: " + Str(Gadget) +#TAB$+ " OriginalImage: " + Str(OriginalImage) +#TAB$+ " OriginalPressedImage: "  + Str(OriginalPressedImage)
      EndIf
      If GadgetImage()\Image <> OriginalImage
        ;  We pass here if the ImageGadget or ButtonImage image is changed + ResizeWindow event, e.g.: SetGadgetState(Gadget, ImageID(#NewImage)) : PostEvent(#PB_Event_SizeWindow, 0, 0)
        GadgetImage()\OriginalImage = OriginalImage
        GadgetImage()\Width = 0 : GadgetImage()\Height = 0
        ;Debug "Change Image Gagdet: " + Str(Gadget) +#TAB$+ " OriginalImage: " + Str(OriginalImage)
      EndIf
      If GadgetImage()\Width <> Width Or GadgetImage()\Height <> Height
        GadgetImage()\Width  =  Width :  GadgetImage()\Height =  Height
        
        Image = CopyImage(GadgetImage()\OriginalImage, #PB_Any)
        If Image
          ResizeImage(Image, Width, Height)
          Select GadgetType(Gadget)
            Case #PB_GadgetType_ButtonImage
              SetGadgetAttribute(Gadget, #PB_Button_Image, ImageID(Image))
            Case #PB_GadgetType_Image
              SetGadgetState(Gadget, ImageID(Image))
          EndSelect
          If GadgetImage()\Image And IsImage(GadgetImage()\Image)
            FreeImage(GadgetImage()\Image)
          EndIf
          GadgetImage()\Image = Image
        EndIf   ; If Image
        
        If GadgetType(Gadget) = #PB_GadgetType_ButtonImage And IsImage(OriginalPressedImage)
          If GadgetImage()\PressedImage <> OriginalPressedImage
            ; We pass here if the ButtonImage pressed image is changed + ResizeWindow event, e.g.: SetGadgetAttribute(Gadget, #PB_Button_PressedImage, ImageID(#NewPressedImage)) : PostEvent(#PB_Event_SizeWindow, 0, 0)
            GadgetImage()\OriginalPressedImage = OriginalPressedImage
            ;Debug "Change Pressed Image Gagdet: " + Str(Gadget) +#TAB$+ " OriginalPressedImage: " + Str(OriginalPressedImage)
          EndIf
          Image = CopyImage(GadgetImage()\OriginalPressedImage, #PB_Any)
          If Image
            ResizeImage(Image, Width, Height)
            SetGadgetAttribute(Gadget, #PB_Button_PressedImage, ImageID(Image))
            If GadgetImage()\PressedImage And IsImage(GadgetImage()\PressedImage)
              FreeImage(GadgetImage()\PressedImage)
            EndIf
            GadgetImage()\PressedImage = Image
          EndIf
        EndIf   ; If GadgetType(Gadget) = #PB_GadgetType_ButtonImage And IsImage(OriginalPressedImage)
        
      EndIf     ; If GadgetImage(Str(Gadget))\Width <> Width Or GadgetImage(Str(Gadget))\Height <> Height
    EndIf       ; If Width > 0 And Height > 0
  EndIf         ; If IsGadget(Gadget) And IsImage(OriginalImage)
EndProcedure

;---------------------------------------
;------ Resize Window Background
; --------------------------------------

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Structure WindowBackgrounds
    BrushBackground.i
    Width.i
    Height.i
  EndStructure
  
  Declare ResizeWindowBackground(Window, OriginalImage, Width, Height)
  
  Macro FreeWindowBackground(_Window_)
    ResizeWindowBackground(_Window_, #PB_Default, 0, 0)
  EndMacro
  
  Procedure ResizeWindowBackground(Window, OriginalImage, Width, Height)
    Protected Image
    Static NewMap WindowBackground.WindowBackgrounds()
    
    If OriginalImage = #PB_Default
      If FindMapElement(WindowBackground(), Str(Window))
        If WindowBackground()\BrushBackground
          DeleteObject_(WindowBackground()\BrushBackground)
        EndIf
        DeleteMapElement(WindowBackground())
      EndIf
      ProcedureReturn
    EndIf   ; If OriginalImage = #PB_Default
    
    If IsWindow(Window) And IsImage(OriginalImage)
      If Width > 0 And Height > 0
        Width = DesktopScaledX(Width) : Height = DesktopScaledY(Height)
        If WindowBackground(Str(Window))\Width <> Width Or WindowBackground(Str(Window))\Height <> Height
          WindowBackground()\Width  =  Width :  WindowBackground()\Height =  Height
          
          Image = CopyImage(OriginalImage, #PB_Any)
          If Image
            ResizeImage(Image, Width, Height)
            If WindowBackground()\BrushBackground
              DeleteObject_(WindowBackground()\BrushBackground)
            EndIf
            WindowBackground()\BrushBackground = CreatePatternBrush_(ImageID(Image))
            If WindowBackground()\BrushBackground
              SetClassLongPtr_(WindowID(Window), #GCL_HBRBACKGROUND, WindowBackground()\BrushBackground)
              InvalidateRect_(WindowID(Window), #Null, #True)
            EndIf
            FreeImage(Image)
          EndIf
          
        EndIf    ; If WindowBackground(Str(Window))\Width <> Width Or WindowBackground(Str(Window))\Height <> Height
      EndIf      ; If Width > 0 And Height > 0
    EndIf        ; If IsWindow(Window) And IsImage(OriginalImage)
  EndProcedure
CompilerEndIf

;---------------------------------------
;------ Demo Resize Helper
;---------------------------------------

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  UseJPEGImageDecoder()
  LoadImage(0,    #PB_Compiler_Home + "Examples\Sources\Data\Geebee2.bmp")
  LoadImage(1,  #PB_Compiler_Home + "Examples\3D\Data\Textures\Lensflare5.jpg")
  LoadImage(2,  #PB_Compiler_Home + "Examples\3D\Data\Textures\Lensflare6.jpg")
  
  LoadFont(0, "Segoe UI Black", 12)
  LoadFont(1, "Courier New", 11, #PB_Font_Italic)
  LoadFont(2, "Tahoma", 9, #PB_Font_Bold)
  
  XIncludeFile "ResizeHelper.pbi"
  
  Procedure Resize_Window()
    Protected Window_WidthIni = 420, Window_HeightIni = 254
    Protected ScrlArea_WidthIni = 400, ScrlArea_HeightIni = 62
    Protected ScrlArea_InnerWidthIni = 372, ScrlArea_InnerHeightIni = 124
    Protected ScaleX.f, ScaleY.f
    
    ScaleX = WindowWidth(0) / Window_WidthIni : ScaleY = WindowHeight(0) / Window_HeightIni
    ResizeGadget(0, ScaleX * 10, ScaleY * 10, ScaleX * 128, ScaleY * 128)
    ResizeGadgetImage(0)
    ResizeGadget(1, ScaleX * 150, ScaleY * 10, ScaleX * 260, ScaleY * 40)
    ResizeGadgetFont(1, ScaleY)
    ResizeGadget(2, ScaleX * 150, ScaleY * 70, ScaleX * 260, ScaleY * 68)
    ResizeGadgetImage(2)
    ResizeGadget(3, ScaleX * 10, ScaleY * 150, ScaleX * 400, ScaleY * 20)
    ResizeGadgetFont(3, ScaleY)
    ResizeGadget(4, ScaleX * 10, ScaleY * 182, ScaleX * 400, ScaleY * 62)
    ScaleX = GadgetWidth(4) / ScrlArea_WidthIni : ScaleY = GadgetHeight(4) / ScrlArea_HeightIni
    SetGadgetAttribute(4, #PB_ScrollArea_InnerWidth, ScaleX * ScrlArea_InnerWidthIni) : SetGadgetAttribute(4, #PB_ScrollArea_InnerHeight, ScaleY * ScrlArea_InnerHeightIni)
    ResizeGadget(5, ScaleX * 10, ScaleY * 22, ScaleX * 80, ScaleY * 20)
    ResizeGadgetFont(5, ScaleY)
    ResizeGadget(6, ScaleX * 90, ScaleY * 20, ScaleX * 280, ScaleY * 22)
    ResizeGadgetFont(6, ScaleY)
    
    ;CompilerIf #PB_Compiler_OS = #PB_OS_Windows : RedrawWindow_(WindowID(0), #Null, #Null, #RDW_INVALIDATE | #RDW_ERASE | #RDW_ALLCHILDREN | #RDW_UPDATENOW) : CompilerEndIf
  EndProcedure
  
  Procedure Open_Window(X = 0, Y = 0, Width = 420, Height = 254)
    If OpenWindow(0, X, Y, Width, Height, "Demo Resize Helper", #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_ScreenCentered)
      ImageGadget(0, 10, 10, 128, 128, ImageID(0))
      ButtonGadget(1, 150, 10, 260, 40, "Free Segoe_UI_10_Bold Font", #PB_Button_Toggle)
      SetGadgetFont(1, FontID(0))
      ButtonImageGadget(2, 150, 70, 260, 68, ImageID(1), #PB_Button_Toggle)
      SetGadgetAttribute(2, #PB_Button_PressedImage, ImageID(2))
      CheckBoxGadget(3, 10, 150, 400, 20, "Change Font for Text and String")
      ScrollAreaGadget(4, 10, 182, 400, 62, 372, 124, 10, #PB_ScrollArea_Single)
      TextGadget(5, 10, 22, 80, 20, "Text :")
      SetGadgetFont(5, FontID(1))
      StringGadget(6, 90, 20, 280, 22, "String Courier_New_11_Italic")
      ; With FreeFont and LoadFont, GetDefaultFont() is called for Gadget 5 above which used this font, the GetObject Font API fails in this case
      ;FreeFont(1) : LoadFont(1, "Courier New", 11, #PB_Font_Italic)
      SetGadgetFont(6, FontID(1))
      CloseGadgetList()
      
      BindEvent(#PB_Event_SizeWindow, @Resize_Window(), 0)
      PostEvent(#PB_Event_SizeWindow, 0, 0)
      ProcedureReturn #True
    EndIf
  EndProcedure
  
  ;- Main Demo Program
  If Open_Window()
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow
          Break
        Case #PB_Event_Gadget
          Select EventGadget()
            Case 1
              If GetGadgetState(1)
                SetGadgetText(1, "Load Segoe_UI_10_Bold Font")
                FreeFont(0)
              Else
                SetGadgetText(1, "Free Segoe_UI_10_Bold Font")
                LoadFont(0, "Segoe UI Black", 10)
                SetGadgetFont(1, FontID(0))
              EndIf
            Case 3
              If GetGadgetState(3)
                SetGadgetText(6, "String Tahoma_9_Bold")
                SetGadgetFont(5, FontID(2)) : SetGadgetFont(6, FontID(2))
              Else
                SetGadgetText(6, "String Courier_New_11_Italic")
                SetGadgetFont(5, FontID(1)) : SetGadgetFont(6, FontID(1))
              EndIf
          EndSelect
      EndSelect
    ForEver
  EndIf
CompilerEndIf
; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 243
; FirstLine = 230
; Folding = -----
; EnableXP
; DPIAware