Class AnalyzeThis.Utils
{

ClassMethod GetRegexLine(pNewLine As %String) As %String
{
	set tNewLine="("
	for i=2:1:$length(pNewLine,"\") {
		set:i>2 tNewLine=tNewLine_"|([\"_$piece(pNewLine,"\",i-1)_"]"
		set tNewLine=tNewLine_"[^\"_$piece(pNewLine,"\",i)_"]"
	}
	for i=2:1:$length(pNewLine,"\") {
		set tNewLine=tNewLine_")"
	}
	Quit "(?s)"_tNewLine_"*("_pNewLine_")"
}

ClassMethod GetRegexProp(pNewLine As %String) As %String
{
	Quit "(""([^""]|(""""))*""(,|"_pNewLine_"))|(([^,""])*(,|"_pNewLine_"))"	
}

}