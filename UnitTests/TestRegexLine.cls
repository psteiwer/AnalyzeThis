Class UnitTests.TestRegexLine Extends %UnitTest.TestCase
{

Method TestInpatients()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexLine("\r\n"))
	set text="DRG Definition,Provider Id,Provider Name,Provider Street Address,Provider City,Provider State,Provider Zip Code,Hospital Referral Region Description, Total Discharges , Average Covered Charges , Average Total Payments ,Average Medicare Payments"_$c(13,10)_"EXTRACRANIAL PROCEDURES,10001,SOUTHEAST ALABAMA MEDICAL CENTER,1108 ROSS CLARK CIRCLE,DOTHAN,AL,36301,AL - Dothan,91,32963.07,5777.24,4763.73"_$c(13,10)_"EXTRACRANIAL PROCEDURES,10005,MARSHALL MEDICAL CENTER SOUTH,2505 U S HIGHWAY 431 NORTH,BOAZ,AL,35957,AL - Birmingham,14,15131.85,5787.57,4976.71"_$c(13,10)_"EXTRACRANIAL PROCEDURES,10006,ELIZA COFFEE MEMORIAL HOSPITAL,205 MARENGO STREET,FLORENCE,AL,35631,AL - Birmingham,24,37560.37,5434.95,4453.79"_$c(13,10)
	set text=$replace(text,$c(13)_$c(10),"\r\n")
	set match.Text=text
	
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="DRG Definition,Provider Id,Provider Name,Provider Street Address,Provider City,Provider State,Provider Zip Code,Hospital Referral Region Description, Total Discharges , Average Covered Charges , Average Total Payments ,Average Medicare Payments\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="EXTRACRANIAL PROCEDURES,10001,SOUTHEAST ALABAMA MEDICAL CENTER,1108 ROSS CLARK CIRCLE,DOTHAN,AL,36301,AL - Dothan,91,32963.07,5777.24,4763.73\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="EXTRACRANIAL PROCEDURES,10005,MARSHALL MEDICAL CENTER SOUTH,2505 U S HIGHWAY 431 NORTH,BOAZ,AL,35957,AL - Birmingham,14,15131.85,5787.57,4976.71\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="EXTRACRANIAL PROCEDURES,10006,ELIZA COFFEE MEMORIAL HOSPITAL,205 MARENGO STREET,FLORENCE,AL,35631,AL - Birmingham,24,37560.37,5434.95,4453.79\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}

Method TestCRLFbasic()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexLine("\r\n"))
	set text="A,B,C,D,E,F"_$c(13,10)_"1,2,3,4,5,6"_$c(13,10)_"7,8,9,10,11,12"_$c(13,10)_"13,14,15,16,17,18"_$c(13,10)
	set text=$replace(text,$c(13)_$c(10),"\r\n")
	set match.Text=text
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="A,B,C,D,E,F\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="1,2,3,4,5,6\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="7,8,9,10,11,12\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="13,14,15,16,17,18\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}

Method TestCRLFadv()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexLine("\r\n"))
	set text="A,B,C,D,E,F"_$c(13,10)_"1,""testing,"_$c(13,10)_"test"",3,4,5,6"_$c(13,10)_"7,8,""testing,"_$c(13,10)_"test"",10,""testing,"_$c(13,10)_"test"",12"_$c(13,10)_"""testing,"_$c(13,10)_"test"",14,15,16,""testing,"_$c(13,10)_"test"",18"_$c(13,10)
	set text=$replace(text,$c(13)_$c(10),"\r\n")
	set match.Text=text
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="A,B,C,D,E,F\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="1,""testing,\r\ntest"",3,4,5,6\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="7,8,""testing,\r\ntest"",10,""testing,\r\ntest"",12\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="""testing,\r\ntest"",14,15,16,""testing,\r\ntest"",18\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}


