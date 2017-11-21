TrimClipboard() {
    linesArray := StrSplit(clipboard, "`n", "`r")

    newClip := ""

    for index, element in linesArray {   
        newClip .= trim(element) . "`r`n" 
    }

    clipboard := SubStr(newClip, 1, -2)
}

#IfWinActive ahk_class Notepad++
^c::
    Send, ^{sc02e}
    Clipwait
    TrimClipboard()
return

^x::
    Send, ^{sc02d}
    Clipwait
    TrimClipboard()
return