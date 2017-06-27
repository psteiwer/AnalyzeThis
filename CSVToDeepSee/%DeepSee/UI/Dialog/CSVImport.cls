/// Created using the page template: Default
Class %DeepSee.UI.Dialog.CSVImport Extends %CSP.UI.Portal.Dialog.WizardTemplate [ System = 4 ]
{

/// This is the temporary file name we saved on remote server, only saved when Input Type is LOCAL.
Property LOCALFILENAME As %ZEN.Datatype.string;

/// If greater than this size and user is importing Sequential file (%GO) then show content 
/// will not be available.
Parameter CheckMaxSize = 10000000;

Property ReadSize As %Integer [ InitialExpression = 50000000 ];

Property LineSize As %Integer [ InitialExpression = 10000 ];

Property hasHeaders As %ZEN.Datatype.string [ InitialExpression = 1 ];

Property FileName As %String;

Property SourceClass As %String;

Property CubeName As %String;

Property Version [ Final, InitialExpression = 1 ];

Property propertyJSONStreamID As %String;

Property dataJSONStreamID As %String;

Property TEST As %String;

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
#htmlContent {
	width: 100%;	
}
/* Progress message style */
.progress { 
	color: green; 
	font-weight: bold;
}
/* style for title instructions */
div.Description	{
	font-size: 0.9em; 
	padding: 5px;
}
table.page {
	table-layout:fixed;	
}
/* style for import content table */
table.ContentTable	{ 
	font-family: Arial, Helvetica, sans-serif;
	border: 1px #888888 solid;
}
table.ContentTable th { 
	font-size: 12px;
	font-weight: bold;		
	background:white; 
	color: #888888;
	text-align: center;
	padding: 0 2px 0 2px;
}
table.ContentTable tr.LiteRow { background: white; font-size: 11px;}
table.ContentTable tr.DarkRow { background: #F1F0E7; font-size: 11px;}
table.ContentTable td { padding-left:2px; padding-right:2px; font-size: 11px; }
</style>
}

XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" >
<html id="header" OnDrawContent="%DrawTitle" />
<pane paneName="dialogBody" id="body"/>
<hgroup id="footer" width="100%" cellAlign="right">
<hgroup id="buttonHolder" cellAlign="right">
<button id="btnBack" controlClass="commandButtonDisabled" caption="Back" onclick="zenPage.previousPage();" disabled="true"/>
<spacer width="10" />
<button id="btnGoDash" controlClass="commandButtonDisabled" caption="Sample Dashboard" onclick="zenPage.seeDash();" disabled="true" hidden="true"/>
<spacer width="10" />
<button id="btnScoreDash" controlClass="commandButtonDisabled" caption="Sample ScoreCard" onclick="zenPage.seeScoreCard();" disabled="true" hidden="true"/>
<spacer width="10" />
<button id="btnGoStats" controlClass="commandButtonDisabled" caption="Cube Statistics" onclick="zenPage.nextPage();" disabled="true" hidden="true"/>
<spacer width="10" />
<button id="btnDone" controlClass="commandButton" caption="Done" onclick="zenPage.firePopupAction('okay','hi');" hidden="true" />
<button id="btnNext" controlClass="commandButtonDisabled" caption="Next" onclick="zenPage.nextPage();" disabled="true"/>
<button id="btnFinish" controlClass="commandButtonDisabled" caption="Import" onclick="zenPage.doImportJSON();" disabled="true" hidden="true"/>
<spacer width="10" />
<button id="btnCancel" controlClass="commandButton" caption="Cancel" onclick="zenPage.dialogCancel();" />
</hgroup>
</hgroup>
</page>
}

/// This XML block defines the contents of this pane.
XData dialogBody [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane id="body" cellStyle="padding-left:10px;">
<label id="idRespond" enclosingClass="note" containerStyle="padding-top:10px;padding-left:4px;" hidden="true"/>
<tabGroup id="tabGroup">

<!-- First Page -->
<tab id="tab1" enclosingStyle="padding-top:20px;" cellStyle="padding-bottom:10px;">
 <html OnDrawContent="DrawPageTitle" seed="1"/>
 
 <radioSet id="InputType" name="InputType" label="The import file resides on" valueList="REMOTE,LOCAL" 
 onclick="zenPage.doLocationChange(zenThis.getValue());" value="REMOTE"/>
 
 <hgroup id="idInstructions" cellVAlign="bottom" enclosingStyle="padding-top:10px;">
<label id="Instructions" value="Please ensure the CSV file name starts with a letter"/>
</hgroup>
<hgroup id="idRemoteFile" cellVAlign="bottom" enclosingStyle="padding-top:20px;" >
<text id="FileName" size="70" label="Enter the path and name of the import file:" onchange="zenPage.UpdateFileName(zenThis.getValue());"/>
<button caption="Browse..." containerStyle="padding-left:2px;" onclick="zenPage.browseSelect('FileName');"/>
</hgroup>
<fileUpload id="LocalFile" name="File" label="Select the path and name of the import file:" size="70" hidden="true" onchange="zenPage.selectLocalFile();"/>

<checkbox id="chkHeaders" caption="This file has a header row" value="1" onchange="zenPage.UpdateHasHeaders(zenThis.getValue());" captionClass="zenLabel" hint=" (Check box to autmatically assign property names.)"/>
<checkbox id="chkRecurse" caption="Include subdirectories" captionClass="zenLabel" value="1" hidden="true"/>
<expando caption="Advanced" animate="true" expanded="false">
<vgroup enclosingStyle="padding-top:10px;">
<label id="LimitLabel" value="Limit the amount of data to read" hint="(Data load will stop after first limit is reached)"/>
<hgroup>
<text id="ReadSize" value="50" size="15" label="Read Limit (MB)" onchange="zenPage.UpdateReadSize(zenThis.getValue());"/>
<text id="LineSize" value="10000" size="15" label="Line Limit" onchange="zenPage.UpdateLineSize(zenThis.getValue());"/>
</hgroup>
</vgroup>

<vgroup enclosingStyle="padding-top:10px;">
<label id="ChangeNameLabel" value="Change the name of the cube"/>
<hgroup>
<text id="CubeName" size="100" label="CubeName" value="#(%page.CubeName)#" onchange="zenPage.UpdateCubeName(zenThis.getValue());"/>
</hgroup>
</vgroup>
</expando>
</tab>

<!-- Second Page -->
<tab id="tab2" enclosingStyle="padding-top:20px;" cellStyle="padding-bottom:10px;">
<group>
<html OnDrawContent="DrawSortPageTitle" seed="2"/>
<html id="htmlContent" OnDrawContent="PropertyCheckJSON" seed="" onrefresh="zenPage.drawDone(2);"/>
<label id="idProgress2" label="Loading File Content..." labelClass="progress"/>
</group>
</tab>

<!-- Third Page -->
<tab id="tab3" enclosingStyle="padding-top:20px;" cellStyle="padding-bottom:10px;">
<html OnDrawContent="DrawPageTitle" seed="3"/>
<html id="htmlContent3" onrefresh="zenPage.updateProgressJSON();"/>
<vgroup>
<hgroup>
<vgroup width="250" align="left">
<label value="Generating Source Class:"/>
<label value="Importing Data:"/>
<label value="Generating DeepSee Cube:"/>
<label value="Populating DeepSee Cube:"/>
<label value="Generating Sample Dashboard:"/>
</vgroup>
<vgroup width="275" labelPosition="left">
<label id="progress1" value="Not Yet Started"/>
<label id="progress2" value="Not Yet Started"/>
<label id="progress3" value="Not Yet Started"/>
<label id="progress4" value="Not Yet Started"/>
<label id="progress5" value="Not Yet Started"/>
</vgroup>
</hgroup>
</vgroup>
</tab>

<!-- Fourth Page -->
<tab id="tab4" enclosingStyle="padding-top:20px;" cellStyle="padding-bottom:10px;">
<html OnDrawContent="DrawPageTitle" seed="4"/>
<html id="htmlContent4" onrefresh="zenPage.drawStats();"/>
<vgroup>
<html id="statsTable"/>
</vgroup>
</tab>
</tabGroup>
</pane>
}

Method UpdateReadSize(value) [ Internal, ZenMethod ]
{
	set ..ReadSize=value*100000
}

Method UpdateLineSize(value) [ Internal, ZenMethod ]
{
	set ..LineSize=value
}

Method UpdateHasHeaders(value) [ Internal, ZenMethod ]
{
	set ..hasHeaders=value
}

Method UpdateFileName(value) [ Internal, ZenMethod ]
{
	set ..FileName=value
}

ClientMethod selectLocalFile() [ Internal, Language = javascript ]
{
	var fileName = zen("LocalFile").getValue();
	zen("btnNext").setDisabled(fileName=="");
	if (fileName!="") {
		zen("btnNext").setProperty('controlClass','commandButton');
	} else {
		zen("btnNext").setProperty('controlClass','commandButtonDisabled');
	}
}

Method seeDash() [ Internal, ZenMethod ]
{
	Set pcube=..CubeName
	&JS<zenPage.firePopupAction('dash','#(pcube)#');>
}

Method seeScoreCard() [ Internal, ZenMethod ]
{
	Set pcube=..CubeName
	&JS<zenPage.firePopupAction('score','#(pcube)#');>
}

/// User changed to pick file between Remote and Local
ClientMethod doLocationChange(flag) [ Internal, Language = javascript ]
{
	if (flag == "LOCAL") {
		zen("idRemoteFile").setHidden(true);
		zen("LocalFile").setHidden(false);
	} else {
		zen("idRemoteFile").setHidden(false);
		zen("LocalFile").setHidden(true);
	}
}

