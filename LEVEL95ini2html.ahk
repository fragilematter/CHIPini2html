#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

FileEncoding, UTF-8-RAW
Global Navigation := ""

Loop %0%  ; For each parameter (or file dropped onto a script):
{
  GivenPath := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
  Loop %GivenPath%, 1
    LongPath = %A_LoopFileLongPath%
  ProcessFile(LongPath)
}

ProcessFile(inFile) 
{
  dateStamp := GetDateStamp(inFile)
  outFile := GetOutputFile(inFile, dateStamp)
  outFileTmp := outFile . ".tmp"
  
  FileDelete, %outFile%.tmp

  WriteHTMLHeader(outFileTmp, dateStamp, "CD")
  
  WriteDirectX(inFile, outFileTmp)
  
  WriteFullversion(inFile, outFileTmp)
  
  WriteDemos(inFile, outFileTmp)
  
  WriteShareware(inFile, outFileTmp)
  
  WriteMovies(inFile, outFileTmp)
  
  WriteUpdates(inFile, outFileTmp)
  
  WriteThemes(inFile, outFileTmp)
  
  WriteHotshots(inFile, outFileTmp)
  
  WriteDrivers(inFile, outFileTmp)
  
  WriteExtras(inFile, outFileTmp)
  
  WriteHTMLFooter(outFileTmp)
  
  WriteNavigation(outFileTmp, outFile)
}

GetOutputFile(inFile, dateStamp)
{
  outFile := ""

  
  SplitPath, inFile, , outFile
  outFile .= "\LEVEL"
  
  outFile := outFile . dateStamp . "R.html"
  
  Return outFile
}

GetDateStamp(inFile)
{
  dateStamp := ""

  IniRead, dateStamp, %inFile%, Main, CD
  
  if (dateStamp = "ERROR")
  {
    dateStamp := ""
  }
  
  Return dateStamp
}

WriteHTMLHeader(outFile, HTMLtitle, MediaType) 
{
  FileAppend, 
(
<!DOCTYPE html>
<html lang="ro">
`t<head>
`t`t<meta charset="utf-8" />
`t`t<meta name="generator" content="Lame AHK LEVEL95.ini parser by Doru Barbu - http://db.0db.ro" />
`t`t<title>LEVEL %MediaType% %HTMLtitle%</title>
`t</head>
`t<body>
`t`t<h1>LEVEL %MediaType% %HTMLtitle%</h1>
`t`t<hr />`n
<!-- Navigation -->`n
), %outFile%
  
}

WriteHTMLFooter(OutputFile)
{
  FileAppend, 
(
`t</body>
</html>
), %OutputFile%
}

