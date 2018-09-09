Class AnalyzeThis.Utils
{

ClassMethod GetNextRegex(ByRef pMatch,ByRef pResult,pIncludeTerm As %Boolean = 1) As %Boolean
{
	Set pResult=""
	
	If '$IsObject(pMatch) {
		Quit 0
	}
	
	Set tStart=$Case(pMatch.End,-2:1,:pMatch.End)
	Set tBool=pMatch.Locate()
	Quit:tBool=0 tBool
	Set tEnd=pMatch.End
	
	Set pResult=$e(pMatch.Text,tStart,$select(pIncludeTerm=1:pMatch.End,1:pMatch.Start)-1)
	
	Quit tBool
}

ClassMethod GetRegexLine(pNewLine As %String) As %String
{
	Quit $replace(pNewLine,"\","\\")_"(?=(?:(?:\\.|[^""\\])*""(?:\\.|[^""\\])*"")*(?:\\.|[^""\\])*\Z)"
	
}

ClassMethod GetRegexProp(pNewLine As %String) As %String
{
	Quit "("_$replace(pNewLine,"\","\\")_"|,)"_"(?=(?:(?:\\.|[^""\\])*""(?:\\.|[^""\\])*"")*(?:\\.|[^""\\])*\Z)"
}

}