/// Start the Import
ClientMethod doImport() [ Language = javascript ]
{
	//Before processing, make sure all property names are unique
	var count=1
	var ok=1
	var test=[];
	while (document.getElementById("propName"+count)!=null) {
		document.getElementById("propName"+count).style=""
		if (test[document.getElementById("propName"+count).value]!=null) {
			document.getElementById("propName"+test[document.getElementById("propName"+count).value]).style.border="2px solid #FF0000"
			document.getElementById("propName"+count).style.border="2px solid #FF0000"
			ok=0
		}
		test[document.getElementById("propName"+count).value]=count
		count+=1
	}
	
	if (!ok) {
		alert("Property names not unique.");
		return
	}
	
	//First thing we must do is generate the new temp file.
	//The new file will be our generated header and the original data
	
	pNames=[]
	pTypes=[]
	pDateFormats=[]
	pIntFormats=[]
	pIncluded=[]
	count=1
	while (document.getElementById("propName"+count)!=null) {
		pNames.push(document.getElementById("propName"+count).value.replace(/\s+/g, ''))
		pTypes.push(document.getElementById("propType"+count).value)
		pDateFormats.push(document.getElementById("dateFormat"+count).value)
		pIntFormats.push(document.getElementById("intFormat"+count).value)
		pIncluded.push(document.getElementById("includeCol"+count).checked)
		
		count+=1
	}
	
	inforow="--ROW("
	for (i=0;i<count-1;i++) {
		if (i!=0) {
			inforow=inforow+","
		}
		if (!/^[A-Za-z][A-Za-z0-9 -]*$/.test(pNames[i].substr(0,1))) {
			inforow=inforow+"n"
		}
		if (zenPage.CheckSQLReserved(pNames[i])) {
			pNames[i]="SQL"+pNames[i]
		}
		inforow=inforow+pNames[i]
		if (!pIncluded[i]) {
			inforow=inforow+"eXcLuDe"
		}
		if (pTypes[i]=="String") {
			inforow=inforow+" varchar(32000)"
		} else if (pTypes[i]=="Integer") {
			if (pIntFormats[i]=="Number") {
				inforow=inforow+" number"
			} else {
				inforow=inforow+" %Library.Currency"
			}
		} else if (pTypes[i]=="Date") {
			if(pDateFormats[i]==5)
			{
				inforow=inforow+" varchar(32000)"
			}
			else
			{
				inforow=inforow+"DaTeDs"+pDateFormats[i]+" varchar(32000)"
			}
		}
	}
	inforow=inforow+")"
	
	//Call method to create temp file
	status=zenPage.AddInfoRow(zen("FileName").getValue(),inforow)
	if (status.includes("ERROR #")) {
		alert(status)
		return
	}
	
	zenPage.nextPage();
	zen("btnDone").setHidden(false);
	zenPage.updateState();
}

/// Start the Import
ClientMethod doImportJSON() [ Language = javascript ]
{
	//Before processing, make sure all property names are unique
	var count=1
	var ok=1
	var test=[];
	while (document.getElementById("propName"+count)!=null) {
		document.getElementById("propName"+count).style=""
		if (test[document.getElementById("propName"+count).value]!=null) {
			document.getElementById("propName"+test[document.getElementById("propName"+count).value]).style.border="2px solid #FF0000"
			document.getElementById("propName"+count).style.border="2px solid #FF0000"
			ok=0
		}
		test[document.getElementById("propName"+count).value]=count
		count+=1
	}
	
	if (!ok) {
		alert("Property names not unique.");
		return
	}
	
	// Update JSON property information with type and include info
	count=0
	while (document.getElementById("propName"+count)!=null) {
		zenPage.updateProperties(count,"Display",document.getElementById("propName"+count).value.replace(/\s+/g, ''))
		zenPage.updateProperties(count,"Type",document.getElementById("propType"+count).value)
		zenPage.updateProperties(count,"DateFormat",document.getElementById("dateFormat"+count).value)
		zenPage.updateProperties(count,"IntFormat",document.getElementById("intFormat"+count).value)
		zenPage.updateProperties(count,"Include",document.getElementById("includeCol"+count).checked)
		
		count+=1
	}
	
	zenPage.nextPage();
	zen("btnDone").setHidden(false);
	zenPage.updateState();
}

Method updateProperties(pId As %String, pProp As %String, pVal As %String) As %Status [ ZenMethod ]
{
	set tempStream=##class(%Stream.FileBinary).%OpenId(..propertyJSONStreamID)
	set prop={}.%FromJSON(tempStream)
	set st=$property(prop,pProp).%Set(pId,pVal)
	if pProp="Display" {
		// This will allow us to get position from either display or logical name
		d prop.%Set(pVal,pId)
	}
	set tempStream=##class(%Stream.FileBinary).%New()
	d prop.%ToJSON(.tempStream)
	d tempStream.%Save()
	set ..propertyJSONStreamID=tempStream.%Id()
	quit st
}

