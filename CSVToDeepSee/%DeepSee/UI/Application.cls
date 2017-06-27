/// Zen application class for pages within the DeepSee portal.
/// 
Class %DeepSee.UI.Application Extends %ZEN.Portal.Application [ System = 4 ]
{

/// This is the name of this application.
Parameter APPLICATIONNAME = "DeepSee";

/// Set this to the correct domain.
Parameter DOMAIN = "%DeepSee";

/// This is the URL of the main starting page of this application.
Parameter HOMEPAGE = "_DeepSee.UI.Home.zen";

/// This Style block contains application-wide CSS 3 style definitions.
XData CSS3Style
{
<style type="text/css">
body {
	font-family: Arial;
	background: #E0E0D0;
}

/* overrider locator bar style */
.locatorBarTable td {
	background: rgb(47,98,128);
	background-image: none;
	background-repeat: repeat-x;
	border-bottom: 1px darkblue solid;
	padding-bottom: 1px;
	color: white;
}

.locatorBarLinks {
	color: white;
}
.locatorBarLinks a {
	color: white;
}
.locatorBarLinks a:visited {
	color: white;
}
.locatorBarLinks a:hover {
	color: red;
	background: #FFFAE7;
}
.locatorBarSelect {
	color: white;
}

/* !!! */
#propertyPanel {
	position: relative;
	background: #707070;
	height: 481px;
	width: 450px;
}

/* !!! */
#searchForm {
	position: absolute;
	top: 60px;
	bottom: 0px;
	right: 0px;
	left: 0px;
	color: black;
	background: #E0E0D0;
	border: 1px solid black;
	font-size: 11pt;
}

.dsPropertyPanelTitle {
	color: white;
	font-size: 12pt;
	padding: 5px;
}

.dsPropertyPanelCommands {
	color: white;
	background: black;
	width: 100px;
	text-align: center;
	font-size: 9pt;
	border: 1px solid gray;
}

.dsTitle {
	width: 100%;
	height: 60px;
	background: #E0E0D0;
	position: relative;
	border-bottom: 1px solid gray;
}

.dsTitleInfoBox {
	position: absolute;
	bottom: 0px;
	left: 400px;
}

.dsTitleInfoLabel {
	padding-left: 10px;
	font-size: 9pt;	
	color: #606060;
	text-align: right;
}

.dsTitleInfoVal {
	font-size: 9pt;	
	color: black;
	text-align: left;
	font-weight: bold;
}

.dsTitleMenuBox {
	position: absolute;
	top: 5px;
	left: 20px;
	font-size: 9pt;	
}

.dsTitleLink {
	color: darkblue;
}

.dsTitleTabBox {
	position: absolute;
	color: white;
	font-size: 14pt;
	bottom: 0px;
	left: 20px;
	width: 250px;
	padding-left: 15px;
	padding-right: 15px;
	padding: 5px;
	background: rgb(47,98,128);
	border-top-left-radius: 5px;
	border-top-right-radius: 5px;
}

.dsLogoBox {
	position: absolute;
	top: 10px;
	right: 40px;
	text-align: center;
}

.dsLogo {
	position: relative;
	font-weight: bold;
	font-size: 12pt;
	top: 0px;
	right: 0px;
	border: 2px solid black;
	padding: 2px;
	padding-left: 5px;
	padding-right: 5px;
	border-radius: 4px;
	background: #E0E0F0;
}

.dsLogoSub {
	position: relative;
	color: #808080;
	font-size: 8pt;
	top: 3px;
	right: 0px;
}
</style>
}

