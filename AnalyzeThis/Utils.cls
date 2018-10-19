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

ClassMethod DetermineNewLine(pString As %String) As %String
{
	set tNewLine=$c(13)_$c(10)
	
	if ($find(pString,$c(10))=0)&&($find(pString,$c(13))>0) {
		set tNewLine=$c(13)
	} elseif ($find(pString,$c(10))>0)&&($find(pString,$c(13))=0) {
		set tNewLine=$c(10)
	} elseif ($find(pString,$c(10))>($find(pString,$c(13))+1)) {
		// Assume that headers do not have $c(13) or $c(10)
		set tNewLine=$c(13)
	}
	
	quit tNewLine
}

ClassMethod ReadStream(ByRef pStream, pString As %String = "") As %String
{
	set tRet=pString_pStream.Read()
	
	set tQuotes=$length(tRet,"""")-1
	
	if tQuotes#2 {
		// This means there is an odd number of quotes.
		// Continue to read until a single quote is found
		set tDone=0
		while 'tDone {
			set tNext=pStream.Read(1)
			set tRet=tRet_tNext
			if tNext="""" {
				set tNext=pStream.Read(1)
				set tRet=tRet_tNext
				if tNext'="""" {
					// We are done, quotes are balanced
					set tDone=1
				}
			}
		}
	} 
	
	quit tRet
}

/// Given a cube name, refresh the data from the data source
ClassMethod RefreshCube(pCubeName As %String, pLineSize As %Integer = 0) As %Status
{
	set st=$$$OK
	set version=$O(^AnalyzeThis.ImportCSV(pCubeName,""))
	if version'="" {
		set sourceType=$O(^AnalyzeThis.ImportCSV(pCubeName,version,""))
		if sourceType="CSV" {
			set fileLocation=^AnalyzeThis.ImportCSV(pCubeName,version,sourceType)
			set st=##class(AnalyzeThis.UI.Dialog.CSVImport).CSVToJSON(fileLocation,.tPropertyJSONStreamId,.tDataJSONStreamId,pLineSize)
			set st=##class(AnalyzeThis.Utils).RefreshJSONData(tDataJSONStreamId,pCubeName)
			
			set st=$system.DeepSee.BuildCube(pCubeName)
		}
	}
	quit st
}

/// Given a Property Stream ID, Data Stream ID, and a CubeName - populate the source class with data from the stream
ClassMethod RefreshJSONData(dataJSONStreamId As %String, pCubeName As %String) As %Status
{
	set tSC=$$$OK
	
	set tClassName="AnalyzeThis.Generated."_pCubeName
	set tSC=$classmethod(tClassName,"%DeleteExtent")
	
	// Get property name array
	do ##class(AnalyzeThis.Utils).GetPropertyNames(tClassName,.propNames)
	
	set dataJSON=##class(%Stream.FileBinary).%OpenId(dataJSONStreamId)
	set dataArray=[].%FromJSON(dataJSON)
	Set iterArray=dataArray.%GetIterator()
	while iterArray.%GetNext(.key,.val) {
		set obj=$classmethod(tClassName,"%New")
		set iterObj=dataArray.%Get(key).%GetIterator()
		set propCount=0
		while iterObj.%GetNext(.key2,.val2) {
			set $property(obj,propNames($i(propCount)))=val2
		}
		set tSC= obj.%Save()
	}
	
	quit tSC
}

/// Given a class name, get the property names by order of SqlColumnNumber
ClassMethod GetPropertyNames(pClassName As %String, Output pPropNames) As %Status
{
	set sql="SELECT Name FROM %Dictionary.PropertyDefinition WHERE parent=? ORDER BY SqlColumnNumber"
	set sqlrs=##class(%SQL.Statement).%ExecDirect(,sql,pClassName)
	
	while sqlrs.%Next() {
		set pPropNames($i(pPropNames))=sqlrs.Name
	}
	
	quit $$$OK
}

}