WriteDirectX(inFile, outFile)
{
  DX := ""
  DXV := ""
  
  IniRead, DX, %inFile%, Main, DirectX
  IniRead, DXV, %inFile%, Main, DirectXV
  
  if (DXV = "ERROR") || (DXV = "")
  {
    Return
  }
  
  if (DX = "ERROR") || (DX = "")
  {
    DX := "<br /><i>/" . DX . "</i>"
  }
  else
  {
    DX := ""
  }
  
  FileAppend, 
(
`t`t<section id="DirectX">DirectX %DXV%%DX%</section><br />`n
), %outFile%
}

WriteFullversion(inFile, outFile)
{
  Fulls := 0
  FullHTML := ""
  
  IniRead, Fulls, %inFile%, Main, Fulls, 0
  
  If (Fulls > 0)
  {
    FileAppend, `t`t<section id="FullVersion"><h1>Full Version</h1>`n , %outFile%
    Navigation .= "<th><a href=""#FullVersion"">Full Version</a></th>"
  }
  
  Loop, %Fulls%
  {
    FullHTML := GetItem(inFile, "Full", A_Index)
    If (FullHTML <> "")
      FileAppend, %FullHTML%`n , %outFile%
  }
  
  If (Fulls > 0)
    FileAppend, `t`t</section><br />`n , %outFile%
}

WriteDemos(inFile, outFile)
{
  Demos := 0
  DemoHTML := ""
  
  IniRead, Demos, %inFile%, Main, Demos, 0
  
  If (Demos > 0)
  {
    FileAppend, `t`t<section id="Demos"><h1>Demos</h1>`n , %outFile%
    Navigation .= "<th><a href=""#Demos"">Demos</a></th>"
  }
  
  Loop, %Demos%
  {
    DemoHTML := GetItem(inFile, "Demo", A_Index)
    If (DemoHTML <> "")
      FileAppend, %DemoHTML%`n , %outFile%
  }
  
  If (Demos > 0)
    FileAppend, `t`t</section><br />`n , %outFile%
}

GetItem(inFile, CategoryName, ItemIndex)
{
  ItemName := ""
  ItemCompany := ""
  ItemTech := ""
  ItemPath := ""
  ItemInstall := ""
  PictureName := ""
  LaunchDate := ""
  
  DescEN := ""
  DescRO := ""
  DescCZ := ""
  
  ItemHTML := ""
  
  IniRead, ItemName, %inFile%, %CategoryName%%ItemIndex%, FullName
  if (ItemName = "ERROR")
    IniRead, ItemName, %inFile%, %CategoryName%%ItemIndex%, Name
    
  if (ItemName = "ERROR")
    Return ""
  
  IniRead, ItemCompany, %inFile%, %CategoryName%%ItemIndex%, Firm
  IniRead, ItemTech, %inFile%, %CategoryName%%ItemIndex%, Techinfo
  IniRead, ItemPath, %inFile%, %CategoryName%%ItemIndex%, InstallDir
  IniRead, ItemInstall, %inFile%, %CategoryName%%ItemIndex%, InstallName
  IniRead, PictureName, %inFile%, %CategoryName%%ItemIndex%, Picture
  IniRead, LaunchDate, %inFile%, %CategoryName%%ItemIndex%, Date
  
  IniRead, DescEN, %inFile%, %CategoryName%%ItemIndex%, Describe0
  IniRead, DescRO, %inFile%, %CategoryName%%ItemIndex%, Describe6
  if (DescEN = "ERROR") && (DescRO <> "ERROR")
  {
    IniRead, DescCZ, %inFile%, %CategoryName%%ItemIndex%, Describe1
    IniRead, DescEN, %inFile%, %CategoryName%%ItemIndex%, Describe2
    IniRead, DescRO, %inFile%, %CategoryName%%ItemIndex%, Describe6
  }
  else
  {
    IniRead, DescCZ, %inFile%, %CategoryName%%ItemIndex%, Describe1
    IniRead, DescRO, %inFile%, %CategoryName%%ItemIndex%, Describe3
  }
  
  ItemHTML := "`t`t`t<dl>`n"
            . "`t`t`t`t<dt>" . ItemName . "</dt>`n"
            
  if (ItemCompany <> "ERROR")
    ItemHTML .= A_Tab . A_Tab . A_Tab . A_Tab . "<dd>Publisher: " . ItemCompany . "</dd>`n"

  if (DescEN <> "ERROR") && (DescEN <> "")
    ItemHTML .= A_Tab . A_Tab . A_Tab . A_Tab . "<dd><b>EN:</b> " . DescEN . "</dd>`n"
    
  if (DescRO <> "ERROR") && (DescRO <> "")
    ItemHTML .= A_Tab . A_Tab . A_Tab . A_Tab . "<dd><b>RO:</b> " . DescRO . "</dd>`n"
    
  if (DescCZ <> "ERROR") && (DescCZ <> "")
    ItemHTML .= A_Tab . A_Tab . A_Tab . A_Tab . "<dd><b>CZ</b>: " . DescCZ . "</dd>`n"
    
  If (PictureName = "ERROR")
  {
    PictureName := ""
  }
  else if (PictureName <> "")
  {
    PictureName := "Screenshot: <i>/LEVEL/" . PictureName . "</i>"
  }
  
  If (LaunchDate = "ERROR") || (LaunchDate = "0") || (LaunchDate = "00")
  {
    LaunchDate := ""
  }
  else if (LaunchDate <> "")
  {
    LaunchDate := "Launch Date: " . LaunchDate
  }

  If (PictureName <> "") && (LaunchDate <> "")
  {
    ItemHTML .= "`t`t`t`t<dd>" . PictureName . " | " . LaunchDate . "</dd>`n"
  }
  else if (PictureName <> "") || (LaunchDate <> "")
  {
    ItemHTML .= "`t`t`t`t<dd>" . PictureName . LaunchDate . "</dd>`n"
  }
    
  if (ItemPath = "ERROR")
  {
    ItemPath := ""
  }
  else if (ItemPath <> "")
  {
    ItemPath := "/" . ItemPath
    if (CategoryName = "Theme")
    {
      ItemPath := "/Themes" . ItemPath
    } 
    else if (CategoryName = "Driver")
    {
      ItemPath := "/Drivers" . ItemPath
    }
    else if (CategoryName = "Movie")
    {
      ItemPath := "/Movies" . ItemPath    
    }
    else if (CategoryName = "Extra")
    {
      ItemPath := "/Extra" . ItemPath    
    }
    
  }
  
  If (ItemInstall = "ERROR")
  {
    ItemInstall := ""
  }
  else if (ItemInstall <> "")
  {
    ItemInstall := "/" . ItemInstall
  }
    
  If (ItemPath <> "") || (ItemInstall <> "")
  {
    ItemPath := StrReplace("<i>" . ItemPath . ItemInstall . "</i>", "\", "/")
  }
    
  if (ItemTech <> "ERROR")
  {
    ItemHTML .= "`t`t`t`t<dd>" . ItemPath . " | " ItemTech . "</dd>`n"
  }
  else if (ItemPath <> "")
  {
    ItemHTML .= "`t`t`t`t<dd>" . ItemPath . "</dd>`n"
  }
    
  ItemHTML .= "`t`t`t</dl>`n"
  
  Return ItemHTML
}

WriteShareware(inFile, outFile)
{
  Shareware := 0
  SharewareHTML := ""
  ShareItem := ""
  ShareIndex := ""
  TestSharewareVersion := ""
  
  IniRead, Shareware, %inFile%, Main, Shareware, -1
  IniRead, TestSharewareVersion, %inFile%, 1hareware, Share01
  
  If (Shareware < 0) || (TestSharewareVersion <> "ERROR")
  {
    Loop, 99
    {
      ShareIndex := Format("{:02}", A_Index)
      IniRead, ShareItem, %inFile%, 1hareware, Share%ShareIndex%
      
      If (ShareItem = "ERROR")
        break
        
      SharewareHTML .= "`t`t`t`t<li>" . ShareItem . "</li>`n"
    }
  }
  
  If (Shareware > 0) || (SharewareHTML <> "")
  {
    FileAppend, `t`t<section id="Shareware"><h1>Shareware</h1>`n , %outFile%
    Navigation .= "<th><a href=""#Shareware"">Shareware</a></th>"
  }
  
  If (SharewareHTML <> "")
  {
    FileAppend, `t`t`t<ul>`n , %outFile%
    FileAppend, %SharewareHTML%, %outFile%
    FileAppend, `t`t`t</ul>`n , %outFile%
  }
  else
  {
    Loop, %Shareware%
    {
      SharewareHTML := GetItem(inFile, "Share", A_Index)
      FileAppend, %SharewareHTML%`n , %outFile%
    }
  }
  
  If (Shareware > 0) || (SharewareHTML <> "")
    FileAppend, `t`t</section><br />`n , %outFile%
}

WriteUpdates(inFile, outFile)
{
  Updates := 0
  UpdatesHTML := ""
  UpdateItem := ""
  UpdateIndex := ""
  UpdateArrayLength := 0
  
  IniRead, Updates, %inFile%, Main, Updates, -1
  
  If (Updates < 0)
  {
    Loop, 99
    {
      UpdateIndex := Format("{:02}", A_Index)
      IniRead, UpdateItem, %inFile%, Updates, Update%UpdateIndex%
      
      If (UpdateItem = "ERROR")
        Break
        
      UpdatesHTML .= "`t`t`t`t<li>" . UpdateItem . "</li>`n"
    }
    
    If (UpdatesHTML <> "")
      UpdatesHTML := "`t`t`t<ul>`n" . UpdatesHTML . "`t`t`t</ul>`n"
  }
  else
  {
    Loop, %Updates%
    {
      IniRead, UpdateItem, %inFile%, Updates, Update%A_Index%
      
      If (UpdateItem = "ERROR")
        Continue
      
      UpdateArray := StrSplit(UpdateItem, ";")
      
      UpdateItem := UpdateArray[1]
      
      UpdateArrayLength = UpdateArray.Length()
      If (UpdateArrayLength > 1) && (UpdateArray[2] <> "")
        UpdateItem .= " " . UpdateArray[2]
      
      UpdatesHTML .= "`t`t`t<dl>`n"
                   . "`t`t`t<dt>" . UpdateItem . "</dt>`n"
                   
      If (UpdateArrayLength > 2) && (UpdateArray[3] <> "")
        UpdatesHTML .= "`t`t`t<dd><i>/" . StrReplace(UpdateArray[3], "\", "/") 
                     . "</i></dd>`n"
    }
  }
  
  If (UpdatesHTML <> "")
  {
    FileAppend, `t`t<section id="Updates"><h1>Updates</h1>`n , %outFile%
    FileAppend, %UpdatesHTML%, %outFile%
    FileAppend, `t`t</section><br />`n , %outFile%
    Navigation .= "<th><a href=""#Updates"">Updates</a></th>"
  }    
}