/// This Style block contains application-wide CSS style definitions.
XData Style
{
<style type="text/css">
body {
	font-family: Arial;
	background: #E0E0D0;
}

/* overrider locator bar style */
.locatorBarTable td {
	background: rgb(47,98,128);
	background-image: none;
	background-repeat: repeat-x;
	border-bottom: 1px darkblue solid;
	padding-bottom: 1px;
	color: white;
}

.locatorBarLinks {
	color: white;
}
.locatorBarLinks a {
	color: white;
}
.locatorBarLinks a:visited {
	color: white;
}
.locatorBarLinks a:hover {
	color: red;
	background: #FFFAE7;
}
.locatorBarSelect {
	color: white;
}

/* !!! */
#propertyPanel {
	position: relative;
	background: #707070;
	height: 481px;
	width: 450px;
}

/* !!! */
#searchForm {
	position: absolute;
	top: 60px;
	bottom: 0px;
	right: 0px;
	left: 0px;
	color: black;
	background: #E0E0D0;
	border: 1px solid black;
	font-size: 11pt;
}

.dsPropertyPanelTitle {
	color: white;
	font-size: 12pt;
	padding: 5px;
}

.dsPropertyPanelCommands {
	color: white;
	background: black;
	width: 100px;
	text-align: center;
	font-size: 9pt;
	border: 1px solid gray;
}

.dsTitle {
	width: 100%;
	height: 60px;
	background: #E0E0D0;
	position: relative;
	border-bottom: 1px solid gray;
}

.dsTitleInfoBox {
	position: absolute;
	bottom: 0px;
	left: 400px;
}

.dsTitleInfoLabel {
	padding-left: 10px;
	font-size: 9pt;	
	color: #606060;
	text-align: right;
}

.dsTitleInfoVal {
	font-size: 9pt;	
	color: black;
	text-align: left;
	font-weight: bold;
}

.dsTitleMenuBox {
	position: absolute;
	top: 5px;
	left: 20px;
	font-size: 9pt;	
}

.dsTitleLink {
	color: darkblue;
}

.dsTitleTabBox {
	position: absolute;
	color: white;
	font-size: 14pt;
	bottom: 0px;
	left: 20px;
	width: 250px;
	padding-left: 15px;
	padding-right: 15px;
	padding: 5px;
	background: rgb(47,98,128);
	-moz-border-radius-topleft: 5px;
	-moz-border-radius-topright: 5px;
}

.dsLogoBox {
	position: absolute;
	top: 10px;
	right: 40px;
	text-align: center;
}

.dsLogo {
	position: relative;
	font-weight: bold;
	font-size: 12pt;
	top: 0px;
	right: 0px;
	border: 2px solid black;
	padding: 2px;
	padding-left: 5px;
	padding-right: 5px;
	-moz-border-radius: 4px;
	background: #E0E0F0;
}

.dsLogoSub {
	position: relative;
	color: #808080;
	font-size: 8pt;
	top: 3px;
	right: 0px;
}
</style>
}

/// Provide any quick links for pages.
ClassMethod GetQuickLinks(Output pLinks) As %Status
{
	Set pLinks("Home") = "_DeepSee.UI.Home.zen"
	Quit $$$OK
}

