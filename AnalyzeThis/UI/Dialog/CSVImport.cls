/// Created using the page template: Default
Class AnalyzeThis.UI.Dialog.CSVImport Extends %ZEN.Dialog.standardDialog [ System = 4 ]
{
Parameter Version = 1;

Property INPUTTYPE As %ZEN.Datatype.string(ZENURL = "INPUTTYPE");

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

Property propertyJSONStreamID As %ZEN.Datatype.string;

Property dataJSONStreamID As %ZEN.Datatype.string;

/// Id used to track progress.
Property trackingId As %ZEN.Datatype.string;

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
<page xmlns="http://www.intersystems.com/zen"
	title="#(%page.dialogTitle)#" >
<html id="header" OnDrawContent="%DrawTitle" />
<form enctype="multipart/form-data" action="AnalyzeThis.UI.Dialog.CSVImport.zen">
<pane paneName="dialogBody" id="body"/>
<hgroup id="footer" width="99%" cellAlign="right">
<hgroup id="buttonHolder" cellAlign="right">
<button id="btnBack" controlClass="commandButtonDisabled" caption="Back" onclick="zenPage.previousPage();" disabled="true" hidden="true"/>
<spacer width="10" />
<button id="btnGoDash" controlClass="commandButtonDisabled" caption="Sample Dashboard" onclick="zenPage.seeDash();" disabled="true" hidden="true"/>
<spacer width="10" />
<button id="btnScoreDash" controlClass="commandButtonDisabled" caption="Sample ScoreCard" onclick="zenPage.seeScoreCard();" disabled="true" hidden="true"/>
<spacer width="10" />
<button id="btnGoStats" controlClass="commandButtonDisabled" caption="Cube Statistics" onclick="zenPage.nextPage();" disabled="true" hidden="true"/>
<spacer width="10" />
<button id="btnDone" controlClass="commandButton" caption="Done" onclick="zenPage.firePopupAction('okay','hi');" hidden="true" />
<button id="btnNext" controlClass="commandButtonDisabled" caption="Next" onclick="zenPage.nextPage();" disabled="true"/>
<submit id="btnSubmit" controlClass="commandButtonDisabled" caption="Next" hidden="true" disabled="true"/>
<button id="btnFinish" controlClass="commandButtonDisabled" caption="Import" onclick="zenPage.doImportJSON();" disabled="true" hidden="true"/>
<spacer width="10" />
<button id="btnCancel" controlClass="commandButton" caption="Cancel" onclick="zenPage.dialogCancel();" />
</hgroup>
</hgroup>
</form>
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
<text id="FileName" size="70" label="Enter the path and name of the import file:" onchange="zenPage.UpdateFileName(zenThis.getValue()); zenPage.updateState();"/>
<button caption="Browse..." containerStyle="padding-left:2px;" onclick="zenPage.browseSelect('FileName');"/>
</hgroup>
<fileUpload id="LocalFile" name="LocalFile" label="Select the path and name of the import file:" size="70" hidden="true" onchange="zenPage.UpdateLocalFile(zenThis.getValue());"/>

<checkbox id="chkHeaders" caption="This file has a header row" value="1" onchange="zenPage.UpdateHasHeaders(zenThis.getValue());" captionClass="zenLabel" hint=" (Check box to autmatically assign property names.)"/>
<checkbox id="chkRecurse" caption="Include subdirectories" captionClass="zenLabel" value="1" hidden="true"/>
<expando caption="Advanced" animate="true" expanded="false">
<vgroup enclosingStyle="padding-top:10px;">
<label id="LimitLabel" value="Limit the amount of data to read" hint="(Data load will stop after first limit is reached)"/>
<hgroup>
<text id="ReadSize" name="ReadSize" value="50" size="15" label="Read Limit (MB)" onchange="zenPage.UpdateReadSize(zenThis.getValue());"/>
<text id="LineSize" name="LineSize" value="10000" size="15" label="Line Limit" onchange="zenPage.UpdateLineSize(zenThis.getValue());"/>
</hgroup>
</vgroup>

<vgroup enclosingStyle="padding-top:10px;">
<label id="ChangeNameLabel" value="Change the name of the cube"/>
<hgroup>
<text id="CubeName" name="CubeName" size="100" label="CubeName" value="#(%page.CubeName)#" onchange="zenPage.UpdateCubeName(zenThis.getValue());"/>
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
<html id="htmlContent3" onrefresh="zenPage.updateProgress();"/>
<timer id="timer" ontimeout="zenPage.updateStatus();"/>
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

/// Update the ReadSize property
Method UpdateReadSize(value) [ Internal, ZenMethod ]
{
	set ..ReadSize=value*100000
}

/// Update the LineSize property
Method UpdateLineSize(value) [ Internal, ZenMethod ]
{
	set ..LineSize=value
}

/// Update the hasHeaders property
Method UpdateHasHeaders(value) [ Internal, ZenMethod ]
{
	set ..hasHeaders=value
}

/// Update the FileName property
Method UpdateFileName(value) [ Internal, ZenMethod ]
{
	set ..FileName=value
	do ..GenerateCubeName()
}

/// Update the LOCALFILENAME property
Method UpdateLocalFile(value) [ Internal, ZenMethod ]
{
	set ..LOCALFILENAME=value
	
	set button=..%GetComponentById("btnSubmit")
	set button.disabled=(value="")
	if value'="" {
		set button.controlClass="commandButton"
	} else {
		set button.controlClass="commandButtonDisabled"
	}
	
	d ..GenerateCubeName()
}