WriteHotshots(inFile, outFile)
{
  Shots := 0
  ShotHTML := ""
  
  IniRead, Shots, %inFile%, Main, Shots, 0
  
  If (Shots > 0)
  {
    FileAppend, `t`t<section id="HotShots"><h1>HotShots</h1>`n , %outFile%
    Navigation .= "<th><a href=""#HotShots"">HotShots</a></th>"
  }
  
  Loop, %Shots%
  {
    ShotHTML := GetItem(inFile, "Shot", A_Index)
    If (ShotHTML <> "")
      FileAppend, %ShotHTML%`n , %outFile%
  }
  
  If (Shots > 0)
    FileAppend, `t`t</section><br />`n , %outFile%
}

WriteThemes(inFile, outFile)
{
  Themes := 0
  ThemeHTML := ""
  
  IniRead, Themes, %inFile%, Main, Themes, 0
  
  If (Themes > 0)
  {
    FileAppend, `t`t<section id="Themes"><h1>Themes</h1>`n , %outFile%
    Navigation .= "<th><a href=""#Themes"">Themes</a></th>"
  }
  
  Loop, %Themes%
  {
    ThemeHTML := GetItem(inFile, "Theme", A_Index)
    If (ThemeHTML <> "")
      FileAppend, %ThemeHTML%`n , %outFile%
  }
  
  If (Themes > 0)
    FileAppend, `t`t</section><br />`n , %outFile%
}

