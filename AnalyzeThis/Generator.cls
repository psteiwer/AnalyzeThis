Class AnalyzeThis.Generator
{

/// This method will go through the entire generation process. Takes in a CSV file
ClassMethod GenerateAll(pFileName, pLineSize, pHasHeaders, pCubeName, pPropertyJSONStreamId, pDataJSONStreamId) As %Status
{
	try {
		// Preparing JSON
		Set ^AnalyzeThis.GenerateTracking($j,1)="Working..."
		set tSC = ##class(AnalyzeThis.UI.Dialog.CSVImport).CSVToJSON(pFileName,.tPropertyJSONStreamId,.tDataJSONStreamId,pLineSize,pHasHeaders)
		// Probably should provide a way to clean these instead of deleting them here
		if pPropertyJSONStreamId'="" {
			// Delete this stream if pPropertyJSONStreamId is populated, it may have updates
			do ##class(%Stream.FileBinary).%DeleteId(tPropertyJSONStreamId)
		}
		if pDataJSONStreamId'="" {
			// This may contain "preview mode" data. Delete it
			do ##class(%Stream.FileBinary).%DeleteId(pDataJSONStreamId)
		}
		Set tPropertyJSONStreamId=pPropertyJSONStreamId
		Set ^AnalyzeThis.GenerateTracking($j,1)=tSC
		if $$$ISERR(tSC) $$$ThrowStatus(tSC)
		
		set tCubeName=$select($G(pCubeName)'="":pCubeName,1:##class(AnalyzeThis.Generator).GenerateCubeName(pFileName))
		
		// Generating Source Class
		Set ^AnalyzeThis.GenerateTracking($j,2)="Working..."
		set tSC=##class(AnalyzeThis.Generator).GenerateSourceClass(tCubeName,tPropertyJSONStreamId)
		Set ^AnalyzeThis.GenerateTracking($j,2)=tSC
		if $$$ISERR(tSC) $$$ThrowStatus(tSC)
		
		// Importing Data
		Set ^AnalyzeThis.GenerateTracking($j,3)="Working..."
		set tSC=##class(AnalyzeThis.Generator).ImportJSONData(tPropertyJSONStreamId, tDataJSONStreamId, tCubeName)
		Set ^AnalyzeThis.GenerateTracking($j,3)=tSC
		if $$$ISERR(tSC) $$$ThrowStatus(tSC)
		
		// Generating Cube
		Set ^AnalyzeThis.GenerateTracking($j,4)="Working..."
		set tSC=##class(AnalyzeThis.Generator).GenerateCube(tCubeName,tPropertyJSONStreamId)
		Set ^AnalyzeThis.GenerateTracking($j,4)=tSC
		if $$$ISERR(tSC) $$$ThrowStatus(tSC)
		
		
		// Populating Cube
		Set ^AnalyzeThis.GenerateTracking($j,5)="Working..."
		set tSC=##class(%DeepSee.Utils).%BuildCube(tCubeName,,0)
		Set ^AnalyzeThis.GenerateTracking($j,5)=tSC
		if $$$ISERR(tSC) $$$ThrowStatus(tSC)
		
		// Generating Sample Dashboard
		Do ##class(AnalyzeThis.UI.CSVImport).AddDetails(tCubeName)
		
		Set ^AnalyzeThis.GenerateTracking($j,6)="Working..."
		set tSC=##class(AnalyzeThis.Generator).GenerateDash(tCubeName)
		Set ^AnalyzeThis.GenerateTracking($j,6)=tSC
		if $$$ISERR(tSC) $$$ThrowStatus(tSC)
	} catch ex {
		set tSC=ex.AsStatus()
	}
	
	// Always clean up streams
	if tPropertyJSONStreamId'="" {
		do ##class(%Stream.FileBinary).%DeleteId(tPropertyJSONStreamId)
	}
	if tDataJSONStreamId'="" {
		do ##class(%Stream.FileBinary).%DeleteId(tDataJSONStreamId)
	}
	quit tSC
}