/// Fire popup action to navigate to dashboard
Method seeDash() [ Internal, ZenMethod ]
{
	Set pcube=..CubeName
	&JS<zenPage.firePopupAction('dash','#(pcube)#');>
}

/// Fire popup action to navigate to scorecard
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
		// for local we cannot allow for Directory
		// show Submit button
		zen("btnNext").setHidden(true);
		zen("btnSubmit").setHidden(false);
	} else {
		zen("idRemoteFile").setHidden(false);
		zen("LocalFile").setHidden(true);
		zen("btnNext").setHidden(false);
		zen("btnSubmit").setHidden(true);
		var FileName = zen("FileName").getValue()
		if (zen("FileName").getValue() != "") {
			zen("btnNext").setProperty('disabled',FileName=="");
			zen("btnNext").setProperty('controlClass', (FileName!="" ? 'commandButton' :'commandButtonDisabled'));			
		}
	}
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
	
	zenPage.nextPage();
	zen("btnDone").setHidden(false);
	zen("btnCancel").setHidden(true);
	zenPage.updateState();
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

	if (0) {
		btnBack.setProperty('hidden',!this.canGoBack());
		btnBack.setProperty('disabled',!this.canGoBack());
		btnBack.setProperty('controlClass',	(this.canGoBack() ? 'commandButton' :'commandButtonDisabled'));
	}
	if (btnNext) {
		btnNext.setProperty('hidden',!this.canGoNext());
		btnNext.setProperty('disabled',!this.canGoNext());
		btnNext.setProperty('controlClass',	(this.canGoNext() ? 'commandButton' :'commandButtonDisabled'));
	}
	// special for Import on this page. Hide regular Next and show Submit Next for LOCAL.
	if (zen("InputType").getValue()=="LOCAL") {
		btnSubmit.setProperty('disabled',true);
		btnSubmit.setProperty('controlClass', 'commandButtonDisabled');
	}
	if (btnFinish) {
		btnFinish.setProperty('disabled',!this.canFinish());
		btnFinish.setProperty('hidden',!this.canFinish());
		btnFinish.setProperty('controlClass', (this.canFinish() ? 'commandButton' :'commandButtonDisabled'));	
	}
}

