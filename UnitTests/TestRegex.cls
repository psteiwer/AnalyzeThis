Class UnitTests.TestRegex Extends %UnitTest.TestCase
{

Method TestCRLFbasic()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexLine("\r\n"))
	set text="A,B,C,D,E,F"_$c(13,10)_"1,2,3,4,5,6"_$c(13,10)_"7,8,9,10,11,12"_$c(13,10)_"13,14,15,16,17,18"_$c(13,10)
	set match.Text=text
	
	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	do $$$AssertEquals(match.Start,1,"Line 1 Start = 1, was "_match.Start)
	do $$$AssertEquals(match.End,14,"Line 1 End = 14, was "_match.End)
	do $$$AssertEquals($e(text,match.Start,match.End-1),"A,B,C,D,E,F"_$c(13,10),$e(text,match.Start,match.End-1))
	
	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	do $$$AssertEquals(match.Start,14,"Line 2 Start = 14, was "_match.Start)
	do $$$AssertEquals(match.End,27,"Line 2 End = 27, was "_match.End)
	do $$$AssertEquals($e(text,match.Start,match.End-1),"1,2,3,4,5,6"_$c(13,10),$e(text,match.Start,match.End-1))
	
	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	do $$$AssertEquals(match.Start,27,"Line 3 Start = 27, was "_match.Start)
	do $$$AssertEquals(match.End,43,"Line 3 End = 43, was "_match.End)
	do $$$AssertEquals($e(text,match.Start,match.End-1),"7,8,9,10,11,12"_$c(13,10),$e(text,match.Start,match.End-1))
	
	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	do $$$AssertEquals(match.Start,43,"Line 4 Start = 43, was "_match.Start)
	do $$$AssertEquals(match.End,62,"Line 4 End = 62, was "_match.End)
	do $$$AssertEquals($e(text,match.Start,match.End-1),"13,14,15,16,17,18"_$c(13,10),$e(text,match.Start,match.End-1))
	
	set st=match.Locate()
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}

Method TestCRLFadv()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexLine("\r\n"))
	set text="A,B,C,D,E,F"_$c(13,10)_"1,""testing,"_$c(13,10)_"test"",3,4,5,6"_$c(13,10)_"7,8,""testing,"_$c(13,10)_"test"",10,""testing,"_$c(13,10)_"test"",12"_$c(13,10)_"""testing,"_$c(13,10)_"test"",14,15,16,""testing,"_$c(13,10)_"test"",18"_$c(13,10)
	set match.Text=text
	
	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	do $$$AssertEquals(match.Start,1,"Line 1 Start = 1, was "_match.Start)
	do $$$AssertEquals(match.End,14,"Line 1 End = 14, was "_match.End)
	do $$$AssertEquals($e(text,match.Start,match.End-1),"A,B,C,D,E,F"_$c(13,10),$e(text,match.Start,match.End-1))
	
	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	do $$$AssertEquals(match.Start,14,"Line 2 Start = 14, was "_match.Start)
	do $$$AssertEquals(match.End,43,"Line 2 End = 43, was "_match.End)
	do $$$AssertEquals($e(text,match.Start,match.End-1),"1,""testing,"_$c(13,10)_"test"",3,4,5,6"_$c(13,10),$e(text,match.Start,match.End-1))
	
	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	do $$$AssertEquals(match.Start,43,"Line 3 Start = 43, was "_match.Start)
	do $$$AssertEquals(match.End,88,"Line 3 End = 88, was "_match.End)
	do $$$AssertEquals($e(text,match.Start,match.End-1),"7,8,""testing,"_$c(13,10)_"test"",10,""testing,"_$c(13,10)_"test"",12"_$c(13,10),$e(text,match.Start,match.End-1))
	
	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	do $$$AssertEquals(match.Start,88,"Line 4 Start = 88, was "_match.Start)
	do $$$AssertEquals(match.End,135,"Line 4 End = 135, was "_match.End)
	do $$$AssertEquals($e(text,match.Start,match.End-1),"""testing,"_$c(13,10)_"test"",14,15,16,""testing,"_$c(13,10)_"test"",18"_$c(13,10),$e(text,match.Start,match.End-1))
	
	set st=match.Locate()
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}


Method TestCRbasic()
{
	set match=##class(%Regex.Matcher).%New(##class(AnalyzeThis.Utils).GetRegexLine("\r"))
	set text="A,B,C,D,E,F"_$c(13)_"1,2,3,4,5,6"_$c(13)_"7,8,9,10,11,12"_$c(13)_"13,14,15,16,17,18"_$c(13)
	set match.Text=text
	
	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	do $$$AssertEquals(match.Start,1,"Line 1 Start = 1, was "_match.Start)
	do $$$AssertEquals(match.End,13,"Line 1 End = 13, was "_match.End)
	do $$$AssertEquals($e(text,match.Start,match.End-1),"A,B,C,D,E,F"_$c(13),$e(text,match.Start,match.End-1))
	
	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	do $$$AssertEquals(match.Start,13,"Line 2 Start = 13, was "_match.Start)
	do $$$AssertEquals(match.End,25,"Line 2 End = 25, was "_match.End)
	do $$$AssertEquals($e(text,match.Start,match.End-1),"1,2,3,4,5,6"_$c(13),$e(text,match.Start,match.End-1))
	
	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	do $$$AssertEquals(match.Start,25,"Line 3 Start = 25, was "_match.Start)
	do $$$AssertEquals(match.End,40,"Line 3 End = 40, was "_match.End)
	do $$$AssertEquals($e(text,match.Start,match.End-1),"7,8,9,10,11,12"_$c(13),$e(text,match.Start,match.End-1))
	
	set st=match.Locate()
	do $$$AssertEquals(st,1,"Regex Matched = "_st)
	do $$$AssertEquals(match.Start,40,"Line 4 Start = 40, was "_match.Start)
	do $$$AssertEquals(match.End,58,"Line 4 End = 58, was "_match.End)
	do $$$AssertEquals($e(text,match.Start,match.End-1),"13,14,15,16,17,18"_$c(13),$e(text,match.Start,match.End-1))
	
	set st=match.Locate()
	do $$$AssertEquals(st,0,"EOF, Regex Matched = "_st)
}

}