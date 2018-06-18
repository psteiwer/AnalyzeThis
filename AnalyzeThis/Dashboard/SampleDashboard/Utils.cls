Include %DeepSee

Class AnalyzeThis.Dashboard.SampleDashboard.Utils
{

ClassMethod DeleteMetaData(pCubeName As %String) As %Status
{
 Set exist=""
 &sql(SELECT %ID INTO :exist FROM AnalyzeThis_Dashboard.MetaData WHERE (CubeName=:pCubeName))
 if ((SQLCODE = 0)&&(exist'="")) 
 {
	&sql(DELETE FROM AnalyzeThis_Dashboard.MetaData WHERE (CubeName=:pCubeName))
 }
 quit $$$OK
}

/// Delete all data and classes for a specific cube.
ClassMethod DeleteAll(pName As %String) As %String
{
	Set tMsg = "Cube deleted."
	
	If ('##class(%DeepSee.Utils).%CubeExists(pName)) {
		Quit $$$ERROR($$$GeneralError,"Please enter a valid cube name")
	}

	set tCubeName=$$$UPPER(pName)
	
	set tCubeClass=##class(%DeepSee.Utils).%GetCubeClass(tCubeName)
	set tCubeFactClass=##class(%DeepSee.Utils).%GetCubeFactClass(tCubeName)
	set tSourceClass=$$$DeepSeeMetaGLVN("cubes",tCubeName,"sourceClass")
	
	//Delete pivots associated with the cube
	Do ##class(AnalyzeThis.UI.CSVImport).GetPivotList(.pivots,,pName)
	Set i=1
	While $DATA(pivots(i))
	{
		Do ##class(%DeepSee.UserLibrary.Utils).%DeleteFolderItem(pivots(i))
		Set i=i+1
	}
	
	set tSC=$classmethod(tCubeFactClass,"%DeleteExtent")
	If $$$ISERR(tSC) {
		Set tMsg = $System.Status.GetErrorText(tSC)
		Quit tMsg
	}
	set tSC=$system.OBJ.Delete(tCubeClass,"/displayerror=0 /displaylog=0")
	If $$$ISERR(tSC) {
		Set tMsg = $System.Status.GetErrorText(tSC)
		Quit tMsg
	}
	
	set tSC=$classmethod(tSourceClass,"%DeleteExtent")
	If $$$ISERR(tSC) {
		Set tMsg = $System.Status.GetErrorText(tSC)
		Quit tMsg
	}
	set tSC=$system.OBJ.Delete(tSourceClass,"/displayerror=0 /displaylog=0")
	If $$$ISERR(tSC) {
		Set tMsg = $System.Status.GetErrorText(tSC)
		Quit tMsg
	}
	
	//Delete MetaDataAnalysis associated with cube
	set tSC=##class(AnalyzeThis.Dashboard.SampleDashboard.Utils).DeleteMetaData(pName)
	If $$$ISERR(tSC) {
		Set tMsg= $System.Status.GetErrorText(tSC)
		Quit tMsg
	}
	
	//Delete Dashboards assoicated with the cube
	set dashName="Generated/Samples for "_pName_".dashboard"
	Set dash=##class(%DeepSee.Dashboard.Utils).%DashboardExists(dashName)
	If (dash) {
		Set tSC=##class(%DeepSee.Dashboard.Utils).%DeleteDashboard(dashName)
		If $$$ISERR(tSC) {
			Set tMsg = $System.Status.GetErrorText(tSC)
			Quit tMsg
		}
	}
	
	set dashName="Generated/Sample ScoreCard for "_pName_".dashboard"
	Set dash=##class(%DeepSee.Dashboard.Utils).%DashboardExists(dashName)
	If (dash) {
		Set tSC=##class(%DeepSee.Dashboard.Utils).%DeleteDashboard(dashName)
		If $$$ISERR(tSC) {
				Set tMsg = $System.Status.GetErrorText(tSC)
				Quit tMsg
		}
	}

	k ^DeepSee.ImportCSV(tSourceClass,pName)
	
	Quit tMsg
}

}