/// Kicks off GenerateAll and starts the update timer
ClientMethod updateProgress() [ Language = javascript]
{
	this.trackingId = this.GenerateAll(this.FileName,this.ReadSize,this.LineSize,this.hasHeaders, this.propertyJSONStreamID, this.dataJSONStreamID);
	if (this.trackingId!='') {
		zen('timer').timeout = 500;
		zen('timer').startTimer();
	}
}

/// Update the status area.
ClientMethod updateStatus() [ Language = javascript ]
{
	var status = this.CheckStatus(this.trackingId);
	var html = zen('htmlContent3');
	if (status != '') {
		html.setContent(status);
		zen('timer').timeout = 250;
		zen('timer').startTimer();
	}
	else {
		this.trackingId = '';
		
		//Should check status before doing this
		zen("btnGoDash").setProperty('disabled',0);
		zen("btnGoDash").setProperty('hidden',0);
		zen("btnGoDash").setProperty('controlClass','commandButton');	
		
		if (zenPage.ScoreCardExists()) {
			zen("btnScoreDash").setProperty('disabled',0);
			zen("btnScoreDash").setProperty('hidden',0);
			zen("btnScoreDash").setProperty('controlClass','commandButton');
		}	
		
		zen("btnGoStats").setProperty('disabled',!this.canStat());
		zen("btnGoStats").setProperty('hidden',!this.canStat());
		zen("btnGoStats").setProperty('controlClass', (this.canStat() ? 'commandButton' :'commandButtonDisabled'));
	}
	return;
}

/// Get the current status of the background task.
ClassMethod CheckStatus(pTrackingId As %String) As %String [ ZenMethod ]
{
	Set tOutput = ""
	Set tIsComplete = 0
	Set tIsErr = 0

	merge tTracking = ^AnalyzeThis.GenerateTracking(pTrackingId)
	
	Set currStep = $O(tTracking(""),-1)
	If currStep="" Quit tOutput
	For tStep=1:1:currStep {
		
		Set tPhase = $Case(tStep,
							1:"Preparing JSON",
							2:"Generating Source Class",
							3:"Importing Data",
							4:"Generating Cube",
							5:"Populating Cube",
							:"Generating Sample Dashboard")
		
		Set tStatus = tTracking(tStep)
		
		If tStatus="Working..." {
			// Leave message as "Working..."
		} ElseIf $$$ISERR(tStatus) {
			Set tStatus = $System.Status.GetErrorText(tStatus)
			Set tIsErr=1
		} Else {
			Set tStatus = "Complete"
			If tStep=6 {
				Set tIsComplete=1
			}
		}
		
		Set tOutput = tOutput _ "<tr style="""_$S(tIsErr:"color:#da4848;",1:"")_""">"
		Set tOutput = tOutput _ "<td>"_tPhase_"</td>"
		Set tOutput = tOutput _ "<td>"_tStatus_"</td>"
		Set tOutput = tOutput _ "</tr>"
	}
	For tStep=currStep+1:1:6 {
		//Set tOutput = tOutput _ "<tr style="""_$S(tErr'="":"color:#da4848;",tIsActive:"font-weight:bold;",1:"background:#E0E0F0;")_""">"
		Set tOutput = tOutput _ "<tr>"
		
		Set tPhase = $Case(tStep,
							1:"Preparing JSON",
							2:"Generating Source Class",
							3:"Importing Data",
							4:"Generating Cube",
							5:"Populating Cube",
							:"Generating Sample Dashboard")
		
		Set tOutput = tOutput _ "<td>"_tPhase_"</td>"
		Set tOutput = tOutput _ "<td>Not Yet Started</td>"
		Set tOutput = tOutput _ "</tr>"
	}
	
	If (tOutput'="") {
		Set tOutput = "<div>"_$$$Text("Status")_ "</div><table class=""statusTable"" cellspacing=""0"" width=""100%"">" _ tOutput _ "</table>"
	}

	If (tIsComplete || tIsErr) {
		Kill ^AnalyzeThis.GenerateTracking(pTrackingId)
	}
	Quit tOutput
}

/// Start the build cube process in the background.
/// Return the tracking id.
ClassMethod GenerateAll(pFileName, pReadSize, pLineSize, pHasHeaders, pPropertyJSONStreamId, pDataJSONStreamId) As %String [ ZenMethod ]
{
	Set tTrackingId = ""
	Set tJobTimeOut = 10
	
	Job ##class(AnalyzeThis.Generator).GenerateAll(pFileName, pReadSize, pLineSize, pHasHeaders, pPropertyJSONStreamId, pDataJSONStreamId)::tJobTimeOut
	If '$Test {
		&js<alert('Unable to start background job.');>
		Set tTrackingId = ""
	}
	Else {
		Set tTrackingId = $ZChild
	}
	Quit tTrackingId
}