ClassMethod FixLineTerminators(inStream As %Stream.FileCharacter, ByRef outStream As %Stream.FileCharacter, ByRef numLines As %Integer = 0) As %Stream.FileCharacter
{
	set st=$$$OK

	try{
		set outStream=##class(%Stream.FileCharacter).%New()
	 	set flip=0
	 	set done=0
	 	while 'inStream.AtEnd && 'done {
		 	set str=inStream.Read()
		 	set startflip=flip
		 	for i=1:1:$length(str,"""") {
			 	if startflip {
				 	if i#2 {
					 	//In quotes
					 	set $piece(str,"""",i)=$replace($piece(str,"""",i),$c(13,10)," ")
					 	set $piece(str,"""",i)=$replace($piece(str,"""",i),$c(13)," ")
					 	set $piece(str,"""",i)=$replace($piece(str,"""",i),$c(10)," ")
					 	set flip=1
				 	} else {
					 	//Out of Quotes
					 	set $piece(str,"""",i)=$replace($piece(str,"""",i),$c(13,10),$c(10))
					 	set $piece(str,"""",i)=$replace($piece(str,"""",i),$c(13),$c(10))
					 	set flip=0
				 	}
			 	} else {
				 	if i#2 {
					 	//Out of Quotes
					 	set $piece(str,"""",i)=$replace($piece(str,"""",i),$c(13,10),$c(10))
					 	set $piece(str,"""",i)=$replace($piece(str,"""",i),$c(13),$c(10))
					 	set flip=0
				 	} else {
					 	//In quotes
					 	set $piece(str,"""",i)=$replace($piece(str,"""",i),$c(13,10)," ")
					 	set $piece(str,"""",i)=$replace($piece(str,"""",i),$c(13)," ")
					 	set $piece(str,"""",i)=$replace($piece(str,"""",i),$c(10)," ")
					 	set flip=1
				 	}
			 	}
		 	}
		 	if outStream.Size>50000000 {
		 		d outStream.Write($e(str,0,$find(str,$c(10))))
		 		set done=1
		 	} else
		 	{
			 	d outStream.Write(str)
		 	}
		 	set numLines=$increment(numLines,$length(str,$c(10)))
	 	}
	 	d outStream.Rewind()
	} catch e {
		set st=e.AsStatus()
	}
 	quit st
}

ClassMethod CheckSQLReserved(pString As %String) As %Boolean [ ZenMethod ]
{
	quit $system.SQL.IsReservedWord(pString)
}

ClassMethod AddInfoRow(pFileName As %String, pInfoRow As %String) As %Status [ ZenMethod ]
{
	set sc=$$$OK
	set file=##class(%Stream.FileCharacter).%New()
	if $length(pFileName,"/")>$length(pFileName,"\") {
 		Set pFileName=$zu(168)_$piece($piece(pFileName,"/",*),".",1)_"DEEPSEE."_$piece(pFileName,".",2)
	} else {
 		Set pFileName=$zu(168)_$piece($piece(pFileName,"\",*),".",1)_"DEEPSEE."_$piece(pFileName,".",2)
	}
	set sc=file.LinkToFile(pFileName)
 	quit:$$$ISERR(sc) sc
	set temp=##class(%Stream.FileCharacter).%New()
 	set sc=temp.CopyFrom(file)
 	quit:$$$ISERR(sc) sc
 	
 	d temp.ReadLine()
 	d file.WriteLine(pInfoRow)
 	
 	while 'temp.AtEnd {
	 	set text=temp.Read()
	 	d file.Write(text)
 	}
 	
 	set sc=file.%Save()
	
	Quit sc
}

ClassMethod CreateTempFile(pFileName As %String, ByRef outFile, ByRef outFileName = "", pMaxReadSize As %Integer, pMaxLineSize As %Integer) As %Status
{
	set sc=$$$OK
	set outFile=##class(%Stream.FileCharacter).%New()
	if $length(pFileName,"/")>$length(pFileName,"\") {
 		Set outFileName=$zu(168)_$piece($piece(pFileName,"/",*),".",1)_"DEEPSEE."_$piece(pFileName,".",2)
	} else {
 		Set outFileName=$zu(168)_$piece($piece(pFileName,"\",*),".",1)_"DEEPSEE."_$piece(pFileName,".",2)
	}
	set sc=outFile.LinkToFile(outFileName)
	quit:$$$ISERR(sc) sc
	set sc=outFile.Clear()
	quit:$$$ISERR(sc) sc
 	
	set oldFile=##class(%Stream.FileCharacter).%New()
 	Set sc=oldFile.LinkToFile(pFileName)
 	quit:$$$ISERR(sc) sc
 	
 	set sc=##class(%DeepSee.UI.Dialog.CSVImport).FixLineTerminators(oldFile,.tempStream,.linecount)
 	
 	quit:$$$ISERR(sc) sc
 	
 	/*
 	quit:$length(pInfoRow)>32000 $$$ERROR($$$GeneralError,"Header row exceeds 32,000 characters")
 	
 	d outFile.WriteLine(pInfoRow)
 	d tempStream.ReadLine()
 	*/
 	
	set line=tempStream.ReadLine()
	set count=0
	while (line'="") && (outFile.Size<pMaxReadSize) && (count<=pMaxLineSize) {
	 	if $length(line)<32000 {
 			d outFile.WriteLine(line)
	 	} else {
		 	//Line too long, ignoring
	 	}
 	
		Set line=tempStream.ReadLine()
		set count=$i(count)
	}
	quit:$$$ISERR(sc) sc
	
	
	set sc= outFile.%Save()
	quit:$$$ISERR(sc) sc
	quit sc
}

/// Update the state of the template buttons.
/// Subclasses should call this method when they need to 
/// update the state of the footer buttons.
ClientMethod updateState() [ Language = javascript ]
{
	var btnBack = zen('btnBack');
	var btnNext = zen('btnNext');
	var btnFinish = zen('btnFinish');
	var btnGoStats = zen('btnGoStats');
	var btnHelp = zen('btnHelp');
	var btnSubmit = zen('btnSubmit');
	var multi = this.hasMultiplePages();

	if (btnBack) {
		btnBack.setProperty('hidden',!this.canGoBack);
		btnBack.setProperty('disabled',!this.canGoBack());
		btnBack.setProperty('controlClass',	(this.canGoBack() ? 'commandButton' :'commandButtonDisabled'));
	}
	if (btnNext) {
		btnNext.setProperty('hidden',!this.canGoNext());
		btnNext.setProperty('disabled',!this.canGoNext());
		btnNext.setProperty('controlClass',	(this.canGoNext() ? 'commandButton' :'commandButtonDisabled'));
	}
	if (btnFinish) {
		btnFinish.setProperty('disabled',!this.canFinish());
		btnFinish.setProperty('hidden',!this.canFinish());
		btnFinish.setProperty('controlClass', (this.canFinish() ? 'commandButton' :'commandButtonDisabled'));	
	}
	if (btnGoStats) {
		btnGoStats.setProperty('disabled',this.canStat());
		btnGoStats.setProperty('hidden',!this.canStat());
		btnGoStats.setProperty('controlClass', (this.canStat() ? 'commandButton' :'commandButtonDisabled'));	
	}
	

	
	/*
	// special for Import on this page. Hide regular Next and show Submit Next for LOCAL.
	if (zen("InputType").getValue()=="LOCAL") {
		btnSubmit.setProperty('disabled',true);
		btnSubmit.setProperty('controlClass', 'commandButtonDisabled');
		btnNext.setProperty('hidden',true);
	} else {
		btnNext.setProperty('hidden',false);
	}
	*/
}

ClientMethod updateProgress() [ Language = javascript ]
{
	zenPage.getComponentById("progress1").setValue("In Progress...")
	zenPage.getComponentById("progress1").setValue("Completed")
	
	zenPage.getComponentById("progress2").setValue("In Progress...")
	status=zenPage.GenerateSourceClass(zen('FileName').getValue())
	if (status!=1 && status!="") {
		zenPage.getComponentById("progress2").setValue(status)
		return
	} else {
		zenPage.getComponentById("progress2").setValue("Completed")
	}
	zenPage.getComponentById("progress3").setValue("In Progress...")
	status=zenPage.GenerateCube()
	if (status!=1 && status!="") {
		zenPage.getComponentById("progress3").setValue(status)
		return
	} else {
		zenPage.getComponentById("progress3").setValue("Completed")
	}
	
	zenPage.getComponentById("progress4").setValue("In Progress...")
	status=zenPage.BuildCube()
	if (status!=1 && status!="") {
		zenPage.getComponentById("progress4").setValue(status)
		return
	} else {
		zenPage.getComponentById("progress4").setValue("Completed")
		zenPage.getComponentById("btnGoStats").setProperty('disabled',0);
		zenPage.getComponentById("btnGoStats").setProperty('hidden',0);
		zenPage.getComponentById("btnGoStats").setProperty('controlClass', (1 ? 'commandButton' :'commandButtonDisabled'));	
		zenPage.AddDetails(zen('FileName').getValue())
	}
	
	zenPage.getComponentById("progress5").setValue("In Progress...")
	status=zenPage.GenerateDash()
	if (status!=1 && status!="") {
		zenPage.getComponentById("progress5").setValue(status)
		return
	} else {
		zenPage.getComponentById("progress5").setValue("Completed")
		zenPage.getComponentById("btnGoDash").setProperty('disabled',0);
		zenPage.getComponentById("btnGoDash").setProperty('hidden',0);
		zenPage.getComponentById("btnGoDash").setProperty('controlClass', (1 ? 'commandButton' :'commandButtonDisabled'));	
		status=zenPage.ScoreCardExists()
		if (status!=1 && status !=""){
		} else {
		zenPage.getComponentById("btnScoreDash").setProperty('disabled',0);
		zenPage.getComponentById("btnScoreDash").setProperty('hidden',0);
		zenPage.getComponentById("btnScoreDash").setProperty('controlClass', (1 ? 'commandButton' :'commandButtonDisabled'));	
		}	
	}
}

ClientMethod updateProgressJSON() [ Language = javascript ]
{
	zenPage.getComponentById("progress1").setValue("In Progress...")
	status=zenPage.GenerateSourceClassJSON()
	zenPage.getComponentById("progress1").setValue("Completed")
	
	zenPage.getComponentById("progress2").setValue("In Progress...")
	status=zenPage.ImportDataJSON()
	if (status!=1 && status!="") {
		zenPage.getComponentById("progress2").setValue(status)
		return
	} else {
		zenPage.getComponentById("progress2").setValue("Completed")
	}
	zenPage.getComponentById("progress3").setValue("In Progress...")
	status=zenPage.GenerateCubeJSON()
	if (status!=1 && status!="") {
		zenPage.getComponentById("progress3").setValue(status)
		return
	} else {
		zenPage.getComponentById("progress3").setValue("Completed")
	}
	
	zenPage.getComponentById("progress4").setValue("In Progress...")
	status=zenPage.BuildCube()
	if (status!=1 && status!="") {
		zenPage.getComponentById("progress4").setValue(status)
		return
	} else {
		zenPage.getComponentById("progress4").setValue("Completed")
		zenPage.getComponentById("btnGoStats").setProperty('disabled',0);
		zenPage.getComponentById("btnGoStats").setProperty('hidden',0);
		zenPage.getComponentById("btnGoStats").setProperty('controlClass', (1 ? 'commandButton' :'commandButtonDisabled'));	
		zenPage.AddDetails(zen('FileName').getValue())
	}
	
	zenPage.getComponentById("progress5").setValue("In Progress...")
	status=zenPage.GenerateDash()
	if (status!=1 && status!="") {
		zenPage.getComponentById("progress5").setValue(status)
		return
	} else {
		zenPage.getComponentById("progress5").setValue("Completed")
		zenPage.getComponentById("btnGoDash").setProperty('disabled',0);
		zenPage.getComponentById("btnGoDash").setProperty('hidden',0);
		zenPage.getComponentById("btnGoDash").setProperty('controlClass', (1 ? 'commandButton' :'commandButtonDisabled'));	
		status=zenPage.ScoreCardExists()
		if (status!=1 && status !=""){
		} else {
		zenPage.getComponentById("btnScoreDash").setProperty('disabled',0);
		zenPage.getComponentById("btnScoreDash").setProperty('hidden',0);
		zenPage.getComponentById("btnScoreDash").setProperty('controlClass', (1 ? 'commandButton' :'commandButtonDisabled'));	
		}	
	}
}

Method ScoreCardExists() As %Status [ ZenMethod ]
{
	Set dashName="Generated/Sample ScoreCard for "_..CubeName_".dashboard"
	Set st=##class(%DeepSee.Dashboard.Utils).%DashboardExists(dashName)
	QUIT st
}

ClientMethod drawStats() [ Language = javascript ]
{
	document.getElementById("statsTable").innerHTML="<p>Generating Stats...</p>"
	document.getElementById("statsTable").innerHTML=zenPage.GetStats()
	zenPage.updateState();
}

Method GenerateDash() As %Status [ ZenMethod ]
{
	Set st=$$$OK
	do ##class(%DeepSee.Dashboard.AutoPivot).GenerateSampleDashboards(..CubeName)
	Set dashName="Generated/Samples for "_..CubeName_".dashboard"
	Set st=##class(%DeepSee.Dashboard.Utils).%DashboardExists(dashName)
	quit st
}

Method GetStats() As %String [ ZenMethod ]
{
	set st=$$$OK
	
	set mdx="SELECT [Measures].[%COUNT] on 1 from ["_..CubeName_"]"
	set rs=##class(%DeepSee.ResultSet).%ExecuteDirect(mdx)
	set totalmembers=rs.%GetOrdinalValue(1)
	set html="<p>"_totalmembers_" facts have been built for Cube "_..CubeName_"</p><table border=""1""><th>Level Name</th><th>Number of Members</th><th>Percentage of Null Values</th>"
	set st=##class(%DeepSee.Utils).%GetDimensionList(..CubeName,.info)
	set d=$order(info(""))
	while d'="" {
		set h=$order(info(d,""))
		while h'="" {
			set l=$order(info(d,h,""))
			while l'="" {
				if $lg(info(d,h,l),1)="l" {
					set spec="["_$lg(info(d,h,l),2)_"].["_$lg(info(d,h,l),3)_"].["_$lg(info(d,h,l),4)_"]"
					set mdx="SELECT COUNT("_spec_".Members) on 1 from ["_..CubeName_"]"
					set rs=##class(%DeepSee.ResultSet).%ExecuteDirect(mdx)
					set members=rs.%GetOrdinalValue(1)
					
					set mdx="SELECT ISNULL("_spec_".&[<null>],0)/[Measures].[%COUNT] on 1 from ["_..CubeName_"]"
					set rs=##class(%DeepSee.ResultSet).%ExecuteDirect(mdx)
					set nullpercent=(((rs.%GetOrdinalValue(1)*10000)\1)/100)
					set html=html_"<tr><td>"_spec_"</td><td>"_members_"</td><td>"_nullpercent_"%</td></tr>"
				}
				set l=$order(info(d,h,l))
			}
			set h=$order(info(d,h))
		}
		set d=$order(info(d))
	}
	set html=html_"</table>"
	quit html
}

Method AddDetails(pFileName As %String, pSourceClass As %String, pCubeName As %String) [ ZenMethod ]
{
	set ^DeepSee.ImportCSV(..SourceClass,..CubeName, ..Version)=pFileName
}

Method GenerateCubeName() [ ZenMethod ]
{
	
	if $length(..FileName,"\")>$length(..FileName,"/") {
		set tName=$zstrip($replace($piece($piece(..FileName,"\",*),".",1),"DEEPSEE",""),"*PCW")
	} else {
		set tName=$zstrip($replace($piece($piece(..FileName,"/",*),".",1),"DEEPSEE",""),"*PCW")
	}

 	if ##class(%Dictionary.CompiledClass).%ExistsId(tName) {
		set st=$classmethod(tName,"%DeleteExtent")
		quit:$$$ISERR(st) $system.Status.GetErrorText(st)
		set st=$system.OBJ.Delete(tName,"/displayerror=0 /displaylog=0")
		quit:$$$ISERR(st) $system.Status.GetErrorText(st)
	}
	if ##class(%Dictionary.CompiledClass).%ExistsId(tName_"Cube") {
		set st=$classmethod(tName_"Cube.Fact","%DeleteExtent")
		quit:$$$ISERR(st) $system.Status.GetErrorText(st)
		set st=$system.OBJ.Delete(tName_"Cube","/displayerror=0 /displaylog=0")
		quit:$$$ISERR(st) $system.Status.GetErrorText(st)
	}
	
	Set ..CubeName=tName
	Set ..SourceClass="User."_tName
	&JS<zenPage.getComponentById("CubeName").setValue("#(..CubeName)#")>
}

Method UpdateCubeName(tName) [ ZenMethod ]
{
	
 	if ##class(%Dictionary.CompiledClass).%ExistsId(tName) {
		set st=$classmethod(tName,"%DeleteExtent")
		quit:$$$ISERR(st) $system.Status.GetErrorText(st)
		set st=$system.OBJ.Delete(tName,"/displayerror=0 /displaylog=0")
		quit:$$$ISERR(st) $system.Status.GetErrorText(st)
	}
	if ##class(%Dictionary.CompiledClass).%ExistsId(tName_"Cube") {
		set st=$classmethod(tName_"Cube.Fact","%DeleteExtent")
		quit:$$$ISERR(st) $system.Status.GetErrorText(st)
		set st=$system.OBJ.Delete(tName_"Cube","/displayerror=0 /displaylog=0")
		quit:$$$ISERR(st) $system.Status.GetErrorText(st)
	}
	
	If ($$$UPPER($ZStrip(tName,"<N"))'=$$$UPPER(tName))
	{
		&JS<alert("Name cannot start with a number!")
		zenPage.getComponentById("CubeName").setValue("#(..CubeName)#")>
	}
	Set ..CubeName=tName
	Set ..SourceClass="User."_tName
}

Method GenerateSourceClass(pFileName As %String) As %String [ ZenMethod ]
{
	set st=$$$OK
	// Take file from request

	if $length(pFileName,"/")>$length(pFileName,"\") {
 		Set pFileName=$zu(168)_$piece($piece(pFileName,"/",*),".",1)_"DEEPSEE."_$piece(pFileName,".",2)
	} else {
 		Set pFileName=$zu(168)_$piece($piece(pFileName,"\",*),".",1)_"DEEPSEE."_$piece(pFileName,".",2)
	}
	
	Set tSourceClass=..SourceClass
	
	//set ^pfscreatefile=$lb(pFileName,tSourceClass)
	//set pFileName=$lg(^pfscreatefile,1)
	//set tSourceClass=$lg(^pfscreatefile,2)
	d ##class(%SQL.Util.Procedures).CSVTOCLASS(,,pFileName,,,,tSourceClass)
	
	
	s class=##class(%Dictionary.ClassDefinition).%OpenId(tSourceClass,,.st)
	quit:$$$ISERR(st) "Source class was not properly generated"
	
	for i=1:1:class.Properties.Count() {
		if class.Properties.GetAt(i).Name["DaTeDs" {
			set counter=$i(counter)
			set prop=class.Properties.GetAt(i)
			set newprop=prop.%ConstructClone()
			set newprop.Name=$piece(prop.Name,"DaTeDs",1)
			set format=$piece(prop.Name,"DaTeDs",2)
			set newprop.Type="%Library.Date"
			set newprop.SqlColumnNumber=class.Properties.Count()+1+counter
			d newprop.Parameters.GetNext(.param)
			while param'="" {
				d newprop.Parameters.RemoveAt(param)
				d newprop.Parameters.GetNext(.param)
			}
			
			do class.Properties.Insert(newprop)
			d class.%Save()
			set st=$System.OBJ.Compile(tSourceClass,"fck /displayerror=0 /displaylog=0")
			quit:$$$ISERR(st)
				
			
			set sql="select %ID as ID from SQL"_tSourceClass
			set rs=##class(%SQL.Statement).%ExecDirect(,sql)
			while rs.%Next() {
				set obj=$classmethod(tSourceClass,"%OpenId",rs.ID)
				try {
					set $property(obj,newprop.Name)=$zdh($property(obj,prop.Name),format)
				} catch {
					set $property(obj,newprop.Name)=""
				}
				set st=obj.%Save()
				quit:$$$ISERR(st)
			}
			
			d class.Properties.RemoveAt(i)
			set st=class.%Save()
			quit:$$$ISERR(st)
			set st=$System.OBJ.Compile(tSourceClass,"fck /displayerror=0 /displaylog=0")
			quit:$$$ISERR(st)
		}
	}
	
	set:'$$$ISERR(st) ..SourceClass=tSourceClass
	quit $system.Status.GetErrorText(st)
}

Method ImportDataJSON() As %String [ ZenMethod ]
{
	set st=$$$OK
	
	set st=##class(%DeepSee.UI.Dialog.CSVImport).ImportJSONData(..propertyJSONStreamID,..dataJSONStreamID,..SourceClass)
	
	quit $system.Status.GetErrorText(st)
}

Method GenerateSourceClassJSON() As %String [ ZenMethod ]
{
	set st=$$$OK
	// Take file from request
	
	set st=##class(%DeepSee.UI.Dialog.CSVImport).JSONToClass(..propertyJSONStreamID,..SourceClass)
	
	quit $system.Status.GetErrorText(st)
}

Method GenerateCube() As %String [ ZenMethod ]
{
	set tSourceClass=..SourceClass
	set tCubeName=$piece(tSourceClass,".",*)
	set tCubeClass=tSourceClass_"Cube"
	//Generate DeepSee Cube
	//set st=##class(%DeepSee.WizardUtils).%GenerateCubeDefinition("User."_tSourceClass_".Record",tCubeName,tCubeClass)
	set st=##class(%DeepSee.WizardUtils).%GenerateCubeDefinition(tSourceClass,tCubeName,tCubeClass)
	quit:$$$ISERR(st) $system.Status.GetErrorText(st)
	
	//Compile new cube class
	set st=$System.OBJ.Compile(tCubeClass,"fck /displayerror=0 /displaylog=0")
	set:'$$$ISERR(st) ..CubeName=tCubeName
	quit:$$$ISERR(st) $system.Status.GetErrorText(st)
	
	//Disable items
	set model=$zobjclassmethod(tCubeClass,"%GetModel")
	for i=1:1:model.dimensions.Count() {
		if model.dimensions.GetAt(i).name["eXcLuDe" {
			set model.dimensions.GetAt(i).disabled=1
			set oldName=model.dimensions.GetAt(i).name
			//Remove "eXcLuDe" from Cube and Source
			
			set prop=##class(%Dictionary.PropertyDefinition).%OpenId(tSourceClass_"||"_model.dimensions.GetAt(i).name)
			if $isobject(prop) {
				set tempprop=prop.%ConstructClone()
				set st=##class(%Dictionary.PropertyDefinition).%DeleteId(tSourceClass_"||"_model.dimensions.GetAt(i).name)
				return:$$$ISERR(st) $system.Status.GetErrorText(st)
				set tempprop.Name=$p(model.dimensions.GetAt(i).name,"eXcLuDe",1)
				set model.dimensions.GetAt(i).name=$p(model.dimensions.GetAt(i).name,"eXcLuDe",1)
				set model.dimensions.GetAt(i).name=model.dimensions.GetAt(i).name
				set model.dimensions.GetAt(i).hierarchies.GetAt(1).levels.GetAt(1).name=model.dimensions.GetAt(i).name
				set model.dimensions.GetAt(i).hierarchies.GetAt(1).levels.GetAt(1).sourceProperty=model.dimensions.GetAt(i).name
				set tempprop.parent=##class(%Dictionary.ClassDefinition).%OpenId(tSourceClass)
				set st=tempprop.%Save()
				return:$$$ISERR(st) $system.Status.GetErrorText(st)
				
				set s=##class(%Dictionary.StorageDefinition).%OpenId(tSourceClass_"||Default")
				for p=1:1:s.Data.GetAt(1).Values.Count() {
					if s.Data.GetAt(1).Values.GetAt(p).Value=oldName {
						set dataval=##class(%Dictionary.StorageDataValueDefinition).%OpenId(s.%Id()_"||"_s.DefaultData_"||"_p)
						set dataval.Value=tempprop.Name
						d dataval.%Save()
					}
				}
			}
				
			set st=$System.OBJ.Compile(tSourceClass,"fck /displayerror=0 /displaylog=0")
			return:$$$ISERR(st) $system.Status.GetErrorText(st)
		}
	}
	for i=1:1:model.measures.Count() {
		if model.measures.GetAt(i).name["eXcLuDe" {
			set model.measures.GetAt(i).disabled=1
			set oldName=model.measures.GetAt(i).sourceProperty
			//Remove "eXcLuDe" from Cube and Source
			
			set prop=##class(%Dictionary.PropertyDefinition).%OpenId(tSourceClass_"||"_model.measures.GetAt(i).sourceProperty)
			if $isobject(prop) {
				set tempprop=prop.%ConstructClone()
				set st=##class(%Dictionary.PropertyDefinition).%DeleteId(tSourceClass_"||"_model.measures.GetAt(i).sourceProperty)
				return:$$$ISERR(st) $system.Status.GetErrorText(st)
				set tempprop.Name=$p(model.measures.GetAt(i).sourceProperty,"eXcLuDe",1)
				set model.measures.GetAt(i).sourceProperty=$p(model.measures.GetAt(i).sourceProperty,"eXcLuDe",1)
				set model.measures.GetAt(i).name=model.measures.GetAt(i).sourceProperty
				set tempprop.parent=##class(%Dictionary.ClassDefinition).%OpenId(tSourceClass)
				set st=tempprop.%Save()
				return:$$$ISERR(st) $system.Status.GetErrorText(st)
				
				set s=##class(%Dictionary.StorageDefinition).%OpenId(tSourceClass_"||Default")
				for p=1:1:s.Data.GetAt(1).Values.Count() {
					if s.Data.GetAt(1).Values.GetAt(p).Value=oldName {
						set dataval=##class(%Dictionary.StorageDataValueDefinition).%OpenId(s.%Id()_"||"_s.DefaultData_"||"_p)
						set dataval.Value=tempprop.Name
						d dataval.%Save()
					}
				}
			}
			
			set st=$System.OBJ.Compile(tSourceClass,"fck /displayerror=0 /displaylog=0")
			return:$$$ISERR(st) $system.Status.GetErrorText(st)
		}
		set prop=##class(%Dictionary.PropertyDefinition).%OpenId(tSourceClass_"||"_model.measures.GetAt(i).sourceProperty)
		if $isobject(prop) {
			if prop.Type="%Library.Currency" {
					set currency=##class(%SYS.NLS.Locale).%New()
					set model.measures.GetAt(i).formatString=currency.Currency_"#.##;-"_currency.Currency_"#.##;;;"
			}
		}
	}
	for i=1:1:model.listings.Count() {
		if model.listings.GetAt(i).fieldList["eXcLuDe" {
			set model.listings.GetAt(i).fieldList=$replace(model.listings.GetAt(i).fieldList,"eXcLuDe","")
		}
	}
	set st=##class(%DeepSee.Utils).%SaveCubeDefinition(tCubeClass,,model.description,model)
	quit:$$$ISERR(st) $system.Status.GetErrorText(st)
	
	
	set st=$System.OBJ.Compile(tCubeClass,"fck /displayerror=0 /displaylog=0")
	quit $system.Status.GetErrorText(st)
}

Method GenerateCubeJSON() As %String [ ZenMethod ]
{
	set tSourceClass=..SourceClass
	set tCubeName=$piece(tSourceClass,".",*)
	set tCubeClass=tSourceClass_"Cube"
	//Generate DeepSee Cube
	//set st=##class(%DeepSee.WizardUtils).%GenerateCubeDefinition("User."_tSourceClass_".Record",tCubeName,tCubeClass)
	set st=##class(%DeepSee.WizardUtils).%GenerateCubeDefinition(tSourceClass,tCubeName,tCubeClass)
	quit:$$$ISERR(st) $system.Status.GetErrorText(st)
	
	//Compile new cube class
	set st=$System.OBJ.Compile(tCubeClass,"fck /displayerror=0 /displaylog=0")
	set:'$$$ISERR(st) ..CubeName=tCubeName
	quit:$$$ISERR(st) $system.Status.GetErrorText(st)
	
	set tempStream=##class(%Stream.FileBinary).%OpenId(..propertyJSONStreamID)
	set propertyObj={}.%FromJSON(tempStream)
	
	//Disable items as needed
	set model=$zobjclassmethod(tCubeClass,"%GetModel")
	for i=1:1:model.dimensions.Count() {
		set tempPos=propertyObj.%Get(model.dimensions.GetAt(i).name)
		if propertyObj.Include.%Get(tempPos)'="true" {
			set model.dimensions.GetAt(i).disabled=1
		}
	}
	for i=1:1:model.measures.Count() {
		if propertyObj.Include.%Get(propertyObj.%Get(model.measures.GetAt(i).name))'="true" {
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
	quit:$$$ISERR(st) $system.Status.GetErrorText(st)
	
	
	set st=$System.OBJ.Compile(tCubeClass,"fck /displayerror=0 /displaylog=0")
	quit $system.Status.GetErrorText(st)
}

Method BuildCube() As %String [ ZenMethod ]
{
	set st=$$$OK
	//Build DeepSee Cube
	//Ignoring Build Errors
	d ##class(%DeepSee.Utils).%BuildCube(..CubeName,,0)
	
	quit $system.Status.GetErrorText(st)
}

/// This method is fired up after onDrawContent is finished. Hide progress message and display error if exists.
ClientMethod drawDone(tab) [ Language = javascript ]
{
	
	var result = this.GetStatus(tab);
	var id = "idProgress"+tab;
	this.IMPORTALL = 0;
	if (result.Status == "Done") {
		if (result.Error != "") {
			this.showMsg(result.Error);
			zen("btnFinish").setProperty('disabled',true);
			zen("btnFinish").setProperty('controlClass','commandButtonDisabled');
		}
	} else if (result.Status == "IMPORTALL") {
		this.IMPORTALL = 1;
	} else {
		//var error = $$$Text("Unexpected error occurred. Loading did not finish as expected.");
		//this.showMsg(error);
		zen("btnNext").setProperty('disabled',true);
		zen("btnNext").setProperty('controlClass','commandButtonDisabled');
	}
	zen(id).setHidden(true);
}

/// Return true if this template can go to the next page (i.e., enable
/// the Next button).<br>
ClientMethod canGoNext() [ Language = javascript ]
{
	var tabGroup = zen('tabGroup');
	var tabNo = tabGroup.getCurrTabNo();	
	var flag = false;
	switch(tabNo) {
	case 1:
		flag = true;
		if (this.INPUTTYPE == "LOCAL") flag = false;
		break;
	case 2:
		break;
	case 3:
		break;
	case 4:
		break;
	}
	return flag;
}

/// Return true if this template can go to the stats page (i.e., enable
/// the stats button).<br>
ClientMethod canStat() [ Language = javascript ]
{
	var tabGroup = zen('tabGroup');
	var tabNo = tabGroup.getCurrTabNo();	
	var flag = false;
	switch(tabNo) {
	case 1:
		break;
	case 2:
		break;
	case 3:
		flag = true;
		break;
	case 4:
		break;
	}
	return flag;
}

/// Return true if this template can go to the previous page (i.e., enable
/// the Back button).<br>
/// This is implemented by subclasses.
ClientMethod canGoBack() [ Language = javascript ]
{
	var tabGroup = zen('tabGroup');
	var tabNo = tabGroup.getCurrTabNo();
	var flag = true;
	switch(tabNo) {
	case 1:
		flag = false;
		break;
	case 2:
		break;
	case 3:
		break;
	case 4:
		break;
	}	
	return flag
}

/// Return true if this template can Finish (i.e., enable
/// the Finish button).<br>
ClientMethod canFinish() [ Language = javascript ]
{
	var tabGroup = zen('tabGroup');
	var tabNo = tabGroup.getCurrTabNo();
	var flag = false;
	switch(tabNo) {
	case 1:
		break;
	case 2:
		flag = true;
		break;
	case 3:
		break;
	case 4:
		break;
	}	
	zen("btnCancel").setHidden(true);
	zen("btnCancel").setDisabled(true);	
	
	return flag;
}

ClientMethod hasMultiplePages() [ Language = javascript ]
{
	return true;
}

/// Go to the next page of the template (if there is one).<br>
ClientMethod nextPage() [ Language = javascript ]
{
	this.resetMsg();
	var tabGroup = zen('tabGroup');
	var tabNo = tabGroup.getCurrTabNo();
	switch(tabNo) {
	case 1:
		var FileName = zen("FileName").getValue();
		var ok = this.ValidateFile(FileName);
		if (ok == 0) {
			this.showMsg($$$Text("File name is empty."),1);	
			zen("FileName").focus();
			break;
		}
		if (ok == -1) {
			this.showMsg($$$Text("You have entered a directory path without a file name."),1);
			zen("FileName").focus();
			break;	
		}
		if (ok == -2) {
			this.showMsg($$$Text("File does not exist!"),1);
			zen("FileName").focus();
			break;		
		}
		if (ok == -3) {
		this.showMsg($$$Text("File Name cannot start with a number!"),1);
		zen("FileName").focus();
		break;		
		}
		var html = zen("htmlContent");
		html.setProperty('seed',FileName);
		tabGroup.showNextTab();
		break;
	case 2:
		var html = zen("htmlContent3");
		html.setProperty('seed',1);
		tabGroup.showNextTab();
		break;
	case 3:
		var html = zen("htmlContent4");
		html.setProperty('seed',1);
		tabGroup.showNextTab();
		break;
	case 4:
		break;
	}
	zenPage.updateState();
}

/// Go to the previous page of the template (if there is one).<br>
/// This is implemented by subclasses.
ClientMethod previousPage() [ Language = javascript ]
{
	//this.resetMsg();	
	var tabGroup = zen('tabGroup');
	var tabNo = tabGroup.getCurrTabNo();
	switch(tabNo) {
	case 1:
		break;
	case 2:
		tabGroup.showPreviousTab();
		this.resetMsg();
		zenPage.updateState();
		if (zen("InputType").getValue()=="LOCAL") {
			zen('btnNext').setProperty('hidden',true);
		}
		break;
	case 3:
		tabGroup.showPreviousTab();
		zenPage.updateState();
		break;
	case 4:
		tabGroup.showPreviousTab();
		zenPage.updateState();
		break;
	}
}

/// This client event, if present, is fired when the page is loaded.
ClientMethod onloadHandler() [ Internal, Language = javascript ]
{
	this.invokeSuper('onloadHandler',arguments);
	if (this.InvalidParam) {
		zen("btnNext").setHidden(true);	}
}

ClientMethod getDialogValue() [ Internal, Language = javascript ]
{
	return ""
}

/// User clicked the Browse button.
ClientMethod browseSelect(name) [ Internal, Language = javascript ]
{
	var Dir = zen(name).getValue();
	zenLaunchPopupWindow('%ZEN.Dialog.fileSelect.zen?Dir='+encodeURIComponent(Dir)+'&wildcard=*.csv&showdirectoryonly=0','FileSelect','resizable,width=600,height=700');
}

/// Returning from file select OR qualifers dialog and setting the value into the appropriate field.
/// The id of the field that needs to be updated is saved in "dialogClicked".
ClientMethod onPopupAction(popupName, action, value) [ Internal, Language = javascript ]
{
	if (action == "ok") {
		zen("FileName").setValue(value);
		zenPage.UpdateFileName(value);
		zenPage.GenerateCubeName();
		zenPage.updateState();	
	}
}

/// This is called when the template is first displayed;
/// This provides a chance to load the last filetype, etc.
ClientMethod onstartHandler() [ Internal, Language = javascript ]
{
	// if this is from the submit of the Local file, load the content of the file on tab 2.
	if (this.INPUTTYPE == "LOCAL") {
		// set the first tab for LOCAL correctly
		this.doLocationChange("LOCAL");		
		if (this.LOCALFILENAME != "") {
			var html = zen("htmlContent");
			html.setProperty('seed',this.LOCALFILENAME);
			var tabGroup = zen('tabGroup');
			var tabNo = tabGroup.getCurrTabNo();
			if (tabNo == 1) {
				tabGroup.showNextTab();
			}
			zenPage.updateState();
		} 
		zen("btnNext").setHidden(true);
	}
}

ClientMethod getSelected() [ Internal, Language = javascript ]
{
	var cb;
	if (!document.getElementById("TotalRows")) return -1;
	var TotalRows = document.getElementById("TotalRows").value;
	var selectedRows = "";
	var dim = ",";
	for (var i = 1; i <= TotalRows; i++) {
		cb = self.document.getElementById("cb_"+i);
		if (cb.checked == true) {
			selectedRows = selectedRows + cb.value + dim;
		}
	}
	return selectedRows;
}

ClientMethod toggleCheckboxes(cbState) [ Internal, Language = javascript ]
{
	var cb;
	var TotalRows = document.getElementById("TotalRows").value;
	for (var i = 1; i <= TotalRows; i++) {
		cb = self.document.getElementById("cb_"+i);
		cb.checked = cbState;
	}
}

/// Get the (localized) title string for the dialog.
/// This should be implemented in a subclass.
Method %OnGetTitle() As %String [ Internal ]
{
	Quit $$$TextHTML("Import CSV")
}

/// Get the (localized) subtitle string for the dialog.
/// This should be implemented in a subclass.
Method %OnGetSubtitle() As %String [ Internal ]
{
	Quit ""
}

/// This callback is called after the server-side page 
/// object and all of its children are created.<br/>
/// Subclasses can override this to add, remove, or modify 
/// items within the page object model, or to provide values
/// for controls.
Method %OnAfterCreatePage() As %Status [ Internal ]
{
	Set tSC = ##super()
	If $$$ISERR(tSC) Quit tSC
	
	// try and determine if user is on *same* machine as server
	// if so, do not provide local upload option
	Set tTCPAddr = $SYSTEM.TCPDevice.PeerAddr(0)
	Set tClientAddr = $G(%request.CgiEnvs("REMOTE_ADDR"))
	Set tIsLocal = ((tClientAddr = "127.0.0.1") ! (tClientAddr = "::1")) & ((tTCPAddr = "127.0.0.1") ! (tTCPAddr = "::1"))
	If 1 {
		Set ..%GetComponentById("InputType").hidden = 1
		Set ..%GetComponentById("LocalFile").hidden = 1
	}
	Set FileName = ""
	Set ..%GetComponentById("FileName").value = FileName
	#; Set for Remote input types choice: ServerName or local machine
	Set ..%GetComponentById("InputType").displayList = $zu(110)_","_$$$Text("My Local Machine")
	If $G(%request.Data("INPUTTYPE",1)) = "LOCAL" {
		Set %page.LOCALFILENAME = $G(%session.Data($Username,"Import","LOCALFileName"))
		Set ..%GetComponentById("InputType").value = "LOCAL"
	}
	Quit $$$OK
}

ClassMethod DrawSortPageTitle(pSeed As %String) As %Status [ Internal ]
{
	Set tPageTitle = "<i>Please sort each column as Dimension, Date, or Measure. "_ 
	"<br/>A Measure might be something like revenue, or total discharges.<br/>If it is a measure, please specify if it is a number or currency."_
	"<br/>A Dimension would be things like zip code, state, or measure description</i>"
	&html<<div class="Description">#(tPageTitle)#
	</div><hr size="1"/>>
	Quit 1
}

ClassMethod DrawPageTitle(pSeed As %String) As %Status [ Internal ]
{
	Set tPageTitle = "Import CSV file"
	&html<<div class="Description">#(tPageTitle)#
	</div><hr size="1"/>>
	Quit 1
}

/// Draw preview content of the CSV file for user to confirm properties
Method PropertyCheck(pSeed) As %Status
{
	
	Set tSC=$$$OK
	
	quit:pSeed="" tSC
	
	set tSC=##class(%DeepSee.UI.Dialog.CSVImport).CreateTempFile(..FileName,.stream,.outfilename,..ReadSize,..LineSize)
 	quit:$$$ISERR(tSC) tSC
 	
 	set line=""
 		
 	k property
 
 	//If we have a header row, grab the first line and populate property(N,"Name")
 	if (..hasHeaders) {
	 	Set line=stream.ReadLine()
		for i=2:2:$length(line,"""") {
			set $piece(line,"""",i)=$replace($piece(line,"""",i),",","%2C")
		}
		

		TRY {
		 	For i=1:1:$length(line,",") {
			 	set property=i
			 	set chars="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
			 	set chars=chars_"abcdefghijklmnopqrstuvwxyz"
			 	set chars=chars_"0123456789"
				set property(i,"Name")=$e($zstrip($replace($piece(line,",",i),"%2C",","),"*E",,chars),0,31)
				set property(i,"Unique")=1
				if $g(property("Unique",property(i,"Name")),0) {
					set property(i,"Unique")=0
				}
				set property("Unique",property(i,"Name"))=1
			}
		}
		CATCH{
		if property(i,"Name")="" {
			return $$$ERROR($ECODE,"Column headers most likely parsed incorrectly, every column with data must have a header. Check file in Excel")
		}
		}
 	}
 	
 	
	//Get 10 sample rows
	//Get count of rows
	set propcount=""
	while line'="" {
		Set line=stream.ReadLine()
		Set:line'="" rows=$i(rows)
		if (('..hasHeaders)&&(propcount="")) {
			For i=1:1:$length(line,",") {
		 		set property=i
				set property(i,"Name")="Property"_i
				set propcount=i
			}
		}
	}
	set totalrows=rows
	d stream.Rewind()
 	Set line=stream.ReadLine()
 	Set sample=1
 	set rows=0
 	set maxrows=10
 	if maxrows>totalrows {
	 	set maxrows=totalrows
 	}
	while ((line'="")&&(sample<=maxrows)) {
		Set line=stream.ReadLine()
		Set rows=$i(rows)
		if rows#(totalrows\maxrows)=0 {
			//Process each property
			for i=2:2:$length(line,"""") {
				set $piece(line,"""",i)=$replace($piece(line,"""",i),",","%2C")
			}
			
			for i=1:1:$length(line,",") {
				set value=$piece(line,",",i)
				if $length(value)>50 {
					set property(i,"Sample",sample)=$e($replace(value,"%2C",","),0,50)_"..."
				} else {
					set property(i,"Sample",sample)=$replace(value,"%2C",",")
				}
				//set type=$select((+value+value=+value)&&(value'=0):"String",1:"text")
				set type=..FindType(value)
				set property(i,"Type",type)=$i(property(i,"Type",type))
				set:$g(property(i,"Len"))<=$length(value) property(i,"Len")=$length(value)
			}
			set sample=$i(sample)
		}
	}
	
	&html<<table border=1>>
	&html<<tr>>
	for i=1:1:property {
		set format=0
		set type="String"
		Set override="text"
		if $g(property(i,"Type","String"))>=2 {
			set override=""
		} else {
			if $piece($o(property(i,"Type","Date"))," ",1)="Date" {
				set type="Date"
				set format=$piece($o(property(i,"Type","Date"))," ",2)
			}
		}
			&html<<td align="center" style="vertical-align:top;">Include? <input type="checkbox" name="includeCol#(i)#" id="includeCol#(i)#" checked></br><select id="propType#(i)#" onchange="zenPage.swapFormat('#(i)#',value)">>
			if ((type="String")&&(override="text")) {
				&html<<option value="String" selected="selected">Dimension</option>>
				&html<<option value="Date">Date</option>>
			} elseif ((type="String")&&(override="")) {
				&html<<option value="String" selected="selected">Dimension</option>>
				&html<<option value="Integer">Measure</option>>
				&html<<option value="Date">Date</option>>
			} elseif type="Integer" {
				&html<<option value="String">Dimension</option>>
				&html<<option value="Integer" selected="selected">Measure</option>>
				&html<<option value="Date">Date</option>>
			} else {
				&html<<option value="String">Dimension</option>>
				&html<<option value="Integer">Measure</option>>
				&html<<option value="Date" selected="selected">Date</option>>
			}
			set style=$select(type="Date":"",1:"display:none;")
			&html<</select></br><select id="dateFormat#(i)#" style="#(style)#"/>>
			&html<<option value="1" #($select(format=1:"selected='selected'",1:""))#>MM/DD/[YY]YY</option>>
			&html<<option value="2">DD Mmm [YY]YY</option>>
			&html<<option value="3" #($select(format=3:"selected='selected'",1:""))#>YYYY-MM-DD</option>>
			&html<<option value="4">DD/MM/[YY]YY</option>>
			&html<<option value="5" #($select(format=5:"selected='selected'",1:""))#>YYYY</option>>
			/*&html<<option value="5">Mmm [D]D, YYYY</option>>
			&html<<option value="6">Mmm [D]D YYYY</option>>
			&html<<option value="7">Mmm DD [YY]YY</option>>
			&html<<option value="8">YYYYMMDD</option>>
			&html<<option value="9">Mmmmm [D]D, YYYY</option>>
			&html<<option value="10">W</option>>
			&html<<option value="11">Www</option>>
			&html<<option value="12">Wwwwww</option>>
			&html<<option value="13">[D]D/[M]M/YYYY </option>>
			&html<<option value="14">nnn</option>>
			&html<<option value="15">DD/MM/[YY]YY</option>>
			&html<<option value="16">YYYYc[M]Mc[D]Dc</option>>
			&html<<option value="17">YYYYc [M]Mc [D]Dc</option>>
			&html<<option value="18">[D]D Mmmmm YYYY</option>>
			&html<<option value="19">[D]D [M]M YYYY</option>>
			&html<<option value="20">[D]D Mmmmm YYYY</option>>
			&html<<option value="21">[D]D [M]M YYYY</option>>*/
			set style=$select(type="Integer":"",1:"display:none;")
			&html<</select><select id="intFormat#(i)#" style="#(style)#"/>>
			&html<<option value="Number" selected="selected">Number</option>>
			&html<<option value="Currency">Currency</option>>
			&html<</select></td>>
	}
	&html<</tr>>
	&html<<tr>>
	for i=1:1:property {
		&html<<th><input type="text" id="propName#(i)#" maxlength="31" value="#(property(i,"Name"))#"></input></th>>
	}
	&html<</tr>>
	for i=1:1:maxrows {
		&html<<tr>>
		for j=1:1:property {
			&html<<td>#(property(j,"Sample",i))#</td>>
		}
		&html<</tr>>
	}
	&html<</table>>
	Quit tSC
}

/// Draw preview content of the CSV file for user to confirm properties
Method PropertyCheckJSON(pSeed) As %Status [ ZenMethod ]
{
	Set tSC=$$$OK
	
	quit:pSeed="" tSC
	
	// Get JSON from CSV
	set tSC = ##class(%DeepSee.UI.Dialog.CSVImport).CSVToJSON(..FileName,.properties,.data,..ReadSize,..LineSize,..hasHeaders)
	set tempdataJSON=##class(%Stream.FileBinary).%New()
	do tempdataJSON.CopyFrom(data)
	do tempdataJSON.%Save()
	set ..dataJSONStreamID=tempdataJSON.%Id()
	set temppropertyJSON=##class(%Stream.FileBinary).%New()
	do temppropertyJSON.CopyFrom(properties)
	do temppropertyJSON.%Save()
	set ..propertyJSONStreamID=temppropertyJSON.%Id()
	
	set dataArray=[].%FromJSON(data)
	set propertyObj={}.%FromJSON(properties)
	
	//set tSC=##class(%DeepSee.UI.Dialog.CSVImport).CreateTempFile(..FileName,.stream,.outfilename,..ReadSize,..LineSize)
 	quit:$$$ISERR(tSC) tSC
 	
	&html<<table border=1>>
	&html<<tr>>
	set iter=propertyObj.Display.%GetIterator()
	while iter.%GetNext(.key,.val) {
		set format=0
		&html<<td align="center" style="vertical-align:top;">Include? <input type="checkbox" name="includeCol#(key)#" id="includeCol#(key)#" checked></br><select id="propType#(key)#" onchange="zenPage.swapFormat('#(key)#',value)">>
			&html<<option value="%String" selected="selected">Dimension</option>>
			&html<<option value="%Integer">Measure</option>>
			&html<<option value="%Date">Date</option>>
		&html<</select></br><select id="dateFormat#(key)#" style="display:none;"/>>
			&html<<option value="1" #($select(format=1:"selected='selected'",1:""))#>MM/DD/[YY]YY</option>>
			&html<<option value="2">DD Mmm [YY]YY</option>>
			&html<<option value="3" #($select(format=3:"selected='selected'",1:""))#>YYYY-MM-DD</option>>
			&html<<option value="4">DD/MM/[YY]YY</option>>
			&html<<option value="5" #($select(format=5:"selected='selected'",1:""))#>YYYY</option>>
			/*&html<<option value="5">Mmm [D]D, YYYY</option>>
			&html<<option value="6">Mmm [D]D YYYY</option>>
			&html<<option value="7">Mmm DD [YY]YY</option>>
			&html<<option value="8">YYYYMMDD</option>>
			&html<<option value="9">Mmmmm [D]D, YYYY</option>>
			&html<<option value="10">W</option>>
			&html<<option value="11">Www</option>>
			&html<<option value="12">Wwwwww</option>>
			&html<<option value="13">[D]D/[M]M/YYYY </option>>
			&html<<option value="14">nnn</option>>
			&html<<option value="15">DD/MM/[YY]YY</option>>
			&html<<option value="16">YYYYc[M]Mc[D]Dc</option>>
			&html<<option value="17">YYYYc [M]Mc [D]Dc</option>>
			&html<<option value="18">[D]D Mmmmm YYYY</option>>
			&html<<option value="19">[D]D [M]M YYYY</option>>
			&html<<option value="20">[D]D Mmmmm YYYY</option>>
			&html<<option value="21">[D]D [M]M YYYY</option>>*/
			&html<</select><select id="intFormat#(key)#" style="display:none;"/>>
			&html<<option value="%Integer" selected="selected">Number</option>>
			&html<<option value="%Library.Currency">Currency</option>>
			&html<</select></td>>
	}
	&html<</tr>>
	&html<<tr>>
	set iter=propertyObj.Display.%GetIterator()
	while iter.%GetNext(.key,.val) {
		&html<<th><input type="text" id="propName#(key)#" maxlength="31" value="#(val)#"></input></th>>
	}
	&html<</tr>>
	set iter=dataArray.%GetIterator()
	while ((iter.%GetNext(.key,.val)) && (key<10)) {
		&html<<tr>>
		set iter2=val.%GetIterator()
		while iter2.%GetNext(.key2,.val2) {
			&html<<td>#(val2)#</td>>
		}
		&html<</tr>>
	}
	&html<</table>>
	Quit tSC
}

ClientMethod swapFormat(propID, value) [ Internal, Language = javascript ]
{
	if (value=='%Date') {
		document.getElementById("dateFormat"+propID).style.display=""
		document.getElementById("intFormat"+propID).style.display="none"
	} else if (value=='%Integer') {
		document.getElementById("intFormat"+propID).style.display=""
		document.getElementById("dateFormat"+propID).style.display="none"
	} else {
		document.getElementById("dateFormat"+propID).style.display="none"
		document.getElementById("intFormat"+propID).style.display="none"
	}
}

ClassMethod FindType(value) As %String
{
	set type="String"
	set type=$select((+value=value):"String",1:"text")
	//Check if it is a date
	//The following patterns are checked: 
	//	(N)N/(N)N/(NN)NN
	//	NNNN-(N)N-(N)N
	//	18NN, 19NN, 20NN, 21NN
	if (value?1.2N1"/"1.2N1"/"2.4N) {
		set type="Date 1"
	} elseif (value?4N1"-"1.2N1"-"1.2N) {
		set type="Date 3"
	}
	elseif((value?1"18"2N)||(value?1"19"2N)||(value?1"20"2N)||(value?1"21"2N))
	{
		set type="Date 5"
	}
	
	
	quit type
}

/// tab = 2: Content - when DrawContent is finished, Status is "Done".
ClassMethod GetStatus(tab) As %ZEN.proxyObject [ Internal, ZenMethod ]
{
	Set proxy = ##class(%ZEN.proxyObject).%New()
	Set proxy.Status = $G(%session.Data($Username,"Import","ContentStatus"))
	Set proxy.Error = $G(%session.Data($Username,"Import","ContentError"))
	Quit proxy
}

/// Validate file name.
ClassMethod ValidateFile(FILE) As %Integer [ Internal, ZenMethod ]
{
	If $ZStrip(FILE,"<>W") = "" Quit 0
	#; Entered directory only!
	If ##class(%File).DirectoryExists(FILE) Quit -1
	#; File does not exist!"
	If '##class(%File).Exists(FILE) Quit -2
	Set tFILE=$PIECE(FILE,"\",*)
	If ($$$UPPER($ZStrip(tFILE,"<N"))'=$$$UPPER(tFILE)) Quit -3
	Set tFILE=$PIECE(FILE,"/",*)
	If ($$$UPPER($ZStrip(tFILE,"<N"))'=$$$UPPER(tFILE)) Quit -3
	Quit 1
}

ClassMethod PrepareAction(selectedRows) As %String [ Internal, ZenMethod ]
{
	Quit ##class(%CSP.UI.Template.List).PrepareAction(selectedRows)
}

/// This method is invoked only when user selects to import from Local Machine.<br/>
/// The necessary parameters are passed in URL. The temp file name is saved in %session and to be used in loading content.
ClassMethod %OnSubmit(pSubmit As %ZEN.Submit) As %Status [ Internal ]
{
	Set tStream = pSubmit.%GetStream("File")
	Set dir = ##class(%File).SubDirectoryName($zu(12),"Temp")
	#; If temp directory does not exist, create it now
	If ##class(%File).DirectoryExists(dir) = 0 {
		Do ##class(%File).CreateDirectory(dir)
	}
	#; Get proper delimeter since SubDirectoryName does not include delimeter
	Set tDelim = "\"
	If $$$isUNIX Set tDelim = "/"
	If $$$isVMS Set tDelim = ""
	#; Give it a name so it won't be deleted automatically
	Set DirFileName = dir_tDelim_"importfromlocal.stream"
	Set file = ##class(%Stream.FileBinary).%New()
	Set tSC = file.LinkToFile(DirFileName)
	If tStream '= "" {
		#; Copy the stream from local server
		Set tSC = file.CopyFrom(tStream)
		#; Save it to the file stream on the remote server
		If tSC Set tSC = file.%Save()
	}
	Set %response.Context("INPUTTYPE") = "LOCAL"
	//  remember popup info
	Set %response.Context("$ZEN_POPUP") = 1
	Set %response.Context("$ZEN_POPUPPARENT") = +$G(%request.Data("$ZEN_POPUPPARENT",1))
	Set %response.Context("$ZEN_SOFTMODAL") = ..%OnUseSoftModals()  
	//  save the temp local file name to be used in later to load content
	Set %session.Data($Username,"Import","LOCALFileName") = DirFileName

	Quit tSC
}

/// This client event, if present, is fired when the page is resized.
ClientMethod onresizeHandler() [ Internal, Language = javascript ]
{
	zenbody=document.getElementById("zenBody")
	body=document.getElementById("body")
	body.offsetHeight=body.parentNode.offsetHeight+'px'
	body.style.height=body.parentNode.offsetHeight+'px'
	body.offsetWidth=(zenBody.offsetWidth-15)+'px'
	body.style.width=(zenBody.offsetWidth-15)+'px'
	console.log(zenBody.offsetWidth)
	console.log(body.offsetWidth)
	console.log(body.style.width)
	//console.log(body.style)
}

ClassMethod CSVToJSON(pFileName As %String = "C:\Users\psteiwer\Documents\simplecsv.csv", ByRef propertyJSON, ByRef dataJSON, pMaxSize As %Integer = 0, pMaxLines As %Integer = 0, pHasHeaders As %Boolean) As %Status
{
	set stream=##class(%Stream.FileBinary).%New()
	d stream.LinkToFile(pFileName)
	set s=stream.Read()
	set m=##class(%Regex.Matcher).%New(".*\r\n")
	set m.Text=s
	set m2=##class(%Regex.Matcher).%New("(""([^""]|(""""))*""(,|\r\n))|(([^,""])*(,|\r\n))")
	set properties = {}
	set displayarray = []
	set typearray = []
	set dateformatarray = []
	set includearray = []
	set intformatarray = []
	set dynamicArray = []
	set pos=0
	
	if (pHasHeaders) {
		if m.Locate() {
			set line=$e(s,m.Start,m.End-1)
			//w "Headers: "_line
			set m2.Text=line
			set propcount=-1
			while m2.Locate() {
				set propcount=$i(propcount)
				set prop=$zstrip($zstrip($e(line,m2.Start,m2.End-1),">",","),">C")
				set:$e(prop,1)="""" prop=$e(prop,2,*)
				set:$e(prop,*)="""" prop=$e(prop,1,*-1)
				set prop=$zstrip(prop,"*P")
				d displayarray.%Push(prop)
				d typearray.%Push("%String")
				d dateformatarray.%Push("")
				d intformatarray.%Push("")
				d includearray.%Push("true")
				d properties.%Set(prop,propcount)
				//w "Prop "_propcount_": "_prop,!
			}
			d properties.%Set("Display",displayarray)
			d properties.%Set("Type",typearray)
			d properties.%Set("DateFormat",dateformatarray)
			d properties.%Set("IntFormat",intformatarray)
			d properties.%Set("Include",includearray)
			set pos=m.End-1
		} Else {
			// Headers too long, pick different file
		}
	} Else {
		if m.Locate() {
			set line=$e(s,m.Start,m.End-1)
			//w "Headers: "_line
			set m2.Text=line
			set propcount=0
			while m2.Locate() {
				set prop="Property"_$i(propcount)
				d displayarray.%Push(prop)
				d typearray.%Push("%String")
				d dateformatarray.%Push("")
				d intformatarray.%Push("")
				d includearray.%Push("true")
				d properties.%Set(prop,propcount)
			}
			d properties.%Set("Display",displayarray)
			d properties.%Set("Type",typearray)
			d properties.%Set("DateFormat",dateformatarray)
			d properties.%Set("IntFormat",intformatarray)
			d properties.%Set("Include",includearray)
			
			d m.ResetPosition()
		} Else {
			// Headers too long, pick different file
		}
	}
	
	set done=0
	set linecount=0
	try {
		while ('done)&&((pMaxLines=0)||(linecount<pMaxLines)) {
			while m.Locate()&&((pMaxLines=0)||(linecount<pMaxLines)) {
				set dynamicObject = {}
				set linecount=$i(linecount)
				set line=$e(s,m.Start,m.End-1)
				//w "Line "_linecount_": "_line
				set m2.Text=line
				set propcount=-1
				while m2.Locate() {
					set propcount=$i(propcount)
					set val=$zstrip($zstrip($e(line,m2.Start,m2.End-1),">",","),">C")
					set:$e(val,1)="""" val=$e(val,2,*)
					set:$e(val,*)="""" val=$e(val,1,*-1)
					//w "Cell: "_val,!
					d dynamicObject.%Set(properties.Display.%Get(propcount),val)
				}
				d dynamicArray.%Push(dynamicObject)
				set pos=m.End-1
			}
			
			set s=$e(s,pos,*)
			if stream.AtEnd {
				set done=1
			} else {
				//If less than half available memory is used, double available memory
				if $s<($zs/2*1024) {
					set $zs=$zs*2
				}
				set s=s_stream.Read()
				set m=##class(%Regex.Matcher).%New(".*\r\n")
				set m.Text=s
				set m2=##class(%Regex.Matcher).%New("(""([^""]|(""""))*""(,|\r\n))|(([^,""])*(,|\r\n))")
			}
		}
	} catch ex {
		// Reached max len, pop one item from array
		//d ##class(%DeepSee.UI.Dialog.CSVImport).MakeArraySafe(.dynamicArray)
		d $system.Status.DisplayError(ex.AsStatus())
	}
	
	set dataJSON=##class(%Stream.FileBinary).%New()
	set propertyJSON=##class(%Stream.FileBinary).%New()
	d dynamicArray.%ToJSON(.dataJSON)
	d properties.%ToJSON(.propertyJSON)
	
	q $$$OK
}

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
		Set prop=##class(%Dictionary.PropertyDefinition).%New()
		Set prop.Name=value
		Set prop.Type=dynamicProperties.Type.%Get(key)
		If prop.Type="%String" {
			d prop.Parameters.SetAt("","MAXLEN")
		} ElseIf prop.Type="%Integer" {
			set prop.Type=dynamicProperties.IntFormat.%Get(key)
		} ElseIf prop.Type="%Date" {
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
				
				Do method.Implementation.WriteLine(" try { set pVal=$zdh(pVal,"_tempFormat_") }")
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

ClassMethod ImportJSONData(propertyJSONStreamId As %String, dataJSONStreamId As %String, pClassName As %String, pCleanFirst As %Boolean = 1) As %Status
{
	set tSC=$$$OK
	
	if pCleanFirst {
		set tSC=$classmethod(pClassName,"%DeleteExtent")
	}
	
	set dataJSON=##class(%Stream.FileBinary).%OpenId(dataJSONStreamId)
	set propertyJSON=##class(%Stream.FileBinary).%OpenId(propertyJSONStreamId)
	set dataArray=[].%FromJSON(dataJSON)
	set propertyObj={}.%FromJSON(propertyJSON)
	Set iterArray=dataArray.%GetIterator()
	while iterArray.%GetNext(.key,.val) {
		set obj=$classmethod(pClassName,"%New")
		set iterObj=dataArray.%Get(key).%GetIterator()
		while iterObj.%GetNext(.key2,.val2) {
			//set:propertyObj.Include.%Get(propertyObj.%Get(key2))="true" $property(obj,propertyObj.Display.%Get(propertyObj.%Get(key2)))=val2
			set $property(obj,propertyObj.Display.%Get(propertyObj.%Get(key2)))=val2
		}
		set tSC= obj.%Save()
		w tSC
	}
	
	quit tSC
}

}
