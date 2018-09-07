Class UnitTests.TestRegexProp Extends %UnitTest.TestCase
{

Method TestAlphaNumeric()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexProp("\r\n"))
	set text="A,2,C"_$c(13,10)
	set match.Text=text

	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set val=$zstrip($zstrip($e(text,match.Start,match.End-1),">",","),">C")
	do $$$AssertEquals(match.Start,1,"Prop 1 Start = 1, was "_match.Start)
	do $$$AssertEquals(match.End,3,"Prop 1 End = 3, was "_match.End)
	do $$$AssertEquals(val,"A","A = "_val)

	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set val=$zstrip($zstrip($e(text,match.Start,match.End-1),">",","),">C")
	do $$$AssertEquals(match.Start,3,"Prop 2 Start = 3, was "_match.Start)
	do $$$AssertEquals(match.End,5,"Prop 2 End = 5, was "_match.End)
	do $$$AssertEquals(val,"2","2 = "_val)

	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set val=$zstrip($zstrip($e(text,match.Start,match.End-1),">",","),">C")
	do $$$AssertEquals(match.Start,5,"Prop 3 Start = 5, was "_match.Start)
	do $$$AssertEquals(match.End,8,"Prop 3 End = 8, was "_match.End)
	do $$$AssertEquals(val,"C","C = "_val)
	
	set st=match.Locate()
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}

Method TestLineBreak()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexProp("\r\n"))
	set text="7,8,""testing,"_$c(13,10)_"test"",10,""testing,"_$c(13,10)_"test"",12"_$c(13,10)
	set match.Text=text

	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set val=$zstrip($zstrip($e(text,match.Start,match.End-1),">",","),">C")
	do $$$AssertEquals(match.Start,1,"Prop 1 Start = 1, was "_match.Start)
	do $$$AssertEquals(match.End,3,"Prop 1 End = 3, was "_match.End)
	do $$$AssertEquals(val,"7","7 = "_val)

	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set val=$zstrip($zstrip($e(text,match.Start,match.End-1),">",","),">C")
	do $$$AssertEquals(match.Start,3,"Prop 2 Start = 3, was "_match.Start)
	do $$$AssertEquals(match.End,5,"Prop 2 End = 5, was "_match.End)
	do $$$AssertEquals(val,"8","8 = "_val)

	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set val=$zstrip($zstrip($e(text,match.Start,match.End-1),">",","),">C")
	do $$$AssertEquals(match.Start,5,"Prop 3 Start = 5, was "_match.Start)
	do $$$AssertEquals(match.End,22,"Prop 3 End = 22, was "_match.End)
	do $$$AssertEquals(val,"""testing,"_$c(13,10)_"test""","""testing,"_$c(13,10)_"test"" = "_val)

	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set val=$zstrip($zstrip($e(text,match.Start,match.End-1),">",","),">C")
	do $$$AssertEquals(match.Start,22,"Prop 4 Start = 22, was "_match.Start)
	do $$$AssertEquals(match.End,25,"Prop 4 End = 25, was "_match.End)
	do $$$AssertEquals(val,"10","10 = "_val)

	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set val=$zstrip($zstrip($e(text,match.Start,match.End-1),">",","),">C")
	do $$$AssertEquals(match.Start,25,"Prop 5 Start = 25, was "_match.Start)
	do $$$AssertEquals(match.End,42,"Prop 5 End = 42, was "_match.End)
	do $$$AssertEquals(val,"""testing,"_$c(13,10)_"test""","""testing,"_$c(13,10)_"test"" = "_val)

	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set val=$zstrip($zstrip($e(text,match.Start,match.End-1),">",","),">C")
	do $$$AssertEquals(match.Start,42,"Prop 6 Start = 42, was "_match.Start)
	do $$$AssertEquals(match.End,46,"Prop 6 End = 46, was "_match.End)
	do $$$AssertEquals(val,"12","12 = "_val)
	
	set st=match.Locate()
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}

Method TestPunctuation()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexProp("\r\n"))
	set text="this! has$ punctuation . (),""testing,"_$c(13,10)_"test"",""so, does, this! @!#$ (  )"",""testing,"_$c(13,10)_"test"""_$c(13,10)
	set match.Text=text

	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set val=$zstrip($zstrip($e(text,match.Start,match.End-1),">",","),">C")
	do $$$AssertEquals(match.Start,1,"Prop 1 Start = 1, was "_match.Start)
	do $$$AssertEquals(match.End,29,"Prop 1 End = 29, was "_match.End)
	do $$$AssertEquals(val,"this! has$ punctuation . ()","this! has$ punctuation . () = "_val)

	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set val=$zstrip($zstrip($e(text,match.Start,match.End-1),">",","),">C")
	do $$$AssertEquals(match.Start,29,"Prop 2 Start = 29, was "_match.Start)
	do $$$AssertEquals(match.End,46,"Prop 2 End = 46, was "_match.End)
	do $$$AssertEquals(val,"""testing,"_$c(13,10)_"test""","""testing,"_$c(13,10)_"test"" = "_val)

	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set val=$zstrip($zstrip($e(text,match.Start,match.End-1),">",","),">C")
	do $$$AssertEquals(match.Start,46,"Prop 3 Start = 46, was "_match.Start)
	do $$$AssertEquals(match.End,74,"Prop 3 End = 74, was "_match.End)
	do $$$AssertEquals(val,"""so, does, this! @!#$ (  )""","""so, does, this! @!#$ (  )"" = "_val)

	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	set val=$zstrip($zstrip($e(text,match.Start,match.End-1),">",","),">C")
	do $$$AssertEquals(match.Start,74,"Prop 4 Start = 74, was "_match.Start)
	do $$$AssertEquals(match.End,92,"Prop 4 End = 92, was "_match.End)
	do $$$AssertEquals(val,"""testing,"_$c(13,10)_"test""","""testing,"_$c(13,10)_"test"" = "_val)
	
	set st=match.Locate()
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}

}