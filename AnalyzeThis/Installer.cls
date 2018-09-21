Class AnalyzeThis.Installer
{

ClassMethod Initialize() [ CodeMode =  objectgenerator ]
{
	Set tSC = $$$OK
	
	Set tSC = ##class(AnalyzeThis.Installer).SetupUserPortalLink()
	
	Quit tSC
}

ClassMethod SetupUserPortalLink() As %Status
{
	Set tItem = ##class(%DeepSee.UserLibrary.Link).%New()
	Set tItem.fullName = "Analyze This"
	Set tPage = "AnalyzeThis.UI.CSVImport.zen"
	Set tItem.href = $system.CSP.GetPortalApp($namespace,tPage) _ tPage
	Set tItem.title = "Analyze This"
	Set tSC = tItem.%Save()
	
	Quit tSC
}

}