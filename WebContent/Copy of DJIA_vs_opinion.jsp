<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="data.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %> 
<%@ page import="java.io.*" %> 
<% 
    int sd = 27;
    int sm = 1;  //month 1 means Feb
    int sy = 2012;
    Calendar fromDate = new GregorianCalendar(sy,sm,sd,0,0);
    Calendar now = Calendar.getInstance();
    int ed = now.get(Calendar.DATE);
    int em = now.get(Calendar.MONTH);
    int ey = now.get(Calendar.YEAR);
	HighLowDataSet dataSet = StockDatasetFactory2.createHighLowDatasetByDay("^DJI",sm,sd,sy,em,ed,ey);
    
	// store all the dates 
	HashSet<java.util.Date> dates = new HashSet<java.util.Date>(); // all availabel dates
	LinkedList<Long> allPos = new LinkedList<Long>();  // all counts of positive words
	LinkedList<Long> allNeg = new LinkedList<Long>();  // all counts of negative words
	
	for(int i = 0; i<dataSet.date.length; i++){
		dates.add(dataSet.date[i]);
	}
	
	String connectionURL = "jdbc:mysql://liu.cs.uic.edu:3306/twitterdb"; 
	// declare a connection by using Connection interface 
	Connection connection = null; 
	// Load JBBC driver "com.mysql.jdbc.Driver" 
	Class.forName("com.mysql.jdbc.Driver").newInstance(); 
	connection = DriverManager.getConnection(connectionURL, "root", "bingteam");
	Statement statement = connection.createStatement();
	ResultSet rs = null;
	String sql = null ;
    //rs = statement.executeQuery("SELECT time, MONTH(`time`) as month, DAY(`time`) as day, HOUR(`time`) as h, MINUTE(`time`) AS m, COUNT(*) as cnt FROM //tweet GROUP BY month,day, h, m order by month desc, day desc, h desc, m desc  limit 0,1");
	try{
		sql = "select distinct Date(`time`) as aDate, sum(pos) as cPos, sum(neg) as cneg from opinion_timeseries where `time` >=" + fromDate.getTime().getTime() +" group by Date(`time`)";
		rs = statement.executeQuery(sql);											
		//System.out.println(sql);
		
		while(rs.next()){
			java.util.Date d = rs.getDate("aDate");
			if(dates.contains(d)){
			   allPos.add(rs.getLong("cPos")); 
			   allNeg.add(rs.getLong("cNeg"));
			  //System.out.println(d);
			}	
		}
	}catch(Exception e){
		
	}  
%>

<!DOCTYPE HTML>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>DJIA vs Opinion words in Tweets</title>
		
		
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
						text: 'StockPrice for DJIA v.s. # of opinion words',
						x: -20 //center
					},
					subtitle: {
						text: 'Source: Yahoo! Finance & Twitter.com',
						x: -20
					},
					xAxis: {
						endOnTick : false,
					    tickInterval: 1,
						maxZoom: 20 * 1000,
						categories: [<%
						                  DateFormat dateFormat = new SimpleDateFormat("MM/dd/YY");
									      for(int i = 0 ; i< dataSet.close.length; i++){
									    	   //System.out.println(dataSet.date[i]);
									    	   //System.out.println(dateFormat.format(dataSet.date[i]));
										       out.print("'"+dateFormat.format(dataSet.date[i])+"'"  + (i < dataSet.close.length-1? ",":""));
										       //System.out.print("'"+dateFormat.format(dataSet.date[i])+"'"  + (i < dataSet.close.length-1? ",":""));
									      }
									%>]
					},
					yAxis: [{
						title: {
							text: 'Stock Price for DJIA'
						},
						plotLines: [{
							value: 0,
							width: 1,
							color: '#808080'
						}],
		
					},{
						opposite: true,
						title: {
							text: '# of Positive and Negative opinion words'
						},
						plotLines: [{
							value: 0,
							width: 1,
							color: '#303080'
						}]
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
					series: [{
						name: 'DJIA',
						data: [<%
						          for(int i = 0 ; i< dataSet.close.length; i++){
						        	  out.print(dataSet.close[i] + (i < dataSet.close.length-1? ",":""));
						    
						          }
						
						      %>]
					},{
						name: 'Positive Opinions',
						data: [<%
								        
											for(int i = 0; i<allPos.size(); i++){
												out.println(""+allPos.get(i) + (i!= allPos.size()-1 ? ",":"") );
											}
											rs.close();
											statement.close();
											connection.close();
										      
									    
						      %>],
						yAxis: 1
					},{
						name: 'Negative Opinions',
						data: [<%
								        
											for(int i = 0; i<allNeg.size(); i++){
												out.println(""+allNeg.get(i) + (i!= allNeg.size()-1 ? ",":"") );
											}
											rs.close();
											statement.close();
											connection.close();
										      
									    
						      %>],
						yAxis: 1
					}
					
					]
				});
				
				
			});
				
		</script>
		
	</head>
	<body>
		
		<!-- 3. Add the container -->
		<div id="container" style="width: 1000px; height: 600px; "></div>
		
				
	</body>
</html>