Method TestCRbasic()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexLine("\r"))
	set text="A,B,C,D,E,F"_$c(13)_"1,2,3,4,5,6"_$c(13)_"7,8,9,10,11,12"_$c(13)_"13,14,15,16,17,18"_$c(13)
	set text=$replace(text,$c(13),"\r")
	set match.Text=text
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="A,B,C,D,E,F\r"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="1,2,3,4,5,6\r"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="7,8,9,10,11,12\r"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="13,14,15,16,17,18\r"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}

Method TestPunctuation()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexLine("\r\n"))
	set text="this! has$ punctuation . (),""testing,"_$c(13,10)_"test"",""so, does, this! @!#$ (  )"",""testing,"_$c(13,10)_"test"""_$c(13,10)
	set text=$replace(text,$c(13)_$c(10),"\r\n")
	set match.Text=text
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="this! has$ punctuation . (),""testing,\r\ntest"",""so, does, this! @!#$ (  )"",""testing,\r\ntest""\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=match.Locate()
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}

Method TestNoFinalLineFeed()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexLine("\r\n"))
	set text="A,B,C,D,E,F"_$c(13,10)_"1,2,3,4,5,6"_$c(13,10)_"7,8,9,10,11,12"_$c(13,10)_"13,14,15,16,17,18"
	set text=$replace(text,$c(13)_$c(10),"\r\n")
	set match.Text=text
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="A,B,C,D,E,F\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="1,2,3,4,5,6\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="7,8,9,10,11,12\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="13,14,15,16,17,18"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}

Method TestLFbasic()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexLine("\n"))
	set text="""term"",""justice"",""justiceName"",""post_mn"",""post_sd"",""post_med"",""post_025"",""post_975"""_$c(10)_"1965,97,""AFortas"",-1.402,0.275,-1.393,-1.97,-0.89"_$c(10)_"1966,97,""AFortas"",-1.564,0.234,-1.555,-2.04,-1.121"_$c(10)_"1967,97,""AFortas"",-1.479,0.245,-1.471,-1.987,-1.026"_$c(10)
	set text=$replace(text,$c(10),"\n")
	set match.Text=text
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="""term"",""justice"",""justiceName"",""post_mn"",""post_sd"",""post_med"",""post_025"",""post_975""\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="1965,97,""AFortas"",-1.402,0.275,-1.393,-1.97,-0.89\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="1966,97,""AFortas"",-1.564,0.234,-1.555,-2.04,-1.121\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="1967,97,""AFortas"",-1.479,0.245,-1.471,-1.987,-1.026\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}

Method TestQuoted()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexLine("\r\n"))
	set text="""A"",""B"",""C"",""D"",""E"",""F"""_$c(13,10)_"""1"",""2"",""3"",""4"",""5"",""6"""_$c(13,10)
	set text=$replace(text,$c(13)_$c(10),"\r\n")
	set match.Text=text
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="""A"",""B"",""C"",""D"",""E"",""F""\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="""1"",""2"",""3"",""4"",""5"",""6""\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}


Method TestNoEndQuote()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexLine("\r\n"))
	set text="""ID"",""Name"",""Sex"",""Age"",""Height"",""Weight"",""Team"",""NOC"",""Games"",""Year"",""Season"",""City"",""Sport"",""Event"",""Medal"""_$c(13,10)_"""1"",""A Dijiang"",""M"",24,180,80,""China"",""CHN"",""1992 Summer"",1992,""Summer"",""Barcelona"",""Basketball"",""Basketball Men's Basketball"",NA"_$c(13,10)_"""2"",""A Lamusi"",""M"",23,170,60,""China"",""CHN"",""2012 Summer"",2012,""Summer"",""London"",""Judo"",""Judo Men's Extra-Li"
	set text=$replace(text,$c(13)_$c(10),"\r\n")
	set match.Text=text
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="""ID"",""Name"",""Sex"",""Age"",""Height"",""Weight"",""Team"",""NOC"",""Games"",""Year"",""Season"",""City"",""Sport"",""Event"",""Medal""\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="""1"",""A Dijiang"",""M"",24,180,80,""China"",""CHN"",""1992 Summer"",1992,""Summer"",""Barcelona"",""Basketball"",""Basketball Men's Basketball"",NA\r\n"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out)
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}



}