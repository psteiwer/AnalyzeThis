Class AnalyzeThis.Dashboard.AutoPivot
{

Query FindLevels(pcubeName) As %SQLQuery [ SqlProc ]
{
 SELECT LevelName
 FROM AnalyzeThis_Dashboard.MetaData 
 WHERE CubeName=:pcubeName
}

ClassMethod GenerateSampleDashboards(pcubeName As %String, pVerbose As %Boolean = 0) As %Status
{
	do ##class(%DeepSee.Utils).%CubeExists(pcubeName, .st)
	if (st=0) {
		w:pVerbose "No Cube Found"
		QUIT $$$ERROR("No Cube Found")
	}
	Do ##class(AnalyzeThis.Dashboard.MetaDataAnalyze).EvaluateCube(pcubeName)
	Set MetaDataExist=0
	&sql(
		select count(*) into :MetaDataExist FROM AnalyzeThis_Dashboard.MetaData where (CubeName=:pcubeName)
	)
	if (SQLCODE) QUIT
	if ('MetaDataExist) {
		w:pVerbose "No Meta Data Found"
		QUIT $$$ERROR("No Meta Data Found")
	}
	
	Set levels=##class(%ResultSet).%New("AnalyzeThis.Dashboard.AutoPivot:FindLevels")
	Set st=levels.Execute(pcubeName)
	if ('st) {
		w:pVerbose "No Levels Found"
		Quit st
	}
	
	kill dash
	Set ChartCount=0
	set dashName="Samples for "_pcubeName
	set dexist=##class(%DeepSee.Dashboard.Utils).%DashboardExists("Generated/"_dashName_".dashboard")
	if (dexist) {
		set dash=##class(%DeepSee.Dashboard.Utils).%OpenDashboard("Generated/"_dashName_".dashboard", .st)
		Set ChartCount=dash.widgets.Count()
	}
	if (ChartCount>3) GOTO Filter
	
	for i=1:1:17 {
		Set scores(i)=0
		Set names(i)=""
	}
	
	while (levels.Next()'=0) {
		Set Levelname=levels.LevelName
		If (Levelname'["%ID") {
			w:pVerbose "Scoring "_Levelname, !
			Set card=0, lt="",n=0,sd=0,m=0,wr=0,dt=""
			&sql(
				SELECT Cardinality, LevelType, "Null", STDDEV, Mean, WordRecognition, DataType, DimName
	 			into :card, :lt, :n, :sd, :m, :wr, :dt, :DimName FROM AnalyzeThis_Dashboard.MetaData
	 			where (CubeName=:pcubeName AND LevelName=:Levelname)
	 		)
			QUIT:(SQLCODE)
			
			Set card=$ZABS(card)
			Set m=$ZABS(m)
			Set sd=$ZABS(sd)
			
			if (pVerbose) {
				w "Meta Data For "_Levelname_":", !
				w "Cardinality="_card, !
				w "LevelType="_lt, !
				w "PercentNull="_n, !
				w "StandardDev="_sd, !
				w "Mean="_m, !
				w "WordRecognition="_wr, !
				w "DataType="_dt, !
			}
			
			set nullFactor = $select(
				n<10:1.8,
				(10<=n)&(n<20):1.6,
				(20<=n)&(n<40):1.4,
				(n>60):.8,
				1:.3
			)
			
			//Bubble Chart
			if ((sd>(m/3))&&(dt'="Date")&&(lt="Measure")&&(Levelname'="%COUNT")) {
				set tScore=1
				Set:(m>0) tScore=(sd/m)+tScore
				Set:(m=0) tScore=(sd/1000)+tScore
				set tScore=tScore+(wr*2)
				Set tScore=tScore*nullFactor
				if (tScore>scores(3)) {
					Set scores(3)=tScore
					Set names(3)=Levelname_"*col*"_lt_"*"_DimName
				}	
			}
			if ((Levelname'=$piece(names(3),"*",1))&&(5<card)&&(card<100)&&(dt'="Date")&&(lt="Measure")&&(Levelname'="%COUNT")) {
				set tScore=1
				set:(15<card)&&(card<25) tScore=tScore+5
				set tScore=tScore+(wr*2)
				Set tScore=tScore*nullFactor
				if (tScore>scores(1)) {
					Set scores(2)=scores(1)
					Set scores(1)=tScore
					Set names(2)=names(1)
					Set names(1)=Levelname_"*col*"_lt_"*"_DimName
				}		
			}
			//Bar Chart
			if ((lt="Dimension")&&(dt'="Date")) {
				set tScore=1
				set tScore=tScore+(wr*2)
				set:(card<15) tScore=tScore+(card*4)
				Set tScore=tScore*nullFactor
				if (tScore>scores(4)) {
					Set scores(4)=tScore
					Set names(4)=Levelname_"*row*"_lt_"*"_DimName
				}	
			}
			if ((lt="Measure")&&(dt'="Date")) {
				set tScore=1
				if (m>0) set tScore=(sd/m)+tScore
				if (m=0) set tScore=(sd/1000)+tScore
				set tScore=tScore+(wr*4)
				Set tScore=tScore*nullFactor
				if (tScore>scores(5)) {
					Set scores(5)=tScore
					Set names(5)=Levelname_"*col*"_lt_"*"_DimName
				}		
			 }
				
			//ScatterPlot
			if ((lt="Measure")&&(Levelname'="%COUNT")) {
				set tScore=1
				set tScore=tScore+wr*10
				Set tScore=tScore+card
				Set tScore=tScore*nullFactor
				if (tScore>scores(6)) {
					Set scores(7)=scores(6)
					Set scores(6)=tScore
					Set names(7)=names(6)
					Set names(6)=Levelname_"*col*"_lt_"*"_DimName
				}	
			}
			if ((dt'="Year")&&(dt'="Date")&&(lt="Dimension")) {
				Set tScore=(wr+1)*card
				Set tScore=tScore*nullFactor
				if (tScore>scores(8)) {
					Set scores(8)=tScore
					Set names(8)=Levelname_"*row*"_lt_"*"_DimName
				}	
			}
				
			//Pie
			if ((lt="Dimension")&&(card>0)&&(card<40)&&(dt'="Date")) {
				set tScore=1
				if (card<6) set tScore=tScore+((card+5)*2)
				if (card<10) set tScore=tScore+(card)
				if (card<20) set tScore=tScore+(card/2)
				set tScore=tScore+wr*2
				Set tScore=tScore*nullFactor
				if (tScore>scores(9)) {
					Set scores(9)=tScore
					Set names(9)=Levelname_"*row*"_lt_"*"_DimName
				}	
			}
				
			//Pivot
			if ((lt="Dimension")&&(card<20)&&(card>0)&&(dt'="Date")) {
				Set tScore=1
				Set tScore=tScore+(4/card)
				Set tScore=tScore+(wr*3)
				Set tScore=tScore*nullFactor
				if (tScore>scores(11)) {
					if (scores(11)'=0)&&(scores(10)=0) {
						Set scores(10)=scores(11)
						Set names(10)=$replace(names(11),"*row*","*col")
					}
					Set scores(11)=tScore
					Set names(11)=Levelname_"*row*"_lt_"*"_DimName
				} elseif (tScore>scores(10)) {
					Set scores(10)=tScore
					Set names(10)=Levelname_"*col*"_lt_"*"_DimName
				}
			} elseif (lt="Measure") {
				if (scores(10)<card) {
					Set scores(10)=card
					Set names(10)=Levelname_"*col*"_lt_"*"_DimName
				}
			}
		
			//Time Chart
			if ((dt="Date")&&(card>5)) {
				Set tScore=card
				Set tScore=tScore*nullFactor
				if (tScore>scores(12)) {
					Set scores(12)=tScore
					Set names(12)=Levelname_"*col*"_lt_"*"_DimName
				}	
			}
					
			//Filters
			If ((lt="Dimension")&&(dt'="Date")) {
				Set tScore=1
				If (dt="State") Set tScore=1000000
				Set tScore=tScore+(1000/(card+1))
				Set tScore=tScore+(100/(n+1))
				if (tScore>scores(13)) {
					Set scores(13)=tScore
					Set names(13)=DimName_"*"_Levelname
				}	
			}
			
			//Plot Boxes
			if ((lt="Dimension")&&(dt'="Date")&&(dt'="Gender")) {
				set tScore=1
				if (card<15) set tScore=tScore+50
				if (tScore>scores(14)) {
					Set scores(14)=tScore
					Set names(14)=Levelname_"*row*"_lt_"*"_DimName
				}	
			}
			if ((lt="Measure")&&(dt'="Date")) {
				set tScore=1
				if (m>0) set tScore=(sd/m)+tScore
				if (m=0) set tScore=(sd/1000)+tScore
				set tScore=tScore*((wr+1)*10)	
				if (tScore>scores(15)) {
					Set scores(17)=scores(15)
					Set names(17)=names(15)
					Set scores(15)=tScore
					Set names(15)=Levelname_"*col*"_lt_"*"_DimName
				} elseif (tScore>scores(17)) {
					Set scores(17)=tScore
					Set names(17)=Levelname_"*col*"_lt_"*"_DimName
				}
			}
			
			//meter
			if (lt="Measure")&&(card>scores(16))&&(Levelname'="%COUNT") {
				set scores(16)=card
				Set names(16)=Levelname_"*row*"_lt
			}
		}
	}
	
	if ((scores(1)>0)&&(scores(2)>0)&&(scores(3)>0)) {
		Set wtype="bubbleChart"			
		Set pname= ##class(AnalyzeThis.Dashboard.AutoPivot).CreatePivotSample(pcubeName, names(1), names(2), names(3), names(8))
		w:pVerbose "Pivot Name="_pname, !
		if (pname'="") {
			Set st=##class(AnalyzeThis.Dashboard.AutoPivot).AddWidget(pcubeName,pname,wtype, ChartCount)
			if (st) {
				Set ChartCount=ChartCount+1
			}
		}
	}
	
	if (ChartCount>3) GOTO Filter
	
	if (scores(4)*scores(5)>0) {
		Set wtype="barChart"
		Set pname=##class(AnalyzeThis.Dashboard.AutoPivot).CreatePivotSample(pcubeName,names(4), names(5))
		w:pVerbose "Pivot Name="_pname, !
		if (pname'="") {
			Set st=##class(AnalyzeThis.Dashboard.AutoPivot).AddWidget(pcubeName,pname,wtype, ChartCount)
			if (st) {
				Set ChartCount=ChartCount+1
			}
		}
	}
	
	if (ChartCount>3) GOTO Filter
	
	if (scores(9)>0) {
		Set pc="%COUNT*col*Measure"
		Set wtype="pieChart"
		Set pname=##class(AnalyzeThis.Dashboard.AutoPivot).CreatePivotSample(pcubeName, names(9), pc)
		w:pVerbose "Pivot Name="_pname, !
		if (pname'="") {
			Set st=##class(AnalyzeThis.Dashboard.AutoPivot).AddWidget(pcubeName,pname,wtype,ChartCount)
			if (st) {
				Set ChartCount=ChartCount+1
			}
		}
	}
			
	if (ChartCount>3) GOTO Filter
	
	if ((scores(12)>0)&&(scores(6)>0)&&(scores(4)>0)) {
		Set spec=""
		Set dt=""
		Set ln=$piece(names(6),"*",1)
		set lt=$piece(names(6),"*",3)
		Set dt=$piece(names(6),"*",4)
			
		Set dt2=""
		Set ln2=$piece(names(4),"*",1)
		set lt2=$piece(names(4),"*",3)
		Set dt2=$piece(names(4),"*",4)
		
		Set tMDX="Select ["_dt2_"].[H1].["_ln2_"].Members on 0 from ["_pcubeName_"]"
		Set tRS = ##class(%DeepSee.ResultSet).%New()
		Set tSC = tRS.%PrepareMDX(tMDX)
		If $$$ISERR(tSC) Quit
		Set tSC = tRS.%Execute()
		If $$$ISERR(tSC) Quit
		kill ^||DeepSee.AxisMembers
		Do tRS.%GetAxisMembers(1,.pKey)
		if ($data(^||DeepSee.AxisMembers(pKey,1,1,0))) {
			Set tlbl=$LG(^||DeepSee.AxisMembers(pKey,1,1,0),2)
			if ($data(^||DeepSee.AxisMembers(pKey,1,2,0))) {
				Set tlbl2=$LG(^||DeepSee.AxisMembers(pKey,1,2,0),2)
			}
		}
		kill ^||DeepSee.AxisMembers

		set spec="Select NONEMPTYCROSSJOIN([Measures].["_ln_"]"
		if ((lt="Measure")&&($$$UPPER(ln)'="%COUNT")) {
			set spec=spec_".AVG"
		}
		Set spec=spec_", {["_dt2_"].[H1].["_ln2_"].&["_tlbl_"], "
		Set spec=spec_"["_dt2_"].[H1].["_ln2_"].&["_tlbl2_"]}) on 1, "
		
		Set dt=""
		Set ln=$piece(names(12),"*",1)
		set lt=$piece(names(12),"*",3)
		Set dt=$piece(names(12),"*",4)

		//set up specs
		if (lt="Dimension") {
			set spec= spec_"["_dt_"].[H1].["_ln_"].Members on 0 from "_pcubeName
		}						
		Set pname=spec
		Set wtype="time"
		w:pVerbose "mdx="_pname, !
		if (pname'="") {
			Set st=##class(AnalyzeThis.Dashboard.AutoPivot).AddWidget(pcubeName,pname,wtype,ChartCount)
			if (st) {
				Set ChartCount=ChartCount+1
			}
		}
	}
	
	if (ChartCount>3) GOTO Filter
	
	//
	//Build a Meter
	//
	If ((scores(9)>0)&&(scores(16)>0)) {
		set metercat=$piece(names(9),"*",1)_"*col*"_$piece(names(9),"*",3,4)
		
		Set wtype="speedometer"
		Set pname=##class(AnalyzeThis.Dashboard.AutoPivot).CreatePivotSample(pcubeName, metercat, names(16))
		w:pVerbose "Pivot Name="_pname, !
		if (pname'="") {
			Set st=##class(AnalyzeThis.Dashboard.AutoPivot).AddWidget(pcubeName, pname,wtype,ChartCount)
			If (st) Set ChartCount=ChartCount+1
		}
	}
	
 	if (ChartCount>3) GOTO Filter
 
	//scatter plot
	if (scores(6)*scores(7)*scores(8)>0) {
		Set wtype="bubbleChart"
		Set pname=##class(AnalyzeThis.Dashboard.AutoPivot).CreatePivotSample(pcubeName,names(6), names(7), names(8))
		w:pVerbose "Pivot Name="_pname, !
		if (pname'="") {
			Set st=##class(AnalyzeThis.Dashboard.AutoPivot).AddWidget(pcubeName,pname,wtype, ChartCount)
			if (st) {
				Set ChartCount=ChartCount+1
			}
			
			if (ChartCount>3) GOTO Filter
			
			Set wtype="line"
			Set st=##class(AnalyzeThis.Dashboard.AutoPivot).AddWidget(pcubeName,pname,wtype, ChartCount)
			if (st) {
				Set ChartCount=ChartCount+1
			}
		}
	}
	
	if (ChartCount>3) GOTO Filter
	
	//
	//Pivot
	//
	if (scores(10)>0) || (scores(11)>0) {
		Set wtype="pivot"
		if '(scores(10)>0) {
			Set pname=##class(AnalyzeThis.Dashboard.AutoPivot).CreatePivotSample(pcubeName, names(11))
		} elseif '(scores(11)>0) {
			Set pname=##class(AnalyzeThis.Dashboard.AutoPivot).CreatePivotSample(pcubeName, names(10))
		} else {
			Set pname=##class(AnalyzeThis.Dashboard.AutoPivot).CreatePivotSample(pcubeName, names(10), names(11))
		}
		w:pVerbose "Pivot Name="_pname, !
		if (pname'="") {
			Set st=##class(AnalyzeThis.Dashboard.AutoPivot).AddWidget(pcubeName, pname, wtype,ChartCount)
			if (st) {
				Set ChartCount=ChartCount+1
			}
		}
	}
	
	// If we have 1 or 3 widgets, add a listing widget to fill in the blank space
	if ((ChartCount=1) || (ChartCount=3)) {
		set pname=##class(AnalyzeThis.Dashboard.AutoPivot).CreateListingSample(pcubeName)
		set wtype="pivot"
		Set st=##class(AnalyzeThis.Dashboard.AutoPivot).AddWidget(pcubeName, pname, wtype,ChartCount)
		if (st) {
			Set ChartCount=ChartCount+1
		}
	}
	
	GOTO Filter

Filter
	w:pVerbose "Adding a filter", !

	if (scores(13)>0) {
		w:pVerbose "Adding a "_names(13)_" filter"
		Do ##class(AnalyzeThis.Dashboard.AutoPivot).addFilter(names(13),pcubeName)
	}
	
	//scorecard
	If ((scores(15)>0)&&(scores(14)>0)) {
		If (scores(17)>0) {
			Set pname=##class(AnalyzeThis.Dashboard.AutoPivot).CreatePivotSample(pcubeName,names(14), names(15),names(17))
			Set st=##class(AnalyzeThis.Dashboard.AutoPivot).SampleScoreCard(pcubeName,pname,$piece(names(15),"*",1), $piece(names(17),"*",1),pVerbose)
		}
		If (scores(17)=0) {
			Set pname=##class(AnalyzeThis.Dashboard.AutoPivot).CreatePivotSample(pcubeName,names(14), names(15))
			Set st=##class(AnalyzeThis.Dashboard.AutoPivot).SampleScoreCard(pcubeName,pname,$piece(names(15),"*",1),,pVerbose)
		}
	}

	if ((st)&&(ChartCount=0)) {
		QUIT $$$ERROR("No Dashboards created")
	}
	
	quit st
}

ClassMethod CreateListingSample(pCubeName As %String) As %String
{
	Set name="Listing for "_pCubeName
	
	set exists=##class(%DeepSee.UserLibrary.Utils).%FolderItemExists("Generated-"_$E(pCubeName,1,15)_"/"_name_".pivot")
	if (exists) {
		quit name
	}

	//Create new pivot
  	set tPivot=##class(%DeepSee.Dashboard.Pivot).%New()
	set tPivot.cubeName=pCubeName
	set tPivot.name=name
	set tPivot.folderName="Generated-"_$E(pCubeName,1,15)
	set tPivot.caption=##class(AnalyzeThis.Dashboard.AutoPivot).ReformatName(name)
	
	set tPivot.mdx="DRILLTHROUGH SELECT FROM ["_pCubeName_"]"
	
	set st=tPivot.%Save()	
	if (st) {
		quit name
	} elseif ('st) {
		quit ""
	}
}

/// Helper Method for GenerateSampleDashboards
ClassMethod CreatePivotSample(pcubeName As %String, pl...) As %String
{
	Set name=$piece(pl(1),"*",1,2)
	if (pl>1) {
		For i=2:1:pl {
			set name=name_"-"_$piece(pl(i),"*",1,2)
		}
	}
	Set name=name_" on "_pcubeName
	
	set exists=##class(%DeepSee.UserLibrary.Utils).%FolderItemExists("Generated-"_$E(pcubeName,1,15)_"/"_name_".pivot")
	if (exists) {
		quit name
	}

	//Create new pivot
  	set tPivot=##class(%DeepSee.Dashboard.Pivot).%New()
	set tPivot.cubeName=pcubeName
	set tPivot.name=name
	set tPivot.folderName="Generated-"_$E(pcubeName,1,15)
	set tPivot.caption=##class(AnalyzeThis.Dashboard.AutoPivot).ReformatName(name)
	
	For i=1:1:pl {
		Set axis=$piece(pl(i),"*",2)
		Set ln=$piece(pl(i),"*",1)
		set lt=$piece(pl(i),"*",3)
		Set dn=$piece(pl(i),"*",4)
	
		//set up specs
		if (lt="Dimension") {
			set spec= "["_dn_"].[H1].["_ln_"].Members"
		} elseif ((lt="Measure")&&($$$UPPER(ln)'="%COUNT")) {
			set spec="[Measures].["_ln_"].AVG"
		} elseif ((lt="Measure")&&($$$UPPER(ln)="%COUNT")) {
			set spec="[Measures].["_ln_"]"
		} else {
			quit
		}

		//create levels
		set lvl=##class(%DeepSee.Dashboard.PivotLevel).%New()
		set lvl.spec=spec
		set lvl.text=ln
		set lvl.enabled=1
	
		//Swizzle
		if (axis="col") do tPivot.columnLevels.Insert(lvl)
		if (axis="row") do tPivot.rowLevels.Insert(lvl)
	}
		
	set st=tPivot.%Save()	
	if (st) {
		quit name
	} elseif ('st) {
		quit ""
	}
}

/// Helper method for GenerateSampleDashboards
ClassMethod AddWidget(pCubeName As %String, pname As %String, wtype As %String, pPos) As %Status
{
	//check if dashboard exists
	kill dash
	set dashName="Samples for "_pCubeName
	set dexist=##class(%DeepSee.Dashboard.Utils).%DashboardExists("Generated/"_dashName_".dashboard")
	if (dexist) {
		set dash=##class(%DeepSee.Dashboard.Utils).%OpenDashboard("Generated/"_dashName_".dashboard", .st)	
		Set wexisting="" 
		Set key=0
		While (dash.widgets.GetNext(.key)) {
			set we=dash.widgets.GetAt(key)
			set wexisting=wexisting_we.name
		}
	} elseif ('dexist) {
		set dash=##class(%DeepSee.Dashboard.Definition).%New()
		set dash.name=dashName
		do dash.folderNameSet("Generated")
		set dash.title=dashName
	}
	
	set dash.snapGrid=1
	set dash.snapTo=1
	Set dash.worklistCount=1
	Set dash.gridCols=$case(pPos,1:5,2:5,3:10,4:10,:10)
	
	//Create widget
	set skip=1
	if (dexist) {
		set wn=pname_"-"_wtype
		if (wexisting'[wn) {
			set skip=1
		}
		elseif (wexisting[wn) {
			set skip=0
		}
	}
			
	if (skip) {
		set wcreated=0
		kill widget, prop
		set widget= ##class(%DeepSee.Dashboard.Widget).%New()
			
		if (wtype'="time") {
			set widget.dataSource="Generated-"_$E(pCubeName,1,15)_"/"_pname_".pivot"
			set widget.name=pname_"-"_wtype
		}
		if (wtype="time") Set widget.name="time"
		if ((wtype'["meter")&&(wtype'="time")&&(wtype'="line")) {
			set widget.type="pivot"
			set widget.subtype=wtype
			Set widget.subtypeClass=wtype
			if (wtype["timeChart") {
				Set widget.subtypeClass="lineChart"
			}
		} elseif (wtype["meter") {
			Set LevelName=$PIECE(pname,"*",1)
			Set card=0, lt="",n=0,sd=0,m=0,wr=0,dt=""
			&sql(
				SELECT DimName into :DimName FROM AnalyzeThis_Dashboard.MetaData where (CubeName=:pCubeName AND LevelName=:LevelName)
			)
			QUIT:(SQLCODE)
			set widget.type="meter"
			set widget.subtype=wtype
			Set prop=##class(%DeepSee.Dashboard.DataProperty).%New()
			Set prop.subtype=wtype
				
			Set tMDX="Select ["_DimName_"].[H1].["_LevelName_"].Members on 0 from ["_pCubeName_"]"
			Set tRS = ##class(%DeepSee.ResultSet).%New()
			Set tSC = tRS.%PrepareMDX(tMDX)
			If $$$ISERR(tSC) Quit
			Set tSC = tRS.%Execute()
			If $$$ISERR(tSC) Quit
			kill ^||DeepSee.AxisMembers
			Do tRS.%GetAxisMembers(1,.pKey)
			Set tlbl=$LG(^||DeepSee.AxisMembers(pKey,1,1,0),2)
			if ($data(tlbl)) {
				Set prop.dataValue="=["_tlbl_"]"
				Set prop.label=tlbl
				&sql(
					SELECT Maximum, STDDEV, Mean into :max, :std, :avg FROM AnalyzeThis_Dashboard.MetaData where (CubeName=:pCubeName AND LevelName=:LevelName)
				)
				if ('SQLCODE) {
					Set prop.rangeUpper=max
					set prop.thresholdLower=avg-(std/2)
					set prop.thresholdUpper=avg+(std/2)
				}
				do widget.dataProperties.Insert(prop)
			}
				
			if ($data(^||DeepSee.AxisMembers(pKey,1,2,0))) {
				Set prop2=##class(%DeepSee.Dashboard.DataProperty).%New()
				Set tlbl2=$LG(^||DeepSee.AxisMembers(pKey,1,2,0),2)
				if ($data(tlbl2)) {
					Set prop2.dataValue="=["_tlbl2_"]"
					Set prop2.label=tlbl2
					Set prop2.rangeUpper=max
					set prop2.thresholdLower=avg-(std/2)
					set prop2.thresholdUpper=avg+(std/2)
					do widget.dataProperties.Insert(prop2)
				}
			}
			kill ^||DeepSee.AxisMembers
					
		} elseif (wtype="time") {
			set widget.type="portlet"
			set widget.subtype="AnalyzeThis.ThirdParty.NVD3timeChart"
			Set widget.subtypeClass="portlet"
			Set mdx=pname
		} elseif (wtype="line") {
			set widget.type="portlet"
			set widget.subtype="AnalyzeThis.ThirdParty.AmSmoothedLineChart"
			Set widget.subtypeClass="portlet"	
				
			//set widget.type="pivot"
			//set widget.subtype="lineChart"
			//Set widget.subtypeClass="lineChart"		
		}
			
		set widget.title=##class(AnalyzeThis.Dashboard.AutoPivot).ReformatName(pname)
		if (wtype="portlet") set widget.title=wtype
		set widget.maximized=0
		Set widget.rowSpanL=5
		Set widget.colSpanL=5
		Set widget.homeRowL=$CASE(pPos,0:0,1:5,2:0,3:5)
		Set widget.homeColL=$CASE(pPos,0:0,1:0,2:5,3:5)
		Kill Properties
		Set Properties=##class(%ArrayOfDataTypes).%New()
		Do Properties.SetAt(1,"analyzer")
		Do Properties.SetAt("chart","chartToggle")
		Do Properties.SetAt(1,"print")
		if (wtype="time") Do Properties.SetAt(mdx,"MDX")
		if (wtype="barChart") {
			Do Properties.SetAt("none","legendPos")
			Set Overrides=##class(%ArrayOfDataTypes).%New()
			Do Overrides.SetAt("{legendVisible:'false',seriesColorScheme:'urban',xAxis:{_type:'axis'},yAxisList:[{_type:'axis'}],chartPivot:true,_type:'"_wtype_"'}",wtype)
			Do Overrides.SetAt("{hidden:true,_type:'chartLegend'}", "legend")
			Set widget.overrides=Overrides
		} elseif (wtype="pivot") {
		} else {
			Set Overrides=##class(%ArrayOfDataTypes).%New()
			Do Overrides.SetAt("{legendVisible:'false',seriesColorScheme:'urban',xAxis:{_type:'axis'},yAxisList:[{_type:'axis'}],_type:'"_wtype_"'}",wtype)
			Set widget.overrides=Overrides
		}
			
		Set widget.properties=Properties
		do dash.widgets.Insert(widget)
		set st=dash.%Save()
			
	}
	elseif ('skip) {
		QUIT '$$$OK
	}
	set st=dash.%Save()
	quit st
}

/// Helper method for GenerateSampleDashboards
ClassMethod addFilter(filter, pCubeName As %String)
{
	Set dimName=$PIECE(filter,"*",1)
	Set levelName=$PIECE(filter,"*",2)
	Set spec="["_dimName_"].[H1].["_levelName_"]"
	kill dash
	set dashName="Samples for "_pCubeName
	set dexist=##class(%DeepSee.Dashboard.Utils).%DashboardExists("Generated/"_dashName_".dashboard")
	if (dexist) {
		Set control=##class(%DeepSee.Dashboard.Control).%New()
		Set control.name=levelName
		Set control.target="*"
		Set control.location="dashboard"
		Set control.action="applyFilter"
		Set control.targetProperty=spec
		Set control.type="auto"
		Set control.label=levelName
		Set dash=##class(%DeepSee.Dashboard.Utils).%OpenDashboard("Generated/"_dashName_".dashboard", .st)	
		Set key=1
		Set widget=dash.widgets.GetAt(key)
		Set cExist=""
		Set cExist=widget.controls.GetAt(key)
		if (cExist'="") quit $$$OK
		Do widget.controls.Insert(control)
		Do dash.%Save()	
	}
	kill dash
	set dashName="Sample ScoreCard for "_pCubeName
	set dexist=##class(%DeepSee.Dashboard.Utils).%DashboardExists("Generated/"_dashName_".dashboard")
	if (dexist) {
		Set control=##class(%DeepSee.Dashboard.Control).%New()
		Set control.name=levelName
		Set control.target="*"
		Set control.location="dashboard"
		Set control.action="applyFilter"
		Set control.targetProperty=spec
		Set control.type="auto"
		Set control.label=levelName
		Set dash=##class(%DeepSee.Dashboard.Utils).%OpenDashboard("Generated/"_dashName_".dashboard", .st)	
		Set key=1
		Set widget=dash.widgets.GetAt(key)
		Set cExist=""
		Set cExist=widget.controls.GetAt(key)
		if (cExist'="") quit $$$OK
		Do widget.controls.Insert(control)
		Do dash.%Save()	
	}
}

/// Reformat the names of pivot tables used by CreatePivotSample for titles
ClassMethod ReformatName(pname As %String) As %String
{
	Set tname(1)=$piece(pname,"*",1)
	Set tList=$LISTFROMSTRING(pname,"*")
	Set length=$LISTLENGTH(tList)
	Set i=2
	For x=2:1:length-1 {
		Set tname(i)=$piece($LG(tList, x),"-",2)
		Set i=i+1
	}
	Set i=2
	Set newName=tname(1)
	while $data(tname(i)) {
		Set newName=newName_" vs "_tname(i)
		set i=i+1
	}
	return newName
}

ClassMethod SampleScoreCard(pcubeName As %String, pPivotName As %String, pLevel1 As %String = "", pLevel2 As %String = "", pVerbose As %Boolean = 0) As %Status
{
	//check if dashboard exists
	kill dash
	set dashName="Sample ScoreCard for "_pcubeName
	set dexist=##class(%DeepSee.Dashboard.Utils).%DashboardExists("Generated/"_dashName_".dashboard")
	if (dexist) QUIT $$$OK
	
	set dash=##class(%DeepSee.Dashboard.Definition).%New()
	set dash.name=dashName
	do dash.folderNameSet("Generated")
	set dash.title=dashName
	set dash.snapGrid=1
	set dash.snapTo=1
	Set dash.worklistCount=1
	
	//Create widget 1
	Set LevelName=pLevel1
	&sql(
		SELECT Maximum, Minimum, STDDEV, Mean into :max, :min, :std, :avg FROM AnalyzeThis_Dashboard.MetaData where (CubeName=:pcubeName AND LevelName=:LevelName)
	)
	w:pVerbose SQLCODE
	QUIT:(SQLCODE)
	set wcreated=0
	kill widget
	set widget= ##class(%DeepSee.Dashboard.Widget).%New()
	
	set widget.dataSource="Generated-"_$E(pcubeName,1,15)_"/"_pPivotName_".pivot"
	set widget.name="ScoreCard1"
	set widget.type="scoreCardWidget"
	set widget.subtype="regular"
	set widget.maximized=0
	Set widget.rowSpanL=5
	Set widget.colSpanL=10
	Set widget.homeRowL=0
	Set widget.homeColL=0
	
	kill prop1, prop2, prop3, prop4, prop5
	Set prop1=##class(%DeepSee.Dashboard.DataProperty).%New()
	Set prop1.display="itemNo"
	Do widget.dataProperties.Insert(prop1)
	
	Set prop2=##class(%DeepSee.Dashboard.DataProperty).%New()
	Set prop2.display="label"
	Set prop2.width=240
	Do widget.dataProperties.Insert(prop2)
	
	Set tlbl=$piece($piece(pPivotName,"*",2),"-",2)
	Set prop3=##class(%DeepSee.Dashboard.DataProperty).%New()
	Set prop3.display="value"
	if (tlbl="%COUNT") Set tlbl="Count"
	Set prop3.dataValue="=["_tlbl_"]"
	Set prop3.label=tlbl
	Set prop3.align="center"
	Set prop3.override="{headerAlign:'center'}"
	Do widget.dataProperties.Insert(prop3)
	
	Set prop4=##class(%DeepSee.Dashboard.DataProperty).%New()
	Set prop4.display="plotBox"
	if (tlbl="%COUNT") Set tlbl="Count"
	Set prop4.dataValue="=["_tlbl_"]"
	Set prop4.label=tlbl
	Set prop4.align="center"
	Set prop4.override="{headerAlign:'center'}"
	if ('SQLCODE) {
		Set prop4.rangeLower=min
		Set prop4.baseValue=avg
		Set prop4.thresholdLower=((avg-min)/2)+min
		Set prop4.thresholdUpper=max-((max-avg)/2)
	}
	do widget.dataProperties.Insert(prop4)
	
	Set prop5=##class(%DeepSee.Dashboard.DataProperty).%New()
	Set prop5.display="lamp"
	if (tlbl="%COUNT") Set tlbl="Count"
	Set prop5.dataValue="=["_tlbl_"]"
	Set prop5.label=tlbl
	Set prop5.align="center"
	Set prop5.override="{headerAlign:'center'}"
	Do widget.dataProperties.Insert(prop5)
	
	set widget.title=##class(AnalyzeThis.Dashboard.AutoPivot).ReformatName(pPivotName)
	do dash.widgets.Insert(widget)
	
	if (pLevel2'="") {
		//Create widget 2
		Set LevelName=pLevel2
		&sql(
			SELECT Maximum, Minimum, STDDEV, Mean into :max, :min, :std, :avg FROM AnalyzeThis_Dashboard.MetaData where (CubeName=:pcubeName AND LevelName=:LevelName)
		)
		QUIT:(SQLCODE)
		set wcreated=0
		kill widget
		set widget= ##class(%DeepSee.Dashboard.Widget).%New()
		
		set widget.dataSource="Generated-"_$E(pcubeName,1,15)_"/"_pPivotName_".pivot"
		set widget.name="ScoreCard"
		set widget.type="scoreCardWidget"
		set widget.subtype="regular"
		set widget.maximized=0
		Set widget.rowSpanL=5
		Set widget.colSpanL=10
		Set widget.homeRowL=5
		Set widget.homeColL=0
		
		Set prop1=##class(%DeepSee.Dashboard.DataProperty).%New()
		Set prop1.display="itemNo"
		Do widget.dataProperties.Insert(prop1)
		
		Set prop2=##class(%DeepSee.Dashboard.DataProperty).%New()
		Set prop2.display="label"
		Set prop2.width=240
		Do widget.dataProperties.Insert(prop2)
		
		Set tlbl=$piece($piece(pPivotName,"*",3),"-",2)
		Set prop3=##class(%DeepSee.Dashboard.DataProperty).%New()
		Set prop3.display="value"
		if (tlbl="%COUNT") Set tlbl="Count"
		Set prop3.dataValue="=["_tlbl_"]"
		Set prop3.label=tlbl
		Set prop3.align="center"
		Set prop3.override="{headerAlign:'center'}"
		Do widget.dataProperties.Insert(prop3)
		
		Set prop4=##class(%DeepSee.Dashboard.DataProperty).%New()
		Set prop4.display="plotBox"
		if (tlbl="%COUNT") Set tlbl="Count"
		Set prop4.dataValue="=["_tlbl_"]"
		Set prop4.label=tlbl
		Set prop4.align="center"
		Set prop4.override="{headerAlign:'center'}"
		if ('SQLCODE) {
			Set prop4.rangeLower=min
			Set prop4.targetValue=avg
			Set prop4.thresholdLower=((avg-min)/2)+min
			Set prop4.thresholdUpper=max-((max-avg)/2)
		}
		do widget.dataProperties.Insert(prop4)
		
		Set prop5=##class(%DeepSee.Dashboard.DataProperty).%New()
		Set prop5.display="arrow"
		if (tlbl="%COUNT") Set tlbl="Count"
		Set prop5.dataValue="=["_tlbl_"]"
		Set prop5.label=tlbl
		Set prop5.align="center"
		Set prop5.override="{headerAlign:'center'}"
		if ('SQLCODE) {
			Set prop5.rangeLower=avg
		}
		Do widget.dataProperties.Insert(prop5)
		
		set widget.title=##class(AnalyzeThis.Dashboard.AutoPivot).ReformatName(pPivotName)
		do dash.widgets.Insert(widget)
	}
	
	set st=dash.%Save()
	w:pVerbose st
	quit st

	QUIT $$$OK
}

}
