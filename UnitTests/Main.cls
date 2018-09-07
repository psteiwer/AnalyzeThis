Class UnitTests.Main
{

ClassMethod Run() As %Status
{
	Set tSC=$$$OK
	
	// Export files
	Set tSQL="SELECT ID FROM %Dictionary.CompiledClass Where ID [ ?"
	Set tSQLRS=##class(%SQL.Statement).%ExecDirect(,tSQL,"UnitTests")
	While tSQLRS.%Next() {
		Continue:tSQLRS.ID="UnitTests.Main"
		Do $system.OBJ.Export(tSQLRS.ID_".cls",^UnitTestRoot_"AnalyzeThis\cls\UnitTests\"_$p(tSQLRS.ID,".",2,*)_".xml")
	}
	
	// Run Unit Tests
	Do ##class(%UnitTest.Manager).RunTest("AnalyzeThis")
	
	Quit tSC
}

}