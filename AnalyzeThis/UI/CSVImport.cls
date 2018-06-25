Include %DeepSee

/// DeepSee CSV Import page.
/// This page lets you import data from a CSV file into DeepSee.
Class AnalyzeThis.UI.CSVImport Extends %DeepSee.UI.standardPage [ System = 4 ]
{
Parameter Version = 1;

/// Displayed name of this page.
Parameter PAGENAME = "CSV Import";

/// If this page has multiple views, this is its initial display mode.
Parameter DEFAULTVIEWMODE;

Parameter DOCBOOKID;

/// If true, the user has write access to the page.
Property canWritePage As %ZEN.Datatype.boolean [ InitialExpression = 1 ];

/// If true, user can modify this particular listing group.
Property canWrite As %ZEN.Datatype.boolean [ InitialExpression = 1 ];

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">

.ribbonTitle {
	color: #404040;
	background: rgb(147,191,252);
}

.dynaGridWrapper {
	border: 1px solid #808080;
}

#command_cmdRemove {
	background: rgb(141,53,53);
}

body {
	background: #F8F8F8;
}

.dgCellInner {
	font-size: 12pt;
}

.zenLabel, .checkboxCaption {
	color: #404040;
	font-size: 10pt;
}
.zenLabelDisabled {
	color: #808080;
	font-size: 10pt;
}

.zenHint {
	color: #606060;
	font-size: 8pt;
}

#editGroup {
	opacity: 0.0;
	-webkit-transition-property: opacity;
	-webkit-transition-duration: 0.5s;
	-webkit-transition-timing-function: ease;
	-moz-transition-property: opacity;
	-moz-transition-duration: 0.5s;
	-moz-transition-timing-function: ease;
}

#propertyGroup {
	position: relative;
	width: 320px;
	opacity: 0.0;
	-webkit-transition-property: opacity;
	-webkit-transition-duration: 0.5s;
	-webkit-transition-timing-function: ease;
	-moz-transition-property: opacity;
	-moz-transition-duration: 0.5s;
	-moz-transition-timing-function: ease;

	border-left: 1px solid #808080;
	border-right: 1px solid #808080;
	border-bottom: 1px solid #808080;
	overflow: auto;
