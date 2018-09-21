Class UnitTests.TestReadStream Extends %UnitTest.TestCase
{

Method TestQuoted()
{
	Set original = $replace($justify(" ",31995)," ","a")_"""this is a quoted string"""
	set stream = ##class(%Stream.FileBinary).%New()
	d stream.Write(original)
	
	set wrong = stream.Read()
	Do $$$AssertNotEquals(wrong,original,"Ending 30 chars: "_$e(original,*-30,*)_" '= "_$e(wrong,*-30,*))
	
	Do stream.Rewind()
	set final = ##class(AnalyzeThis.Utils).ReadStream(.stream)
	Do $$$AssertEquals(final,original,"Ending 30 chars: "_$e(original,*-30,*)_" = "_$e(final,*-30,*))
}

}