/// Using the current cube name, check if a scorecard was generated for this cube
Method ScoreCardExists() As %Status [ ZenMethod ]
{
	Set dashName="Generated/Sample ScoreCard for "_..CubeName_".dashboard"
	Set st=##class(%DeepSee.Dashboard.Utils).%DashboardExists(dashName)
	QUIT st
}

/// Display cube stats in the status area
ClientMethod drawStats() [ Language = javascript ]
{
	document.getElementById("statsTable").innerHTML="<p>Generating Stats...</p>"
	document.getElementById("statsTable").innerHTML=zenPage.GetStats()
	zenPage.updateState();
}

/// Generate stats display
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

/// Using file properties, create the cube name
Method GenerateCubeName() [ ZenMethod ]
{
	set file=""
	If ..%GetValueById("InputType")="LOCAL" {
		set file=..LOCALFILENAME
	} else {
		set file=..FileName
	}
	if $length(file,"\")>$length(file,"/") {
		set tName=$zstrip($replace($piece($piece(file,"\",*),".",1),"DEEPSEE",""),"*PCW")
	} else {
		set tName=$zstrip($replace($piece($piece(file,"/",*),".",1),"DEEPSEE",""),"*PCW")
	}
	
	Set ..CubeName=tName
	Set ..SourceClass="AnalyzeThis.Generated."_tName
	d ..%SetValueById("CubeName",tName)
}

/// Validates and updates the cube name property
Method UpdateCubeName(tName) [ ZenMethod ]
{
	If ($$$UPPER($ZStrip(tName,"<N"))'=$$$UPPER(tName))
	{
		&JS<alert("Name cannot start with a number!")
		zenPage.getComponentById("CubeName").setValue("#(..CubeName)#")>
	}
	Set ..CubeName=tName
	Set ..SourceClass="AnalyzeThis.Generated."_tName
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
	
	return flag;
}

ClientMethod hasMultiplePages() [ Language = javascript ]
{
	return true;
}

/// Go to the next page of the template (if there is one).<br>
ClientMethod nextPage() [ Language = javascript ]
{
	var tabGroup = zen('tabGroup');
	var tabNo = tabGroup.getCurrTabNo();
	switch(tabNo) {
	case 1:
		var FileName = zen("FileName").getValue();
		var inputtype = "REMOTE"
		if (this.LOCALFILENAME != "") {
			filename = this.LOCALFILENAME;
			inputtype = "LOCAL";
		}
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
	var tabGroup = zen('tabGroup');
	var tabNo = tabGroup.getCurrTabNo();
	switch(tabNo) {
	case 1:
		break;
	case 2:
		tabGroup.showPreviousTab();
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
	this.onresizeHandler();
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
	If tIsLocal {
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
	If $G(%request.Data("ReadSize",1)) '= "" {
		Set %page.ReadSize = $G(%request.Data("ReadSize",1))*100000
		Set ..%GetComponentById("ReadSize").value = $G(%request.Data("ReadSize",1))*100000
		Set ..ReadSize = $G(%request.Data("ReadSize",1))*100000
	}
	If $G(%request.Data("LineSize",1)) '= "" {
		Set %page.LineSize = $G(%request.Data("LineSize",1))
		Set ..%GetComponentById("LineSize").value = $G(%request.Data("LineSize",1))
		Set ..LineSize = $G(%request.Data("LineSize",1))
	}
	If $G(%request.Data("CubeName",1)) '= "" {
		Set %page.CubeName = $G(%request("CubeName",1))
		Set ..%GetComponentById("CubeName").value = $G(%request.Data("CubeName",1))
		Set ..CubeName = $G(%request.Data("CubeName",1))
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
Method PropertyCheckJSON(pSeed) As %Status [ ZenMethod ]
{
	Set tSC=$$$OK
	
	quit:pSeed="" tSC
	
	// Get JSON from CSV
	set file=""
	If ..INPUTTYPE="LOCAL" {
		set file=..LOCALFILENAME
	} else {
		set file=..FileName
	}
	set tSC = ##class(AnalyzeThis.UI.Dialog.CSVImport).CSVToJSON(file,.propertiesJSONStreamId,.dataJSONStreamId,..ReadSize,10,..hasHeaders)
	
	Set ..propertyJSONStreamID=propertiesJSONStreamId
	Set ..dataJSONStreamID=dataJSONStreamId
	
	Set properties=##class(%Stream.FileBinary).%OpenId(propertiesJSONStreamId)
	set propertyObj={}.%FromJSON(properties)
	
	Set data=##class(%Stream.FileBinary).%OpenId(dataJSONStreamId)
	set dataArray=[].%FromJSON(data)
	
 	quit:$$$ISERR(tSC) tSC
 	
	&html<<table border=1>>
	&html<<tr>>
	set iter=propertyObj.Display.%GetIterator()
	while iter.%GetNext(.key,.val) {
		set format=0
		&html<<td align="center" style="vertical-align:top;">Include? <input type="checkbox" name="includeCol#(key)#" id="includeCol#(key)#" onchange="zenPage.updateProp('#(key)#','Include',this.checked,'#(propertiesJSONStreamId)#');" checked></br><select id="propType#(key)#" onchange="zenPage.swapFormat('#(key)#',value); zenPage.updateProp('#(key)#','Type',value,'#(propertiesJSONStreamId)#');">>
			&html<<option value="%String" selected="selected">Dimension</option>>
			&html<<option value="%Integer">Measure</option>>
			&html<<option value="%Date">Date</option>>
		&html<</select></br><select id="dateFormat#(key)#" style="display:none;" onchange="zenPage.updateProp('#(key)#','DateFormat',value,'#(propertiesJSONStreamId)#');"/>>
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
			&html<</select><select id="intFormat#(key)#" style="display:none;" onchange="zenPage.updateProp('#(key)#','IntFormat',value,'#(propertiesJSONStreamId)#');"/>>
			&html<<option value="%Integer" selected="selected">Integer</option>>
			&html<<option value="%Double">Double</option>>
			&html<<option value="%Library.Currency">Currency</option>>
			&html<</select></td>>
	}
	&html<</tr>>
	&html<<tr>>
	set iter=propertyObj.Display.%GetIterator()
	while iter.%GetNext(.key,.val) {
		&html<<th><input type="text" id="propName#(key)#" maxlength="31" value="#(val)#" onchange="zenPage.updateProp('#(key)#','Display',value,'#(propertiesJSONStreamId)#');"></input></th>>
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

/// Changes formatting options based on the type
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

/// As changes are made to the properties, update the JSON stream
Method updateProp(key, which, value, stream) [ ZenMethod ]
{
	set propertyJSON=##class(%Stream.FileBinary).%OpenId(stream)
	set propertyObj={}.%FromJSON(propertyJSON)
	
	d propertyObj.%Get(which).%Set(key,value)
	
	d propertyObj.%ToJSON(.propertyJSON)
	d propertyJSON.%Save()
}

/// Given a value, find the best guess of type
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

/// This method is invoked only when user selects to import from Local Machine.<br/>
/// The necessary parameters are passed in URL. The temp file name is saved in %session and to be used in loading content.
ClassMethod %OnSubmit(pSubmit As %ZEN.Submit) As %Status [ Internal ]
{
	Set tStream = pSubmit.%GetStream("LocalFile")
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
	Set DirFileName = dir_tDelim_pSubmit.%Data("CubeName")_".stream"
	Set file = ##class(%Stream.FileBinary).%New()
	Set tSC = file.LinkToFile(DirFileName)
	If tStream '= "" {
		#; Copy the stream from local server
		Set tSC = file.CopyFrom(tStream)
		#; Save it to the file stream on the remote server
		If tSC Set tSC = file.%Save()
	}
	Set %response.Context("INPUTTYPE") = "LOCAL"
	Set %response.Context("LineSize") = pSubmit.%Data("LineSize")
	Set %response.Context("ReadSize") = pSubmit.%Data("ReadSize")
	Set %response.Context("CubeName") = pSubmit.%Data("CubeName")
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
	body.offsetWidth=(zenbody.offsetWidth-20)+'px'
	body.style.width=(zenbody.offsetWidth-20)+'px'
}

/// Takes a CSV file and returns two stream IDs containing relating to a JSON object for the Properties and a JSON object for the Data
ClassMethod CSVToJSON(pFileName As %String = "C:\Users\psteiwer\Documents\simplecsv.csv", ByRef propertyJSONStreamId, ByRef dataJSONStreamId, pMaxSize As %Integer = 0, pMaxLines As %Integer = 0, pHasHeaders As %Boolean = 1, pNewLine As %String = {$c(13,10)}) As %Status
{
	set stream=##class(%Stream.FileBinary).%New()
	d stream.LinkToFile(pFileName)
	set s=stream.Read()
	set pNewLine=$zconvert(pNewLine,"O","JS")
	set tNewLine="("
	for i=2:1:$length(pNewLine,"\") {
		set:i>2 tNewLine=tNewLine_"|([\"_$piece(pNewLine,"\",i-1)_"]"
		set tNewLine=tNewLine_"[^\"_$piece(pNewLine,"\",i)_"]"
	}
	for i=2:1:$length(pNewLine,"\") {
		set tNewLine=tNewLine_")"
	}
	set m=##class(%Regex.Matcher).%New("(?s)"_tNewLine_"*("_pNewLine_")")
	set m.Text=s
	set m2=##class(%Regex.Matcher).%New("(""([^""]|(""""))*""(,|"_pNewLine_"))|(([^,""])*(,|"_pNewLine_"))")
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
			set m2.Text=line
			set propcount=-1
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
	
	set totalprops=propcount
	set done=0
	set linecount=0
	try {
		while ('done)&&((pMaxLines=0)||(linecount<pMaxLines)) {
			while m.Locate()&&((pMaxLines=0)||(linecount<pMaxLines)) {
				set dynamicObject = {}
				set linecount=$i(linecount)
				set line=$e(s,m.Start,m.End-1)
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
				if totalprops=propcount {
					d dynamicArray.%Push(dynamicObject)
					set pos=m.End
				}
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
				set m.Text=s
			}
		}
	} catch ex {
		// Reached max len, pop one item from array
		//d ##class(AnalyzeThis.UI.Dialog.CSVImport).MakeArraySafe(.dynamicArray)
		d $system.Status.DisplayError(ex.AsStatus())
	}
	
	set dataJSONStream=##class(%Stream.FileBinary).%New()
	d dynamicArray.%ToJSON(.dataJSONStream)
	d dataJSONStream.%Save()
	set dataJSONStreamId = dataJSONStream.%Id()
	
	set propertyJSONStream=##class(%Stream.FileBinary).%New()
	d properties.%ToJSON(.propertyJSONStream)
	d propertyJSONStream.%Save()
	set propertyJSONStreamId = propertyJSONStream.%Id()
	
	q $$$OK
}
}
