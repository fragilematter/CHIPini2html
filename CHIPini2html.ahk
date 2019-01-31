#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

FileEncoding, UTF-8-RAW

Loop %0%  ; For each parameter (or file dropped onto a script):
{
  GivenPath := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
  Loop %GivenPath%, 1
    LongPath = %A_LoopFileLongPath%
  ProcessFile(LongPath)
}


ProcessFile(CHIPini) 
{
  fname  := ""
  outDir := ""
  inName := ""
  MediaType := ""
  Categories := []
  
  IniRead, fname, %CHIPini%, Main, Nume
  If (fname = "") || (fname = "ERROR")
  {
    MsgBox, INI parsing failed for %CHIPini%
    Return
  }
  
  HTMLtitle := fname
  
  SplitPath, CHIPini, inName, outDir
  

  
  IniRead, MediaType, %CHIPini%, Main, DVD, CD
  If (MediaType = 1)
    MediaType = DVD
    
  If (MediaType = 0)
  {
    MediaType = CD
  }
    
    If (inName = "Level.ini")
  {
    fname := outDir . "\LVL" . MediaType . fname
    HTMLtitle := "LEVEL " . MediaType . " " . HTMLtitle
  }
  
  If (inName = "Chip.ini")
  {
    fname := outDir . "\" . fname
    HTMLtitle := "CHIP " . MediaType . " " . HTMLtitle
  }
  
  WriteHTMLHeader(fname, HTMLtitle)
  
  Categories := GetCategories(CHIPini, fname)
  
  WriteNavigation(Categories, fname)
  
  GetHighlights(CHIPini, fname)

  Loop % Categories.Length()
    ParseCategory(Categories[A_Index], 1, CHIPini, fname)
    
  WriteHTMLFooter(fname)
}

WriteHTMLHeader(OutFile, HTMLtitle) 
{
  FileAppend, 
(
<!DOCTYPE html>
<html lang="ro">
`t<head>
`t`t<meta charset="utf-8" />
`t`t<meta name="generator" content="Lame AHK CHIP.ini parser by Doru Barbu - http://db.0db.ro" />
`t`t<title>%HTMLtitle%</title>
`t</head>
`t<body>
`t`t<h1>%HTMLtitle%</h1>
`t`t<hr />`n
), %OutFile%.html
  
}

