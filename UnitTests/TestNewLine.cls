Class UnitTests.TestNewLine Extends %UnitTest.TestCase
{


Method TestInpatients()
{
	Set text = "DRG Definition,Provider Id,Provider Name,Provider Street Address,Provider City,Provider State,Provider Zip Code,Hospital Referral Region Description, Total Discharges , Average Covered Charges , Average Total Payments ,Average Medicare Payments"_$c(13,10)_"EXTRACRANIAL PROCEDURES,10001,SOUTHEAST ALABAMA MEDICAL CENTER,1108 ROSS CLARK CIRCLE,DOTHAN,AL,36301,AL - Dothan,91,32963.07,5777.24,4763.73"_$c(13,10)_"EXTRACRANIAL PROCEDURES,10005,MARSHALL MEDICAL CENTER SOUTH,2505 U S HIGHWAY 431 NORTH,BOAZ,AL,35957,AL - Birmingham,14,15131.85,5787.57,4976.71"_$c(13,10)_"EXTRACRANIAL PROCEDURES,10006,ELIZA COFFEE MEMORIAL HOSPITAL,205 MARENGO STREET,FLORENCE,AL,35631,AL - Birmingham,24,37560.37,5434.95,4453.79"_$c(13,10)
	Set tNewLine = ##class(AnalyzeThis.Utils).DetermineNewLine(text)
	Set tExpected = $C(13,10)
	Do $$$AssertEquals(tNewLine,tExpected,tExpected_" = "_tNewLine)
}

Method TestCRbasic()
{
	Set text = "A,B,C,D,E,F"_$c(13)_"1,2,3,4,5,6"_$c(13)_"7,8,9,10,11,12"_$c(13)_"13,14,15,16,17,18"_$c(13)
	Set tNewLine = ##class(AnalyzeThis.Utils).DetermineNewLine(text)
	Set tExpected = $C(13)
	Do $$$AssertEquals(tNewLine,tExpected,tExpected_" = "_tNewLine)
}

Method TestCRLFbasic()
{
	Set text = "A,B,C,D,E,F"_$c(13,10)_"1,2,3,4,5,6"_$c(13,10)_"7,8,9,10,11,12"_$c(13,10)_"13,14,15,16,17,18"_$c(13,10)
	Set tNewLine = ##class(AnalyzeThis.Utils).DetermineNewLine(text)
	Set tExpected = $C(13,10)
	Do $$$AssertEquals(tNewLine,tExpected,tExpected_" = "_tNewLine)
}

Method TestCRLFadv()
{
	Set text = "A,B,C,D,E,F"_$c(13,10)_"1,""testing,"_$c(13,10)_"test"",3,4,5,6"_$c(13,10)_"7,8,""testing,"_$c(13,10)_"test"",10,""testing,"_$c(13,10)_"test"",12"_$c(13,10)_"""testing,"_$c(13,10)_"test"",14,15,16,""testing,"_$c(13,10)_"test"",18"_$c(13,10)
	Set tNewLine = ##class(AnalyzeThis.Utils).DetermineNewLine(text)
	Set tExpected = $C(13,10)
	Do $$$AssertEquals(tNewLine,tExpected,tExpected_" = "_tNewLine)
}

Method TestPunctuation()
{
	Set text = "this! has$ punctuation . (),""testing,"_$c(13,10)_"test"",""so, does, this! @!#$ (  )"",""testing,"_$c(13,10)_"test"""_$c(13,10)
	Set tNewLine = ##class(AnalyzeThis.Utils).DetermineNewLine(text)
	Set tExpected = $C(13,10)
	Do $$$AssertEquals(tNewLine,tExpected,tExpected_" = "_tNewLine)
}

Method TestLFbasic()
{
	set text="""term"",""justice"",""justiceName"",""post_mn"",""post_sd"",""post_med"",""post_025"",""post_975"""_$c(10)_"1965,97,""AFortas"",-1.402,0.275,-1.393,-1.97,-0.89"_$c(10)_"1966,97,""AFortas"",-1.564,0.234,-1.555,-2.04,-1.121"_$c(10)_"1967,97,""AFortas"",-1.479,0.245,-1.471,-1.987,-1.026"_$c(10)
	Set tNewLine = ##class(AnalyzeThis.Utils).DetermineNewLine(text)
	Set tExpected = $C(10)
	Do $$$AssertEquals(tNewLine,tExpected,tExpected_" = "_tNewLine)
	
}

}