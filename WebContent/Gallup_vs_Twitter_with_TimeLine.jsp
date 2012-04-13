<%@page import="java.sql.Date"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="data.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.sql.*" %> 
<%@ page import="java.io.*" %> 
<% 

    int sd = 10;
    int sm = 3;  //month 1 means Feb
    int sy = 2012;
    	
	int k = 1;   // moving average for k days
	if (request.getParameter("k") != null) {
		   k = Integer.parseInt(request.getParameter("k"));
	}
	
	int lead = 0; //the leading time of Twitter
	if (request.getParameter("lead") != null) {
		lead = Integer.parseInt(request.getParameter("lead"));
	}
	
	Calendar fromDate = new GregorianCalendar(sy,sm,sd,0,0);
    java.sql.Date fromDataSQL = new Date(sy-1900,sm,sd);
	TimeSeriesDataSet dataSet = GallUpDatasetFactory.createHighLowDatasetByDay(sm+1, sd, sy);
	
    LinkedList<java.util.Date> dates = new LinkedList<java.util.Date>(); // all availabel dates
	LinkedList<Long> allPos = new LinkedList<Long>();  // all counts of positive words
	LinkedList<Long> allNeg = new LinkedList<Long>();  // all counts of negative words
	
	String connectionURL = "jdbc:mysql://liu.cs.uic.edu:3306/twitterdb2"; 
	// declare a connection by using Connection interface 
	Connection connection = null; 
	// Load JBBC driver "com.mysql.jdbc.Driver" 
	Class.forName("com.mysql.jdbc.Driver").newInstance(); 
	connection = DriverManager.getConnection(connectionURL, "root", "bingteam");
	Statement statement = connection.createStatement();
	ResultSet rs = null;
	String sql = null ;
    try{
		sql = "select distinct Date(`time`) as aDate, sum(pos) as cPos, sum(neg) as cneg from consumer_confidence_timeseries where `time` >='" + fromDataSQL +"' group by Date(`time`)";
		rs = statement.executeQuery(sql);											
	    System.out.println(sql);
		while(rs.next()){
			   java.util.Date d = rs.getDate("aDate");
			  
			   d.setTime(d.getTime() + lead * 24 * 60 * 60 * 1000);
			   dates.add(d);

			   allPos.add(rs.getLong("cPos")); 
			   allNeg.add(rs.getLong("cNeg"));

		}
	}catch(Exception e){
		
	}  
%>

<!DOCTYPE HTML>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>Gallup Job Creation Index and Economic Confidence Index v.s. # of Twitter Sentiments</title>
		
		<Script language="JavaScript">
		<!-- Script courtesy of http://www.web-source.net - Your Guide to Professional Web Site Design and Development
		function goto(form) { var index=form.select.selectedIndex
		if (form.select.options[index].value != "0") {
		location=form.select.options[index].value;}}
		//-->
		</SCRIPT>
		<!-- 1. Add these JavaScript inclusions in the head of your page -->
		<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>
		<script type="text/javascript" src="highstock.js"></script>
		
		<!-- 2. Add the JavaScript to initialize the chart on document ready -->
		<script type="text/javascript">
		
			var chart;
			$(document).ready(function() {
				Highcharts.setOptions({
			        colors: ['#FF0000','#058DC7', '#000000', '#707070', '#DDDF00', '#24CBE5', '#64E572', '#FF9655']
				});
				chart = new Highcharts.StockChart({
					chart: {
						renderTo: 'container',
						defaultSeriesType: 'line',
						marginBottom: 80
					},
					title: {
						text: 'Gallup Job Creation Index and Economic Confidence Index v.s. # of Twitter Sentiments',
						x: -20 //center
					},
					subtitle: {
						text: 'Source: <a href="http://www.gallup.com/poll/122840/Gallup-Daily-Economic-Indexes.aspx">Gallup.com</a> & <a href="https://twitter.com">Twitter.com</a>',
						x: -20
					},
					xAxis: {
						type: 'datetime',
					    labels: {
			                rotation: 270,
			                y:30
			            }
					},
					yAxis: [{
						title: {
							text: 'Gallup Job Creation Index and Economic Confidence Index'
						},
						labels: {
			                y:0,
			                X:100
			            }
						
					},{
						opposite: true,
						title: {
							text: 'ratio of Positive to Negative Tweets'
						},
					}],
					legend: {
			            enabled: true,
			            align: 'right',
			            backgroundColor: '#FCFFC5',
			            borderColor: 'black',
			            borderWidth: 2,
			            layout: 'vertical',
			            verticalAlign: 'top',
			            y: 100,
			            shadow: true
			        },
					series: [{
						name: 'Gallup Economic Confidence Index',
						data: [<%
						          for(int i = 0 ; i< dataSet.eci.length; i++){
						              out.print("[Date.UTC("+(dataSet.date[i].getYear()+1900)+","+dataSet.date[i].getMonth()+","+dataSet.date[i].getDate()+"),"+dataSet.eci[i] +"],");
						          }
						      %>],
						yAxis: 0
					},		{
						name: 'Gallup Job Creation Index',
						data: [<%
						          for(int i = 0 ; i< dataSet.jci.length; i++){
						              out.print("[Date.UTC("+(dataSet.date[i].getYear()+1900)+","+dataSet.date[i].getMonth()+","+dataSet.date[i].getDate()+"),"+dataSet.jci[i] +"],");
						          }
						      %>],
						yAxis: 0
					},
					//  {  //only show calm and sure
					//	name: 'OpinionLexicon',
					//	data: 
					//	[
						  <%
				          /* 				        
											for(int i = k - 1; i < allPos.size(); i++){
												double ave = 0.0;
												//out.println(""+ d + (i!= allPos.size()-1 ? ",":"") );
												for(int j = 0 ; j <= k - 1 ; j++){
													double d = (double)(allPos.get(i-j))/(allNeg.get(i-j)+allPos.get(i-j)+1);
													ave +=d;
												}
												ave/=k;
												ave = (double)((int)(ave*1000))/1000;
												out.print("[Date.UTC("+(dates.get(i).getYear()+1900)+","+dates.get(i).getMonth()+","+dates.get(i).getDate()+"),"+ ave +"],");
											}
											rs.close();
											statement.close();
											connection.close();
						   */				      
									    
						      %>
					//	      ],
					//	yAxis: 1
					//},
					 
					  {
						name: 'ratio of Twitter Sentiments',
						data: [<%
								        
											for(int i = k - 1; i<allPos.size(); i++){
												double ave = 0.0;
												for(int j = 0 ; j <= k - 1 ; j++){
													double d = (double)(allPos.get(i-j))/(allNeg.get(i-j) + 1);
													ave +=d;
												}
												ave/=k;
												ave = (double)((int)(ave*1000))/1000;
												out.print("[Date.UTC("+(dates.get(i).getYear()+1900)+","+dates.get(i).getMonth()+","+dates.get(i).getDate()+"),"+ ave +"],");
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
		<br>
		<div> 1. Click the name of the category in the legend to show or hide the corresponding plot. <br>
		      2. ratio of Twitter Sentiments is computed using terms from <a href="http://www.cs.pitt.edu/mpqa/subj_lexicon.html"> Subjectivity Lexicon </a> by University of Pittsburgh <br>
		      3. The ratio of Twitter Sentiments is real time, but there is a lag for the two indices of Gallup. And the index is based on a 3-days rolling average. (For example, the index value of April 12 is essentially an average of April 10 to April 12).
	</body>
</html>