WriteHTMLFooter(OutputFile)
{
  FileAppend, 
(
`t</body>
</html>
), %OutputFile%.html
}

GetHighlights(CHIPini, OutputFile)
{
  Highlight := ""
  Highlights := ""

  IniRead, Highlight, %CHIPini%, Sectiuni, Recomandari
  
  If (Highlight = "") || (Highlight = 0) || (Highlight = "ERROR")
    Return
  
  Loop, 7
  {
    IniRead, Highlight, %CHIPini%, Recomandari, Recomandare%A_Index%
    If (Highlight = "") || (Highlight = "ERROR")
      Continue
      
      Transform, Highlight, HTML, %Highlight%
      
    Highlights := Highlights . "<li>" . Highlight . "</li>"
  }
  
  If (Highlights = "")
    Return
    
  FileAppend, `t`t<section><h1>Highlights</h1><ul>%Highlights%</ul></section>`n 
    , %OutputFile%.html
}

GetCategories(CHIPini, OutputFile)
{
  TestCategory := ""
  Categories := []
  IniRead, TestCategory, %CHIPini%, Butoane__INTERFATA, B1

  If (TestCategory <> "") && (TestCategory <> "ERROR")
    Categories := GetCategoriesByButtons(CHIPini, OutputFile)    
  Else
    Categories := GetCategoriesByHeuristicSearch(CHIPini, OutputFile)
    
  Return Categories
}

GetCategoriesByHeuristicSearch(CHIPini, OutputFile)
{
  Groups := []
  GroupName := ""
  Categories := []
  SubCategories := []
  SubCatName := []

  Loop, Read, %CHIPini%
  {
    If (SubStr(A_LoopReadLine, 1, 1) <> "[")
      Continue
    
    If (A_LoopReadLine = "[Main]")
      Continue
      
    If (A_LoopReadLine = "[Sectiuni]")
      Continue
      
    GroupName := SubStr(A_LoopReadLine, 2, StrLen(A_LoopReadLine) - 2)
    
    Groups.Push(GroupName)
  }

  Loop % Groups.Length()
  {
    GroupName := Groups[A_Index]
    
    ItemCount = 0
    IniRead, ItemCount, %CHIPini%, %GroupName%, Items, 0
    
    SubCatCount = 0
    IniRead, SubCatCount, %CHIPini%, %GroupName%, Domenii, 0
    
    If (ItemCount = "")
      ItemCount = 0
      
    If (SubCatCount = "")
      SubCatCount = 0
      
    If (SubCatCount = 0)
      Continue
    
    ; most groups which have subcategories seem to only use them internally
    If (ItemCount > 0) && (SubCatCount > 0)
      Continue
      
    Loop, %SubCatCount%
    {
      IniRead, SubCatName, %CHIPini%, %GroupName%, Domeniu%A_Index%
      
      If (SubCatName <> "ERROR")
        SubCategories.Push(SubCatName)
    }
  }
  
  ; before adding the real categories, check if we need to add the intro
  
  IniRead, GroupName, %CHIPini%, Main, Intro
  
  If (GroupName <> "") && (GroupName <> "ERROR")
    Categories.Push("Intro")
  
  Loop % Groups.Length()
  {
    GroupName := Groups[A_Index]
    
    If (HasVal(SubCategories, GroupName) > 0)
      Continue
      
    Categories.Push(GroupName)
  }
  
  Return Categories
}

GetCategoriesByButtons(CHIPini, OutputFile)
{
  Categories := []
  Category := ""
  Enabled := ""

  Loop, 7
  {
    IniRead, Category, %CHIPini%, Butoane__INTERFATA, B%A_Index%
    If (Category = "") || (Category = "ERROR")
      Continue

    IniRead, Enabled, %CHIPini%, Sectiuni, %Category%
    If (Enabled = "") || (Enabled = "ERROR") || (Enabled = 0)
      Continue

    Categories.Push(Category)

  }
  
  Return Categories
}

WriteNavigation(Categories, OutputFile)
{
  Category := ""
  CategHTML := ""
  CategURL := ""

  Loop % Categories.Length()
  {
    Category := Categories[A_Index]
    
    If (Category = "Remote")
      Continue
    
    Transform, Category, HTML, %Category%
    CategURL := StrReplace(Category, A_Space, "%20")
    
    CategHTML = %CategHTML%<th><a href="#%CategURL%">%Category%</a></th>
  }
  
  If (CategHTML <> "")
    FileAppend, `t`t<table><tr>%CategHTML%</tr></table>`n, %OutputFile%.html
}

GetSubcategories(CatName, SubCatCount, CHIPini)
{
  Subcategories := []
  Subcategory := ""
  
  Loop % SubCatCount
  {
    IniRead, Subcategory, %CHIPini%, %CatName%, Domeniu%A_Index%
    
    If (Subcategory = "ERROR")
      Subcategory := ""
      
    Transform, Subcategory, HTML, %Subcategory%
    Subcategories.Push(Subcategory)
  }
  
  Return Subcategories
}

ParseCategory(CatName, CatLevel, CHIPini, OutputFile)
{
  ItemCount = 0
  IniRead, ItemCount, %CHIPini%, %CatName%, Items, 0
  
  SubCatCount = 0
  IniRead, SubCatCount, %CHIPini%, %CatName%, Domenii, 0

  If (ItemCount = "")
    ItemCount = 0
    
  If (SubCatCount = "")
    SubCatCount = 0
    
  If (CatName <> "Intro") && (ItemCount = 0) && (SubCatCount = 0)
    Return
    
  Transform, CatNameHTML, HTML, %CatName%
  CatNameURL := StrReplace(CatNameHTML, A_Space, "%20")
  
  If (CatLevel = 1) && (CatName = "Intro")
  {
    IniRead, Intro, %CHIPini%, Main, Intro
    
    If (Intro <> "") && (Intro <> "ERROR")
    {
      FileAppend, `t`t<section id="%CatNameURL%"><h2>%CatNameHTML%</h2>`n
        , %OutputFile%.html
      Transform, Intro, HTML, %Intro%
      FileAppend, `t`t<p>%Intro%</p>`n, %OutputFile%.html
    }
    Return
  }  
  
  If (CatLevel = 1)
    FileAppend, `t`t<section id="%CatNameURL%"><h2>%CatNameHTML%</h2>`n
      , %OutputFile%.html
  Else
  {
    HeadingLevel := CatLevel + 1
    FileAppend, `t`t<h%HeadingLevel%>%CatNameHTML%</h%HeadingLevel%>`n, %OutputFile%.html
  }

  Subcategories := []
  Subcategories := GetSubcategories(CatName, SubCatCount, CHIPini)
    
  If (ItemCount > 0)
    GetItems(CatName, ItemCount, Subcategories, CHIPini, OutputFile)

  If (ItemCount = 0) && (SubCatCount > 0)
  {
    SubCatName := ""

    Loop % SubCatCount
    {
      SubCatName := Subcategories[A_Index]
      
      If (SubCatName = "") Or (SubCatName = "ERROR")
        Continue
      
      ParseCategory(SubCatName, CatLevel + 1, CHIPini, OutputFile)
    }
  }
  
  If (CatLevel = 1)
  {
    FileAppend, `t`t</section>`n, %OutputFile%.html
  }
}

GetItems(CatName, ItemCount, Subcategories, CHIPini, OutputFile)
{
  ItemName := ""
  ItemDescription := ""
  ItemDirectory := ""
  ItemBinary := ""
  ItemCategory = 0
  ItemLineTwo := ""
    
  Loop % ItemCount
  {
    IniRead, ItemName, %CHIPini%, %CatName%, nume%A_Index%
    IniRead, ItemDescription, %CHIPini%, %CatName%, desc%A_Index%
    IniRead, ItemDirectory, %CHIPini%, %CatName%, dir%A_Index%
    IniRead, ItemBinary, %CHIPini%, %CatName%, inst%A_Index%
    IniRead, ItemCategory, %CHIPini%, %CatName%, dom%A_Index%, 0
    
    If (ItemName = "ERROR")
      Continue
      
    If (ItemBinary = "ERROR")
      IniRead, ItemBinary, %CHIPini%, %CatName%, exe%A_Index%
      
    If (ItemBinary = "ERROR")
      IniRead, ItemBinary, %CHIPini%, %CatName%, read%A_Index%
      
    If (ItemBinary = "ERROR")
      ItemBinary := ""
      
    If (ItemDescription = "ERROR")
      ItemDescription := ""
      
    Transform, ItemName, HTML, %ItemName%
    Transform, ItemDescription, HTML, %ItemDescription%
    Transform, ItemDirectory, HTML, %ItemDirectory%
    Transform, ItemBinary, HTML, %ItemBinary%
    
    ItemLineTwo := ""
    If (ItemCategory <> 0) && (Subcategories[ItemCategory] <> "")
      ItemLineTwo := "<b>" . Subcategories[ItemCategory] . "</b> - "
    
    If (ItemDescription <> "")
      ItemDescription := ItemDescription . "<br />"
      
    ItemLineTwo := ItemLineTwo . "<i>" . ItemDirectory . "\" . ItemBinary . "</i>"
      
    FileAppend, 
(
`t`t`t<dl>
`t`t`t`t<dt>%ItemName%</dt>
`t`t`t`t<dd>%ItemDescription%%ItemLineTwo%</dd>
`t`t`t</dl>`n
)
    , %OutputFile%.html
  }
}

; HasVal by jNizM
; https://autohotkey.com/boards/viewtopic.php?p=109617&sid=a057c8ab901a3ab88f6304b71729c892#p109617
HasVal(haystack, needle) {
    for index, value in haystack
        if (value = needle)
            return index
    if !(IsObject(haystack))
        throw Exception("Bad haystack!", -1, haystack)
    return 0
}
