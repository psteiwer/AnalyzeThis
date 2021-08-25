Class UnitTests.TestRegexProp Extends %UnitTest.TestCase
{

Method TestAlphaNumeric()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexProp("\r\n"))
	set text="A,2,C"_$c(13,10)
	set text=$replace(text,$c(13)_$c(10),"\r\n")
	set match.Text=text

	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out,0)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="A"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out,0)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="2"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out,0)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="C"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out,0)
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}

Method TestLineBreak()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexProp("\r\n"))
	set text="7,8,""testing,"_$c(13,10)_"test"",10,""testing,"_$c(13,10)_"test"",12"_$c(13,10)
	set text=$replace(text,$c(13)_$c(10),"\r\n")
	set match.Text=text
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out,0)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="7"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out,0)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="8"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out,0)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="""testing,\r\ntest"""
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out,0)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="10"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out,0)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="""testing,\r\ntest"""
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out,0)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="12"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out,0)
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}

Method TestPunctuation()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexProp("\r\n"))
	set text="this! has$ punctuation . (),""testing,"_$c(13,10)_"test"",""so, does, this! @!#$ (  )"",""testing,"_$c(13,10)_"test"""_$c(13,10)
	set text=$replace(text,$c(13)_$c(10),"\r\n")
	set match.Text=text
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out,0)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="this! has$ punctuation . ()"
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out,0)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="""testing,\r\ntest"""
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out,0)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="""so, does, this! @!#$ (  )"""
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out,0)
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set expected="""testing,\r\ntest"""
	do $$$AssertEquals(out,expected,expected_" = "_out)
	
	set st=##class(AnalyzeThis.Utils).GetNextRegex(.match,.out,0)
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}

}