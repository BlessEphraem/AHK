#Warn All, Off

#Requires Autohotkey v2
;AutoGUI creator: Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter creator: github.com/mmikeww/AHK-v2-script-converter
;EasyAutoGUI-AHKv2 github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2

if A_LineFile = A_ScriptFullPath && !A_IsCompiled
{
	myGui := Constructor()
	myGui.Show("w620 h420")
}

Constructor()
{	
	myGui := Gui()
	ButtonOK := myGui.Add("Button", "x19 y30 w80 h23", "&OK")
	DropDownList1 := myGui.Add("DropDownList", "x324 y53 w120", ["DropDownList", "", ""])
	ButtonOK.OnEvent("Click", OnEventHandler)
	DropDownList1.OnEvent("Change", OnEventHandler)
	myGui.OnEvent('Close', (*) => ExitApp())
	myGui.Title := "Window"
	
	OnEventHandler(*)
	{
		ToolTip("Click! This is a sample action.`n"
		. "Active GUI element values include:`n"  
		. "ButtonOK => " ButtonOK.Text "`n" 
		. "DropDownList1 => " DropDownList1.Text "`n", 77, 277)
		SetTimer () => ToolTip(), -3000 ; tooltip timer
	}
	
	return myGui
}