WriteDrivers(inFile, outFile)
{
  Drivers := 0
  DriverHTML := ""
  
  IniRead, Drivers, %inFile%, Main, Drivers, 0
  
  If (Drivers > 0)
  {
    FileAppend, `t`t<section id="Drivers"><h1>Drivers</h1>`n , %outFile%
    Navigation .= "<th><a href=""#Drivers"">Drivers</a></th>"
  }
  
  Loop, %Drivers%
  {
    DriverHTML := GetItem(inFile, "Driver", A_Index)
    If (DriverHTML <> "")
      FileAppend, %DriverHTML%`n , %outFile%
  }
  
  If (Drivers > 0)
    FileAppend, `t`t</section><br />`n , %outFile%
}

WriteMovies(inFile, outFile)
{
  Movies := 0
  MovieHTML := ""
  
  IniRead, Movies, %inFile%, Main, Movies, 0
  
  If (Movies > 0)
  {
    FileAppend, `t`t<section id="Movies"><h1>Movies</h1>`n , %outFile%
    Navigation .= "<th><a href=""#Movies"">Movies</a></th>"
  }
  
  Loop, %Movies%
  {
    MovieHTML := GetItem(inFile, "Movie", A_Index)
    If (MovieHTML <> "")
      FileAppend, %MovieHTML%`n , %outFile%
  }
  
  If (Movies > 0)
    FileAppend, `t`t</section><br />`n , %outFile%
}

WriteExtras(inFile, outFile)
{
  Extras := 0
  ExtraHTML := ""
  
  IniRead, Extras, %inFile%, Main, Extra, 0
  
  If (Extras > 0)
  {
    FileAppend, `t`t<section id="Extras"><h1>Extras</h1>`n , %outFile%
    Navigation .= "<th><a href=""#Extras"">Extras</a></th>"
  }
  
  Loop, %Extras%
  {
    ExtraHTML := GetItem(inFile, "Extra", A_Index)
    If (ExtraHTML <> "")
      FileAppend, %ExtraHTML%`n , %outFile%
  }
  
  If (Extras > 0)
    FileAppend, `t`t</section><br />`n , %outFile%
}

WriteNavigation(inFile, outFile)
{
  Found := 0

  If (StrLen(Navigation) < 1)
  {
    FileMove, %inFile%, %outFile%, 1
    MsgBox, EmptyNav
    Return
  }
  
  Navigation := "`t`t<table>" . Navigation . "</table><br />"
  
  FileDelete, %outFile%
  
  Loop, Read, %inFile%, %outFile%
  {
    if (Found = 1)
    {
      FileAppend, %A_LoopReadLine%`n
      Continue
    }
    
    if (A_LoopReadLine = "<!-- Navigation -->")
    {
      FileAppend, %Navigation%`n
      Found := 1
    }
    else
    {
      FileAppend, %A_LoopReadLine%`n
    }
  }
  
  FileDelete, %inFile%
}
