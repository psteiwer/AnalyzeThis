Class DeepSee.AbstractAmChart Extends (%ZEN.Component.component, %ZEN.Component.page, DeepSee.ListingInterface, %ZEN.Component.dataView)
{

Parameter INCLUDEFILES = "style:http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css,style:http://www.trirand.net/themes/ui.jqgrid.css,script:http://ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js,script:http://code.jquery.com/ui/1.10.3/jquery-ui.js,script:http://www.trirand.net/aspnetmvc/Scripts/trirand/i18n/grid.locale-en.js,script:http://www.trirand.net/js/trirand/jquery.jqGrid.min.js,script:themeswitchertool.js";

Property settings As %String [ MultiDimensional ];

Property barColor As %String;

Property enableListing As %Boolean;

Property hintText As %String;

Property captions As %String;

Property pager As %Boolean;

Property captionsFromSource As %Boolean;

ClassMethod %OnGetPortletName() As %String
{
    quit ""
}

ClassMethod %OnGetPortletIcon() As %String
{
    quit ""
}

ClassMethod %OnGetPortletSettings(Output pInfo As %List) As %Status
{
 	kill pInfo
  // $LB(name,value,type,caption,title)
  	set pInfo($I(pInfo)) = $LB("barColor","","%String",$$$Text("Bar color","DeepSee"),"")
 	set pInfo($I(pInfo)) = $LB("captionsFromSource",1,"%Boolean",$$$Text("Use captions from source","DeepSee"),"")
  	set pInfo($I(pInfo)) = $LB("captions","","%String",$$$Text("Captions","DeepSee"),"")
	set pInfo($I(pInfo)) = $LB("pager",1,"%Boolean",$$$Text("Enable pager?","DeepSee"),"")
	set pInfo($I(pInfo)) = $LB("enableListing",0,"%Boolean",$$$Text("Детализация","DeepSee"),"")
	set pInfo($I(pInfo)) = $LB("hintText","","%String",$$$Text("Текст в подсказке","DeepSee"),"")
 	
        
    quit $$$OK
}

ClientMethod getConnectedController() [ Language = javascript ]
{
	// connect to controller
	var controller = this.getController();
	if (null == controller) 
	{
		// try to connect to dataController
		this.connectToController();
		controller = this.getController();
	}
	
	return controller;
}

ClientMethod notifyViewHandler(reason, data1, data2, data3) [ Language = javascript ]
{
	
	switch(reason) 
	{
		case 'dataChange':
			this.acquireData();
			this.renderContents();
			
			break;
		case 'modelChange':
			this.renderContents();
			break;
	}
}

ClientMethod renderSameParts(self) [ Language = javascript ]
{
	renderListingButton(self,"amchart");
}

Method %DrawHTML()
{
	
    // This causes ZEN to render this component on the client.
    set ..renderFlag = ..renderFlag + 1
	#dim propName As %String = $order(..settings(""))
	while (propName '= "")
	{
		if ("" '= $get(..settings(propName)))
			try
			{
				set $property($this, propName) = ..settings(propName)
			}
			catch {}
		set propName = $order(..settings(propName))
	}
	
 &html<<div id="amchart#(..index)#" class="amchart#(..index)#" style="width: 300px; height: 300px;margin:5px;"></div>
	<div id="wrapper#(..index)#" style="display:none;"><table id="grid#(..index)#" style="width:100%; height:100%;"></table>
	<div id="pager#(..index)#"></div>
	</div>
  	<!--Это решает баг в портлете с запросом несуществующих функций  -->
   	<script type='text/javascript'>
        SVGAnimatedString.prototype.search = function () {return -1;};
        SVGAnimatedString.prototype.split = function () {return [""]};
   </script>
   <script type='text/javascript' src='http://www.amcharts.com/lib/3/amcharts.js'></script>
   <script type='text/javascript' src='http://www.amcharts.com/lib/3/funnel.js'></script>
    <script type='text/javascript' src='http://www.amcharts.com/lib/3/serial.js'></script>
    <script src="http://www.amcharts.com/lib/3/pie.js" type="text/javascript"></script>
  
    >
	d ##class(DeepSee.ListingInterface).DrawHTML()
}

/// Notification from the containing widget that the page is loaded or the widget is resized.
/// Subclass can implement this, if they wish.
ClientMethod adjustContentSize(load, width, height) [ Language = javascript ]
{
	
	var obj=document.getElementById('amchart'+this.index);
	obj.style.width=width+'px';
	obj.style.height=height+'px';
	if(this.chart) { 
	  this.chart.invalidateSize();
	  resizeGrid(this,width,height);
	  }
}

}
