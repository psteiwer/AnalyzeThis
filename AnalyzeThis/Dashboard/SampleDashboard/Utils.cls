Include %DeepSee

Class AnalyzeThis.Dashboard.SampleDashboard.Utils
{
/// Delete all data and classes for a specific cube.
ClassMethod DeleteAll(pName As %String) As %Status
{
	If ('##class(%DeepSee.Utils).%CubeExists(pName)) {
		Quit $$$ERROR($$$GeneralError,"Please enter a valid cube name")
	}

	set tCubeName=$$$UPPER(pName)
	
	set tCubeClass=##class(%DeepSee.Utils).%GetCubeClass(tCubeName)
	set tCubeFactClass=##class(%DeepSee.Utils).%GetCubeFactClass(tCubeName)
	set tSourceClass=$$$DeepSeeMetaGLVN("cubes",tCubeName,"sourceClass")
	
	//Delete pivots associated with the cube
	Do ##class(AnalyzeThis.UI.CSVImport).GetPivotList(.pivots,,pName)
	Set pivot = $O(pivots(""))
	While pivot '= "" {
		Do ##class(%DeepSee.UserLibrary.Utils).%DeleteFolderItem(pivots(i))
		Set pivot = $O(pivots(pivot))
	}
	
	set tSC=$classmethod(tCubeFactClass,"%DeleteExtent")
	If $$$ISERR(tSC) {
		Quit tSC
	}
	set tSC=$system.OBJ.Delete(tCubeClass,"/displayerror=0 /displaylog=0")
	If $$$ISERR(tSC) {
		Quit tSC
	}
	
	set tSC=$classmethod(tSourceClass,"%DeleteExtent")
	If $$$ISERR(tSC) {
		Quit tSC
	}
	set tSC=$system.OBJ.Delete(tSourceClass,"/displayerror=0 /displaylog=0")
	If $$$ISERR(tSC) {
		Quit tSC
	}
	
	//Delete MetaDataAnalysis associated with cube
	set tSC=##class(AnalyzeThis.Dashboard.MetaData).Delete(pName)
	If $$$ISERR(tSC) {
		Quit tSC
	}
	
	//Delete Dashboards associated with the cube
	Set dashboards(1) = "Generated/Samples for "_pName_".dashboard"
	Set dashboards(2) = "Generated/Sample ScoreCard for "_pName_".dashboard"
	
	Set dashIdx = $O(dashboards(""))
	While dashIdx '= "" {
		set dashName=dashboards(dashIdx)
		Set dash=##class(%DeepSee.Dashboard.Utils).%DashboardExists(dashName)
		If (dash) {
			Set tSC=##class(%DeepSee.Dashboard.Utils).%DeleteDashboard(dashName)
			If $$$ISERR(tSC) {
				Quit
			}
		}
		
		Set dashIdx = $O(dashboards(dashIdx))
	}
	If $$$ISERR(tSC) {
		Quit tSC
	}

	k ^DeepSee.ImportCSV(tSourceClass,pName)
	
	Quit tSC
}

}
