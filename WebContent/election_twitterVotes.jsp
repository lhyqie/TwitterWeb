<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="data.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %> 
<%@ page import="java.io.*" %> 
<% 
	String type = null;
	if (request.getParameter("type") != null) {
   		type = request.getParameter("type");
	}else {
		type = "election";
	}
    int sd = 26;
    int sm = 2;  //month 1 means Feb
    int sy = 2012;
    

    String candidates[] = {"Barack Obama", "Randall Terry", "Mitt Romney", "Rick Santorum", "Newt Gingrich", "Ron Paul"};
    LinkedList< ArrayList<Integer> > voteSeries = new LinkedList< ArrayList<Integer> >();
    LinkedList<java.util.Date> dates = new LinkedList<java.util.Date>();
	Calendar fromDate = new GregorianCalendar(sy,sm,sd,0,0);
    Calendar now = Calendar.getInstance();
    int ed = now.get(Calendar.DATE);
    int em = now.get(Calendar.MONTH);
    int ey = now.get(Calendar.YEAR);
	HighLowDataSet dataSet = StockDatasetFactory2.createHighLowDatasetByDay("^DJI",sm,sd,sy,em,ed,ey);
    //out.println(dartaSet);
	// store all the dates 
	
	String connectionURL = "jdbc:mysql://liu.cs.uic.edu:3306/twitterdb"; 
	// declare a connection by using Connection interface 
	Connection connection = null; 
	// Load JBBC driver "com.mysql.jdbc.Driver" 
	Class.forName("com.mysql.jdbc.Driver").newInstance(); 
	connection = DriverManager.getConnection(connectionURL, "root", "bingteam");
	Statement statement = connection.createStatement();
	ResultSet rs = null;
	String sql = null ;
	try{
		sql = "select distinct Date(`time`) as aDate, sum(Obama) as cObama, sum(Terry) as cTerry, sum(Romney) as cRomney, sum(Santorum) as cSantorum, sum(Gingrich) as cGingrich, sum(Paul) as cPaul from election_timeseries where `time` >=" + fromDate.getTime().getTime() +" group by Date(`time`)";
		rs = statement.executeQuery(sql);											
	    System.out.println(sql);
		
		while(rs.next()){
			java.util.Date d = rs.getDate("aDate");
			dates.add(d);
			
			ArrayList<Integer> votes = new ArrayList<Integer>();
			votes.add(rs.getInt("cObama"));
			votes.add(rs.getInt("cTerry"));
			votes.add(rs.getInt("cRomney"));
			votes.add(rs.getInt("cSantorum"));
			votes.add(rs.getInt("cGingrich"));
			votes.add(rs.getInt("cPaul"));
		
			voteSeries.add(votes);
		}
	}catch(Exception e){
		
	}  
%>

<!DOCTYPE HTML>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>Twitter "Votes" in election 2012</title>
		
		<Script language="JavaScript">
		<!-- Script courtesy of http://www.web-source.net - Your Guide to Professional Web Site Design and Development
		function goto(form) { var index=form.select.selectedIndex
		if (form.select.options[index].value != "0") {
		location=form.select.options[index].value;}}
		//-->
		</SCRIPT>
		<!-- 1. Add these JavaScript inclusions in the head of your page -->
		<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>
		<script type="text/javascript" src="highcharts.js"></script>
		
		<!-- 2. Add the JavaScript to initialize the chart on document ready -->
		<script type="text/javascript">
		
			var chart;
			$(document).ready(function() {
				chart = new Highcharts.Chart({
					chart: {
						renderTo: 'container',
						defaultSeriesType: 'line',
						marginRight: 130,
						marginBottom: 25
					},
					title: {
						text: 'Twitter Mentions of the Candidates in 2012 Election',
						x: -20 //center
					},
					subtitle: {
						text: 'Source: Yahoo! Finance & Twitter.com',
						x: -20
					},
					xAxis: {
						endOnTick : false,
					    tickInterval: <%=(int)(dataSet.close.length/8)%>,
						maxZoom: 20 * 1000,
						categories: [<%
						                  DateFormat dateFormat = new SimpleDateFormat("MM/dd/YY");
									      for(int i = 0 ; i< dates.size(); i++){
									    	   //System.out.println(dataSet.date[i]);
									    	   //System.out.println(dateFormat.format(dataSet.date[i]));
										       out.print("'"+dateFormat.format(dates.get(i))+"'"  + (i < dates.size()-1? ",":""));
										       //System.out.print("'"+dateFormat.format(dataSet.date[i])+"'"  + (i < dataSet.close.length-1? ",":""));
									      }
									%>]
					},
					yAxis: [{
						title: {
							text: 'Twitter Votes'
						},
						plotLines: [{
							value: 0,
							width: 1,
							color: '#808080'
						}],
		
					}],
					tooltip: {
						formatter: function() {
				                return '<b>'+ this.series.name +'</b><br/>'+
								this.x +': '+' '+ this.y ;
						}
					},
					legend: {
						align: 'right',
						verticalAlign: 'top',
						x: -10,
						y: 50,
						floating: true
					},
					series: [
					  <% for(int k = 0 ; k <6; k++) {%>
					  	{
							name: '<%out.print(candidates[k]);%>',
							data: [<%
									        
												for(int i = 0; i<voteSeries.size(); i++){
													ArrayList<Integer> votes = voteSeries.get(i);
													out.println(""+ votes.get(k)+(i < voteSeries.size()-1? ",":""));
												}
												rs.close();
												statement.close();
												connection.close();
											      
										    
							      %>],
							yAxis: 0
						},<% }%>
					]
				});
				
				
			});
				
		</script>
		
	</head>
	<body>
		
		<div><FORM NAME="form1">
			<SELECT NAME="select" ONCHANGE="goto(this.form)" SIZE="1">
				<OPTION VALUE="DJIA_vs_opinion.jsp?type=mood" <%if(type.equals("mood")){out.print(" selected ");}%> >mood</OPTION>
				<OPTION VALUE="election_twitterVotes.jsp?type=election" <%if(type.equals("election")){out.print(" selected ");}%> >election</OPTION>
				<OPTION VALUE="DJIA_vs_opinion.jsp?type=finance-economy" <%if(type.equals("finance-economy")){out.print(" selected ");}%> >finance-economy</OPTION>
			</SELECT>
			</FORM>  
		</div>
		<!-- 3. Add the container -->
		<div id="container" style="width: 1000px; height: 600px; "></div>
		
				
	</body>
</html>