/// Given a file name, output the resulting cube name
ClassMethod GenerateCubeName(pFileName) As %String
{
	set tName=$zstrip($replace($piece(##class(%File).GetFilename(pFileName),".",1),"DEEPSEE",""),"*PCW")
	
	quit tName
}

/// Given a cube name and Property Stream ID, generate a source class
ClassMethod GenerateSourceClass(pCubeName, pPropertyJSONStreamId) As %Status
{
	set tSC=$$$OK
	
	set tSC=##class(AnalyzeThis.Dashboard.Utils).DeleteAll(pCubeName)
	
	// Take file from request
	set tSC=##class(AnalyzeThis.Generator).JSONToClass(pPropertyJSONStreamId,"AnalyzeThis.Generated."_pCubeName)
	
	quit tSC
}

/// Given a Property Stream ID and a Class Name, generate a Class with the given properties and name
ClassMethod JSONToClass(propertiesJSON As %String, pClassName As %String) As %Status
{
	//Use propertiesJSON to build class
	//Populate with dataJSON
	if ##class(%Dictionary.ClassDefinition).%ExistsId(pClassName) {
		set tSC=##class(%Dictionary.ClassDefinition).%DeleteId(pClassName)
	}
	Set class=##class(%Dictionary.ClassDefinition).%New()
	Set class.Name=pClassName
	Set class.Super="%Persistent"
	Set tempStream=##class(%Stream.FileBinary).%OpenId(propertiesJSON)
	Set dynamicProperties={}.%FromJSON(tempStream)
	Set iter=dynamicProperties.Display.%GetIterator()
	while iter.%GetNext(.key,.value) {
		if dynamicProperties.Ignore.%Get(key) {
			continue
		}
		Set prop=##class(%Dictionary.PropertyDefinition).%New()
		Set prop.Name=value
		Set prop.Type=dynamicProperties.Type.%Get(key)
		If prop.Type="%String" {
			d prop.Parameters.SetAt("","MAXLEN")
		} ElseIf prop.Type="%Integer" {
			set intformat=dynamicProperties.IntFormat.%Get(key)
			set:intformat'="" prop.Type=intformat
			
			if intformat="%Library.Currency" {
				// Add setter method to strip currency signs if included
				set method=##class(%Dictionary.MethodDefinition).%New(class.Name_"||"_prop.Name_"Set")
				set method.Name=prop.Name_"Set"
				set method.FormalSpec = "pVal"
				Set method.ReturnType = "%Status"
				
				Do method.Implementation.WriteLine(" try { set pVal=$zstrip(pVal,""*P"",,"".,"") }")
				Do method.Implementation.WriteLine(" catch ex {  }")
				Do method.Implementation.WriteLine(" set i%"_prop.Name_"=pVal")
				Do method.Implementation.WriteLine(" quit $$$OK")

				Do class.Methods.Insert(method)

			}
		} ElseIf ((prop.Type="%Date") || (prop.Type="%TimeStamp")) {
			set tempFormat=dynamicProperties.DateFormat.%Get(key)
			if tempFormat=5 {
				//Cast back as string until we support partial dates
				set prop.Type="%String"
			} else {
				//Create setter method to translate to $h
				set method=##class(%Dictionary.MethodDefinition).%New(class.Name_"||"_prop.Name_"Set")
				set method.Name=prop.Name_"Set"
				set method.FormalSpec = "pVal"
				Set method.ReturnType = "%Status"
				
				if (prop.Type="%Date") {
					Do method.Implementation.WriteLine(" try { set pVal=$zdh(pVal,"_tempFormat_") }")
				} Else {
					// This is a %TimeStamp type, convert to %Date since %DeepSee.WizardUtils does not handle %TimeStamp
					set prop.Type="%Date"
					Do method.Implementation.WriteLine(" try { set pVal=+$zdth(pVal,"_tempFormat_") }")
				}
				Do method.Implementation.WriteLine(" catch ex {  }")
				Do method.Implementation.WriteLine(" set i%"_prop.Name_"=pVal")
				Do method.Implementation.WriteLine(" quit $$$OK")

				Do class.Methods.Insert(method)
			}
		}
		//if dynamicProperties.Include.%Get(key)="true" {
		d class.Properties.Insert(prop)
		//}
	}
	set tSC=class.%Save()
	set tSC=$system.OBJ.Compile(pClassName,"fck /displayerror=0 /displaylog=0")
	
	quit tSC
}

/// Given a Property Stream ID, Data Stream ID, and a CubeName - populate the source class with data from the stream
ClassMethod ImportJSONData(propertyJSONStreamId As %String, dataJSONStreamId As %String, pCubeName As %String, pCleanFirst As %Boolean = 1) As %Status
{
	set tSC=$$$OK
	
	set tClassName="AnalyzeThis.Generated."_pCubeName
	
	if pCleanFirst {
		set tSC=$classmethod(tClassName,"%DeleteExtent")
	}
	
	set dataJSON=##class(%Stream.FileBinary).%OpenId(dataJSONStreamId)
	set propertyJSON=##class(%Stream.FileBinary).%OpenId(propertyJSONStreamId)
	set dataArray=[].%FromJSON(dataJSON)
	set propertyObj={}.%FromJSON(propertyJSON)
	Set iterArray=dataArray.%GetIterator()
	while iterArray.%GetNext(.key,.val) {
		set obj=$classmethod(tClassName,"%New")
		set iterObj=dataArray.%Get(key).%GetIterator()
		while iterObj.%GetNext(.key2,.val2) {
			//set:propertyObj.Include.%Get(propertyObj.%Get(key2))="true" $property(obj,propertyObj.Display.%Get(propertyObj.%Get(key2)))=val2
			set $property(obj,propertyObj.Display.%Get(propertyObj.Properties.%Get(key2)))=val2
		}
		set tSC= obj.%Save()
	}
	
	quit tSC
}

/// Given a Cube name and a Property Stream ID, generate a cube
ClassMethod GenerateCube(pCubeName, pPropertyJSONStreamId) As %Status
{
	set tSourceClass="AnalyzeThis.Generated."_pCubeName
	set tCubeClass=tSourceClass_"Cube"
	set tCubeName=pCubeName
	
	//Generate DeepSee Cube
	//set st=##class(%DeepSee.WizardUtils).%GenerateCubeDefinition("AnalyzeThis.Generated."_tSourceClass_".Record",tCubeName,tCubeClass)
	set st=##class(%DeepSee.WizardUtils).%GenerateCubeDefinition(tSourceClass,tCubeName,tCubeClass)
	if $$$ISERR(st) quit st
	
	//Compile new cube class
	set st=$System.OBJ.Compile(tCubeClass,"fck /displayerror=0 /displaylog=0")
	if $$$ISERR(st) quit st
	
	set tempStream=##class(%Stream.FileBinary).%OpenId(pPropertyJSONStreamId)
	set propertyObj={}.%FromJSON(tempStream)
	
	//Disable items as needed
	set model=$zobjclassmethod(tCubeClass,"%GetModel")
	for i=1:1:model.dimensions.Count() {
		set tempPos=propertyObj.Properties.%Get(model.dimensions.GetAt(i).name)
		if propertyObj.Include.%Get(tempPos)'="true" {
			set model.dimensions.GetAt(i).disabled=1
		}
	}
	for i=1:1:model.measures.Count() {
		if propertyObj.Include.%Get(propertyObj.Properties.%Get(model.measures.GetAt(i).name))'="true" {
			set model.measures.GetAt(i).disabled=1
		}
		// make measures searchable
		set model.measures.GetAt(i).searchable=1
		set prop=##class(%Dictionary.PropertyDefinition).%OpenId(tSourceClass_"||"_model.measures.GetAt(i).sourceProperty)
		if $isobject(prop) {
			if prop.Type="%Library.Currency" {
					set currency=##class(%SYS.NLS.Locale).%New()
					set model.measures.GetAt(i).formatString=currency.Currency_"#.##;-"_currency.Currency_"#.##;;;"
			}
		}
	}
	set st=##class(%DeepSee.Utils).%SaveCubeDefinition(tCubeClass,,model.description,model)
	if $$$ISERR(st) quit st
	
	
	set st=$System.OBJ.Compile(tCubeClass,"fck /displayerror=0 /displaylog=0")
	quit st
}

/// Given a cube name, generate a Dashboard
ClassMethod GenerateDash(pCubeName) As %Status
{
	Set st=$$$OK
	do ##class(AnalyzeThis.Dashboard.AutoPivot).GenerateSampleDashboards(pCubeName)
	Set dashName="Generated/Samples for "_pCubeName_".dashboard"
	Set st=##class(%DeepSee.Dashboard.Utils).%DashboardExists(dashName)
	quit st
}
}