/// Provide finder contents for the DeepSee pages. Called from %CSP.Portal.Home.
ClassMethod GetDeepSeeArray(Output pData) As %Status
{
	Set tNoHTML5 = 1
	If (%page.cssLevel>=3) Set tNoHTML5 = 0
	
	//Set pMetaData = $LB("name","title","link","disabled","icon","description")
	Set lblNoHTML5 = $$$TextHTML("DeepSee Visual Reporting requires the use of an HTML5 compliant browser.")
	Set lblNoPriv = $$$TextHTML("You do not have privilege to view this page.")	
	Set tUse = $$CheckArchitectViewAccess^%qdsUtils()
	Set tDisabled = 'tUse
	Set tText = $$$TextHTML("Create and modify DeepSee data models")
	Set tLinkTitle = $Case(tDisabled,0:tText,:lblNoPriv)
	Set pData($I(n)) = $LB($$$Text("Architect"),tLinkTitle,..Link("_DeepSee.UI.Architect.zen"),tDisabled,..Link("portal/architect_48.gif"),tText)
	
	Set tUse = $$CheckAnalyzerViewAccess^%qdsUtils()
	Set tDisabled = 'tUse
	Set tText = $$$TextHTML("Create and modify DeepSee pivot tables based on DeepSee data models")
	Set tLinkTitle = $Case(tDisabled,0:tText,:lblNoPriv)	
	Set pData($I(n)) = $LB($$$Text("Analyzer"),tLinkTitle,..Link("_DeepSee.UI.Analyzer.zen"),tDisabled,..Link("portal/comparison_chart_48.gif"),tText)
	
	Set tUse = $System.Security.Check("%DeepSee_Portal","USE")||
				$System.Security.Check("%DeepSee_PortalEdit","USE")
	Set tDisabled = 'tUse
	Set tText = $$$TextHTML("View the DeepSee User Portal")
	Set tLinkTitle = $Case(tDisabled,0:tText,:lblNoPriv)
	Set pData($I(n)) = $LB($$$Text("User Portal"),tLinkTitle,..Link("_DeepSee.UserPortal.Home.zen"),tDisabled,..Link("portal/clients_48.gif"),tText)
	
	
	// ====== VISUAL REPORTING SUB-MENU
	Set tUse = $$CheckReportExecuteAccess^%qdsUtils()
	Set tDisabled = 'tUse
	Set tText = $$$Text("Create and modify DeepSee Visual Reporting objects")
	Set tLinkTitle = $Case(tDisabled,0:tText,:lblNoPriv)
	Set pData($I(n)) = $LB($$$Text("Visual Reporting"),tLinkTitle,,tDisabled,..Link("portal/icon_deepseeReports.png"),tText)
 
		Set n2 = 0
		Set tUse = $$CheckReportDataDefAccess^%qdsUtils()
		Set tDisabled = 'tUse
		Set tText = $$$Text("Create and modify data collection modules and schema")
		Set tLinkTitle = $Case(tDisabled,0:tText,:lblNoPriv)
		Set tLinkTitle = $Case(tNoHTML5,0:tLinkTitle,:lblNoHTML5)
		If ('tDisabled) Set tDisabled = tNoHTML5
		Set pData(n,$I(n2)) = $LB($$$Text("Report Data Definition"),tLinkTitle,,tDisabled,..Link("portal/DSCollector.png"),tText)
			Set n3 = 0

			Set tText = $$$Text("Design master queries for use in printed reports")
			Set tLinkTitle = $Case(tDisabled,0:tText,:lblNoPriv)
			Set tLinkTitle = $Case(tNoHTML5,0:tLinkTitle,:lblNoHTML5)
			If ('tDisabled) Set tDisabled = tNoHTML5
			Set pData(n,n2,$I(n3)) = $LB($$$Text("Data Collection Builder"),tLinkTitle,..Link("_DeepSee.Report.UI.CreateDCR.zen"),tDisabled,..Link("portal/DSCollector.png"),tText)
			
			Set tText = $$$Text("Extract a schema definition from an existing Zen Report")
			Set tLinkTitle = $Case(tDisabled,0:tText,:lblNoPriv)
			Set tLinkTitle = $Case(tNoHTML5,0:tLinkTitle,:lblNoHTML5)
			If ('tDisabled) Set tDisabled = tNoHTML5
			Set pData(n,n2,$I(n3)) = $LB($$$Text("Extract from legacy report"),tLinkTitle,..Link("_DeepSee.Report.UI.ExtractDSS.zen"),tDisabled,..Link("portal/DSSBuilder.png"),tText)

			Set tText = $$$Text("Generate a schema definition from an existing SQL query")
			Set tLinkTitle = $Case(tDisabled,0:tText,:lblNoPriv)
			Set tLinkTitle = $Case(tNoHTML5,0:tLinkTitle,:lblNoHTML5)
			If ('tDisabled) Set tDisabled = tNoHTML5
			Set pData(n,n2,$I(n3)) = $LB($$$Text("Build from query"),tLinkTitle,..Link("_DeepSee.Report.UI.QueryBasedDSS.zen"),tDisabled,..Link("portal/DSSBuilder.png"),tText)

		Set tUse = $$CheckReportFormatDefAccess^%qdsUtils()
		Set tDisabled = 'tUse
		Set tText = $$$Text("Define and modify printed report layouts based on existing data sets")
		Set tLinkTitle = $Case(tDisabled,0:tText,:lblNoPriv)
		Set tLinkTitle = $Case(tNoHTML5,0:tLinkTitle,:lblNoHTML5)
		If ('tDisabled) Set tDisabled = tNoHTML5
		Set pData(n,$I(n2)) = $LB($$$Text("Report Builder"),tLinkTitle,,tDisabled,..Link("portal/icon_deepseeReports.png"),tText)

			Set n3 = 0
			Set tText = $$$Text("Design and edit tabular reports")
			Set tLinkTitle = $Case(tDisabled,0:tText,:lblNoPriv)
			Set pData(n,n2,$I(n3)) = $LB($$$Text("Line Item Report Builder"),tLinkTitle,..Link("_DeepSee.Report.UI.BuildLIDR.zen"),tDisabled,..Link("portal/lidrReport.png"),tText)

		Set tUse = $$CheckReportExecuteAccess^%qdsUtils()
		Set tDisabled = 'tUse
		Set tText = $$$Text("Execute an existing report")
		Set tLinkTitle = $Case(tDisabled,0:tText,:lblNoPriv)
 		Set pData(n,$I(n2)) = $LB($$$Text("Run Reports"),tText,..Link("_DeepSee.Report.UI.ExecuteReport.zen"),,..Link("portal/report_48.gif"),tText)
 
 
 	// ====== TOOLS SUB-MENU
	Set tText = $$$Text("Various DeepSee Tools")
	Set pData($I(n)) = $LB($$$Text("Tools"),tText,,,..Link("portal/eye_chart_info_48.gif"),tText)
		Set n2 = 0
		
		Set tUse = $System.Security.Check("%DeepSee_Admin","USE")||			// DTB287 - Add security check
		 			$System.Security.Check("%Development","USE")
		Set tDisabled = 'tUse
		Set tText = $$$Text("Execute ad hoc MDX queries against DeepSee models")
		Set pData(n,$I(n2)) = $LB($$$Text("Query Tool"),tText,..Link("_DeepSee.UI.MDXQuery.zen"),tDisabled,..Link("portal/sql_query_48.gif"),tText)

		Set tUse = $System.Security.Check("%DeepSee_PortalEdit","USE")		// DTB287 - Add security check
		Set tDisabled = 'tUse
		Set tText = $$$Text("Create and modify DeepSee Term Lists")
		Set pData(n,$I(n2)) = $LB($$$Text("Term List Manager"),tText,..Link("_DeepSee.UI.TermListManager.zen"),tDisabled,..Link("deepsee/summary_48.gif"),tText)

		// DTB084 - Add Listing Group Manager
		Set tUse = $$CheckListingGroupViewAccess^%qdsUtils()
		Set tText = $$$Text("Create and modify DeepSee Listing Groups")
		Set tDisabled = 'tUse
		Set tLinkTitle = $Case(tDisabled,0:tText,:lblNoPriv)
		Set pData(n,$I(n2)) = $LB($$$Text("Listing Group Manager"),tLinkTitle,..Link("_DeepSee.UI.ListingGroupManager.zen"),tDisabled,..Link("deepsee/summary_48.gif"),tText)

		If $System.Version.GetMajor() >= 2011 {
			Set tUse = $System.Security.Check("%DeepSee_PortalEdit","USE")	// DTB287 - Add security check
			Set tDisabled = 'tUse
			Set tText = $$$Text("Create and modify DeepSee Quality Measures")
			Set pData(n,$I(n2)) = $LB($$$Text("Quality Measures"),tText,..Link("_DeepSee.UI.QualityMeasures.zen"),tDisabled,..Link("portal/logo_design_48.gif"),tText)
		}

		If $System.Version.GetMajor() >= 2011 {
			Set tUse = $System.Security.Check("%DeepSee_PortalEdit","USE")	// DTB287 - Add security check
			Set tDisabled = 'tUse
			Set tText = $$$Text("Create and modify DeepSee Worksheets")
			Set pData(n,$I(n2)) = $LB($$$Text("Worksheet Builder"),tText,..Link("_DeepSee.UI.WorksheetBuilder.zen"),tDisabled,..Link("deepsee/spreadsheet_48.gif"),tText)
		}
		
		// DTB004 - Move Model Viewer to DeepSee Tools
		Set tText = $$$Text("View relationships between cube models")
		Set pData(n,$I(n2)) = $LB($$$Text("Model Browser"),tText,..Link("_DeepSee.UI.ModelBrowser.zen"),0,..Link("deepsee/ds2_orgchart_44.png"),tText)
		
		// BDB383 - Expose PMML Model Tester in DeepSee tools
		set tText = $$$Text("Test predictive models expressed as PMML")
		set pData(n,$i(n2)) = $lb($$$Text("PMML Model Tester"),tText,..Link("_DeepSee.PMML.UI.ModelTester.zen"),0,..Link("deepsee/ds2_beaker_44.png"),tText)

		// PFS CSV Data Import
		set tText = $$$Text("Import CSV Data")
		set pData(n,$i(n2)) = $lb($$$Text("Import CSV Data"),tText,..Link("_DeepSee.UI.CSVImport.zen"),0,..Link("deepsee/spreadsheet_48.gif"),tText)


	// ====== ADMIN SUB-MENU
	Set tText = $$$Text("Administrative Tools")
	Set pData($I(n)) = $LB($$$Text("Admin"),tText,,,..Link("portal/admin_config_48.gif"),tText)
		Set n2 = 0
		Set tText = $$$Text("View DeepSee log files")
		Set pData(n,$I(n2)) = $LB($$$Text("DeepSee Logs"),tText,..Link("_DeepSee.UI.LogViewer.zen"),,..Link("portal/folder_48.gif"),tText)

		Set tText = $$$Text("Manage the content of DeepSee folders")
		Set pData(n,$I(n2)) = $LB($$$Text("Folder Manager"),tText,..Link("_DeepSee.UI.FolderManager.zen"),,..Link("portal/folder_48.gif"),tText)
	
		Set tUse = $System.Security.Check("%DeepSee_Admin","USE")
		Set tDisabled = 'tUse
		Set tText = $$$TextHTML("View or modify DeepSee settings for this namespace")
		Set tLinkTitle = $Case(tDisabled,0:tText,:lblNoPriv)
		Set pData(n,$I(n2)) = $LB($$$Text("Settings"),tLinkTitle,..Link("_DeepSee.UI.Settings.zen"),tDisabled,..Link("portal/gear_48.gif"),tText)
		
		// DTB004 - Move Cube Management to submenu of DeepSee Admin
		Set tUse = $System.Security.Check("%DeepSee_Admin","USE")
		Set tDisabled = 'tUse
		Set tText = $$$Text("Cube Management")
		Set pData(n,$I(n2)) = $LB(tText,tText,,tDisabled,..Link("portal/admin_config_48.gif"),tText)
		
		Set n3=0
		Set tText = $$$Text("Register and schedule cubes to be automatically built and synchronized.")
		Set pData(n,n2,$I(n3)) = $LB($$$Text("Cube Registry"),tText,..Link("_DeepSee.UI.CubeRegistry.zen"),,..Link("deepsee/ds_chart_treemap.png"),tText)
	
	Quit $$$OK
}

}