background: #f6f8f9; /* Old browsers */
background: -moz-linear-gradient(-45deg,  #f6f8f9 0%, #e5ebee 50%, #d7dee3 51%, #f5f7f9 100%); /* FF3.6+ */
background: -webkit-gradient(linear, left top, right bottom, color-stop(0%,#f6f8f9), color-stop(50%,#e5ebee), color-stop(51%,#d7dee3), color-stop(100%,#f5f7f9)); /* Chrome,Safari4+ */
background: -webkit-linear-gradient(-45deg,  #f6f8f9 0%,#e5ebee 50%,#d7dee3 51%,#f5f7f9 100%); /* Chrome10+,Safari5.1+ */
background: -o-linear-gradient(-45deg,  #f6f8f9 0%,#e5ebee 50%,#d7dee3 51%,#f5f7f9 100%); /* Opera 11.10+ */
background: -ms-linear-gradient(-45deg,  #f6f8f9 0%,#e5ebee 50%,#d7dee3 51%,#f5f7f9 100%); /* IE10+ */
background: linear-gradient(-45deg,  #f6f8f9 0%,#e5ebee 50%,#d7dee3 51%,#f5f7f9 100%); /* W3C */
filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f6f8f9', endColorstr='#f5f7f9',GradientType=1 ); /* IE6-9 fallback on horizontal gradient */
}

.gridLabel {
	color: #808080;
	padding: 3px;
	font-size: 24px;
}

#help {
	padding: 10px;
	font-size: 12px;
	color: #606060;
}

#termList {
	width: 500px;
	height: 200px;
	border: 10px solid #E0E0E0;
	border-radius: 5px;
}

.termItemEven {
	width: 100%;
	background: #F8F8F8;
	color: #404040;
	font-family: arial;
	border-bottom: 1px solid #D0D0D0;
}

.termItemOdd {
	width: 100%;
	color: #404040;
	font-family: arial;
	border-bottom: 1px solid #D0D0D0;
}

.tlHeader {
	position: relative;
	height: 40px;
	vertical-align: middle;
	border-bottom: 1px solid white;
	padding: 4px;
	background: #808080;
	color: #F0F0F0;
	font-size: 10pt;
	font-weight: bold;
}

.tlBody {
	position: absolute;
	top: 40px;
	bottom: 0px;
	left:0px;
	right: 0px;
	background: #D0D0D0;
}

.tlItem,
.tlItemSelected {
	position: relative;
	padding: 4px;
	height: 25px;
	vertical-align: middle;
	font-size: 20px;
	color: #404040;
	background: #F0F0F0;
	border-bottom: 1px solid #D0D0D0;
}

.tlItemSelected {
	color: #F0F0F0;
	background: rgb(53,107,141);
}

.tlItem:hover {
	background: #E8E8E8;
}

.dynaTreeNode {
	white-space: nowrap;
	font-size: 10pt;
}

.dynaTreeItem {
	color: rgb(71,72,67);
}

</style>
}

XData contentPane [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane xmlns="http://www.intersystems.com/zen">
<hgroup valign="top" >
<spacer width="20" />
<vgroup valign="top" >
<spacer height="20" />
<tablePane id="table"
    cellSpacing="2"
	fixedHeaders="false"	
	queryClass="AnalyzeThis.UI.CSVImport"
	queryName="GetImportedCubes"
	useSnapshot="true"
	showQuery="false"
	showZebra="true"
	showRowNumbers="false"
	maxRows="5000"
	valueColumn="CubeName"
	
	>
<column colName="CubeName" header="Cube Name" />
<column colName="Analyzer" link="#(%query.Application)#_DeepSee.UI.Analyzer.zen?CUBE=#(%query.CubeName)#"/>
<column colName="Architect" link="#(%query.Application)#_DeepSee.UI.Architect.zen?CUBE=#(%query.CubeName)#"/>
<column colName="Dashboard" link="#(%query.Application)#_DeepSee.UserPortal.DashboardViewer.zen?DASHBOARD=Generated/Samples%20for%20#(%query.CubeName)#.dashboard"/>
<column colName="ScoreCard" link="#(%query.Application)#_DeepSee.UserPortal.DashboardViewer.zen?DASHBOARD=Generated/Sample%20ScoreCard%20for%20#(%query.CubeName)#.dashboard"/>
<column colName="Info" onclick="return zenPage.showInfo('#(%query.CubeName)#');" linkCaption="Info" link="#"/>
<column colName="Application" hidden="true"/>
</tablePane>
</vgroup>
</hgroup>
</pane>
}

/// Get the (localized) title string for the page.
/// This should be implemented in a subclass.
Method %OnGetTitle() As %String [ Internal ]
{
	Quit $$$Text("CSV Import","AnalyzeThis")
}

/// Get the (localized) name of the page.
Method %OnGetPageName() As %String [ Internal ]
{
	Quit $$$Text("CSV Import","AnalyzeThis")
}

/// Get the product name for the page.
Method %OnGetProductName() As %String [ Internal ]
{
	Quit "DeepSee"
}

/// Get information to display in the ribbon bar.
Method OnGetRibbonInfo(Output pDisplay As %Boolean, Output pViewIcons As %List, Output pSortOptions As %List, Output pSearchBox As %Boolean, Output pRibbonTitle As %String, Output pCommands As %List) As %Status [ Internal ]
{
	Set pDisplay = 1
	Set pSearchBox = 0
	Set pRibbonTitle = $$$Text("Import CSV Data")

	// commands
	// $LB(id,caption,help,onclick)
	Set:(..canWrite||..canWritePage) pCommands($I(cmdIdx)) = $LB("cmdNew",$$$Text("New"),$$$Text("Create a cube based off a CSV file"),"zenPage.newCube();")
	//Set:..canWrite pCommands($I(cmdIdx)) = $LB("cmdOpen",$$$Text("Open"),$$$Text("Open this cube"),"zenPage.openCube();")
	Set:..canWrite pCommands($I(cmdIdx)) = $LB("cmdRemove",$$$Text("Delete"),$$$Text("Delete this cube"),"zenPage.deleteCube();")
	
	Quit $$$OK
}

/// OCnvenience utility for setting the ribbon message
ClientMethod setRibbonMessage(message) [ Internal, Language = javascript ]
{
	if (message == undefined) {
		message = '';
	}
	self.document.getElementById('ribbonMessage').innerHTML=message;
}

/// This client event is fired when a popup page launched from this page fires an action.
ClientMethod onPopupAction(popupName, action, value) [ Internal, Language = javascript ]
{
	switch(popupName) {
	case 'switchNamespace':
		var homeurl = zenLink("/csp/sys/%25CSP.Portal.Home.zen");
		var url = zenPage.GetNewURL(value,"AnalyzeThis.UI.CSVImport.zen");
		if (url == "" || value == "%SYS") url = homeurl;
		self.document.location = url;
		break;
	case 'CSVImport':
		if (action=="okay") {
			try {
				self.document.location = zenLink('AnalyzeThis.UI.CSVImport.cls');
			}
			catch(ex) {
			}
		}
		if (action=="dash") {
			try {
				self.document.location=zenLink('_DeepSee.UserPortal.DashboardViewer.zen?DASHBOARD=Generated/Samples%20for%20'+value+'.dashboard')	
			}
			catch(ex)
			{
			}
		}
		if (action=="score") {
			try {
			self.document.location=zenLink('_DeepSee.UserPortal.DashboardViewer.zen?DASHBOARD=Generated/Sample%20ScoreCard%20for%20'+value+'.dashboard')	
			}
			catch(ex)
			{
			}
		}


		break;
}
}

/// This is called in the middle of rendering the tool ribbon.
/// Subclasses can inject their own content into the ribbon by writing it out in this method.
/// This content is best wrapped within a single td element.
/// It can also consist of multiple td elements.
/// <p>
/// To achieve a fixed position for elements within the ribbon, for a fixed width page you can 
/// use a single enclosing td that contains a table and a single tr, 
/// with td elements inside that single tr that contain your content for the ribbon.
/// <p>
/// To achieve a fixed position for elements within the ribbon, 
/// for a page whose width varies depending on its contents (thereby stretching the ribbon)
/// you can use multiple td elements to contain your content and then a final
/// td element that is empty and has width 40% (or so) to push your contents towards the left
/// and keep them in their proper locations.
Method OnDrawRibbon() As %Status [ Internal ]
{
	&html<<td id="ribbonSpacer" width="5%"></td>>
	&html<<td id="ribbonMessage" style="color:red" width="20%"></td>>
	Quit $$$OK
}

/// Create a new cube.
ClientMethod newCube() [ Internal, Language = javascript ]
{
	if (this.pageModified) {
		if (!confirm($$$Text('There are unsaved changes, do you wish to continue?'))) {
			return;
		}
	}
	var parms = {
			MODE:"models",
	};
	
	zenLaunchPopupWindow('AnalyzeThis.UI.Dialog.CSVImport.cls','CSVImport','status,resizable=yes,width=900,height=700',parms);
}

/// View info about cube.
ClientMethod showInfo(pCubeName) [ Language = javascript ]
{
	if (this.pageModified) {
		if (!confirm($$$Text('There are unsaved changes, do you wish to continue?'))) {
			return;
		}
	}
	var parms = new Object();
	parms.cubeName=pCubeName;
	
	zenPage.launchPopupWindow('AnalyzeThis.UI.Dialog.CSVImport.showInfo.cls','CSVImport','status,resizable=yes,width=900,height=700',parms);

	//d ##class(AnalyzeThis.UI.Dialog.CSVImport.showInfo).drawStats(pCubeName)
}

/// Create a new cube.
ClientMethod openCube() [ Language = javascript ]
{
	if (zenPage.getComponentById("table").getValue()!="") {
		if (this.pageModified) {
			if (!confirm($$$Text('There are unsaved changes, do you wish to continue?'))) {
				return;
			}
		}
		var parms = {
				MODE:"models",
				CUBE:zenPage.getComponentById("table").getValue(),
		};
		
		zenLaunchPopupWindow('AnalyzeThis.UI.Dialog.CSVImportOpen.cls','CSVImportOpen','status,scrollbars,resizable=yes,width=900,height=700',parms);
	} else {
		alert("Please select a cube below");
	}
}

/// Delete the current cube.
ClientMethod deleteCube() [ Language = javascript ]
{
	if (zenPage.getComponentById("table").getValue()!="") {
		if (confirm($$$Text('Do you wish to remove all dashboards, pivot tables, cubes, and classes associated with '+zenPage.getComponentById("table").getValue()))) {
			zenPage.setRibbonMessage('Deleting '+zenPage.getComponentById("table").getValue()+'...');
			this.Delete(zenPage.getComponentById("table").getValue())
			try {
				self.document.location = zenLink('AnalyzeThis.UI.CSVImport.cls');
			}
			catch(ex) {
			}
		}
	}
}

/// Delete a cube.
Method Delete(pName As %String) As %String [ ZenMethod ]
{
	Set tMsg = "Cube Deleted."
	
	Set tSC=##class(AnalyzeThis.Dashboard.Utils).DeleteAll(pName)
	If $$$ISERR(tSC) {
		Set tMsg = $System.Status.GetErrorText(tSC)
	}
	
	Quit tMsg
}

/// Return a list of all currently defined DeepSee Pivots visible to the current user.
/// This is used by utilities.<br/>
/// This list takes the form:<br/>
/// pList(i)=fullName
/// If <var>pHidden</var> is true, then include trash and local items.<br/>
/// If <var>pCubeName</var> is provided, then only list pivots based on it.
ClassMethod GetPivotList(Output pList, pHidden As %Boolean = 0, pCubeName As %String = "") As %Status
{
	Set tSC = $$$OK
	Kill pList
	Try {
		set i=1
		Set tFlag = $zu(115,8,0)
		Set tStatement = ##class(%SQL.Statement).%New(,"DEFAULT_SCHEMA")
		Set tSC = tStatement.%Prepare("SELECT ID FROM %DeepSee_Dashboard.Pivot")
		If $$$ISERR(tSC) Quit
		
		Set pCubeName = $$$UPPER(pCubeName)

		Set tRS = tStatement.%Execute()
		While (tRS.%Next(.tSC)) {
			If $$$ISERR(tSC) Quit
			If (tRS.ID '="") {
				Set tItem = ##class(%DeepSee.UserLibrary.FolderItem).%OpenId(tRS.ID)
				If ($IsObject(tItem)) {			
					Set tFullName = $P(tItem.fullName,".",1) // name without extension
					If (pHidden || ($E(tFullName,1)'="$") || ($E(tFullName,1,3)="$$$")) {
						If ((pCubeName="")||(pCubeName=$$$UPPER(tItem.cubeName))) {
							If (tItem.%CheckResource()) {
								Set pList(i) = tItem.fullName
								set i=i+1
							}
						}
					}
				}
			}
		}
	}
	Catch(ex) {
		Set tSC = ex.AsStatus()
	}
	Set tFlag = $zu(115,8,tFlag)
	Quit tSC
}

Query GetImportedCubes() As %Query(ROWSPEC = "CubeName,Analyzer,Architect,Dashboard,ScoreCard,Info,Application") [ SqlProc ]
{
}

ClassMethod GetImportedCubesExecute(ByRef qHandle As %Binary) As %Status
{
	Set tSC = $$$OK
	kill ^||AnalyzeThis.CSVImportExecute
	set CubeName=$o(^DeepSee.ImportCSV(""))
	while CubeName'="" {
		Set dashName="Generated/Samples for "_CubeName_".dashboard"
		Set dash=##class(%DeepSee.Dashboard.Utils).%DashboardExists(dashName)
		Set scoreCardName="Generated/Sample ScoreCard for "_CubeName_".dashboard"
		Set scoreCard=##class(%DeepSee.Dashboard.Utils).%DashboardExists(scoreCardName)
		set ^||AnalyzeThis.CSVImportExecute($i(count))=$lb(CubeName,"Analyzer","Architect",$case(dash, 0:"", 1:"Dashboard"),$case(scoreCard, 0:"", 1:"ScoreCard"),"Info",$system.CSP.GetPortalApp($NAMESPACE,$replace($this,"%","_")_".zen"),"info")
		set CubeName=$o(^DeepSee.ImportCSV(CubeName))
	}
    Set qHandle = $LB("")
    Quit tSC
}

ClassMethod GetImportedCubesFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status
{
	set index=$list(qHandle,1)
	set index=$o(^||AnalyzeThis.CSVImportExecute(index))
    If index="" {
        Set Row = ""
        Set AtEnd = 1
    }
    Else {
        Set Row = ^||AnalyzeThis.CSVImportExecute(index)
    }
    Set qHandle = $LB(index)
    Quit $$$OK
}

ClassMethod GetImportedCubesClose(ByRef qHandle As %Binary) As %Status [ Internal, PlaceAfter = GetImportedCubesExecute ]
{
    Set qHandle = ""
    Quit $$$OK
}

ClassMethod AddDetails(pCubeName As %String)
{
	set ^AnalyzeThis.ImportCSV(pCubeName, ..#Version)=1
}

}
