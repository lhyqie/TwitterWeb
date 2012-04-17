<%@page import="java.sql.Date"%>
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
	}else{
	   type = "mood";
	}

    int sd = 12;
    int sm = 2;  //month 1 means Feb
    int sy = 2012;
    
	if(!type.equals("mood")){
		sd = 25; sm= 2; sy =2012;
	}

	int k = 1;   // moving average for k days
	if (request.getParameter("k") != null) {
		   k = Integer.parseInt(request.getParameter("k"));
	}
	
	int lead = 0; //the leading time of Twitter
	if (request.getParameter("lead") != null) {
		lead = Integer.parseInt(request.getParameter("lead"));
	}
	
	Calendar fromDate = new GregorianCalendar(sy,sm,sd,0,0);
    Calendar now = Calendar.getInstance();
    int ed = now.get(Calendar.DATE);
    int em = now.get(Calendar.MONTH);
    int ey = now.get(Calendar.YEAR);
    
    java.sql.Date fromDataSQL = new Date(sy-1900,sm,sd);
	HighLowDataSet dataSet = StockDatasetFactory2.createHighLowDatasetByDay("^DJI",sm,sd,sy,em,ed,ey);
    //out.println(dartaSet);
	// store all the dates 
	LinkedList<java.util.Date> dates = new LinkedList<java.util.Date>(); // all availabel dates
	LinkedList<Long> allPos = new LinkedList<Long>();  // all counts of positive words
	LinkedList<Long> allNeg = new LinkedList<Long>();  // all counts of negative words
	LinkedList< LinkedList<Long> > allPos_GPOMS = new LinkedList< LinkedList<Long> >();
	LinkedList< LinkedList<Long> > allNeg_GPOMS = new LinkedList< LinkedList<Long> >();
	//String GPOMS_Name[] = {"Calm", "Sure","Vital","Kind","Happy","Alert"};
	String GPOMS_Name[] = {"predictor1", "predictor2","Vital","Kind","Happy","Alert"};
	for(int i = 0; i <6; i++){
		allPos_GPOMS.add(new LinkedList<Long>());
		allNeg_GPOMS.add(new LinkedList<Long>());
	}
	//out.println("size="+dataSet.getSize());

	
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
		sql = "select distinct Date(`time`) as aDate, sum(pos) as cPos, sum(neg) as cneg,  sum(alert_pos) as cAlertPos, sum(alert_neg) as cAlertNeg, sum(calm_pos) as cCalmPos, sum(calm_neg) as cCalmNeg, sum(sure_pos) as cSurePos, sum(sure_neg) as cSureNeg, sum(vital_pos) as cVitalPos, sum(vital_neg) as cVitalNeg, sum(kind_pos) as cKindPos, sum(kind_neg) as cKindNeg, sum(happy_pos) as cHappyPos, sum(happy_neg) as cHappyNeg from opinion_timeseries where `time` >='" + fromDataSQL +"' and type ='"+type+"' group by Date(`time`)";
		rs = statement.executeQuery(sql);											
	    //out.println(sql);
		
		while(rs.next()){
			java.util.Date d = rs.getDate("aDate");
			  
			   d.setTime(d.getTime() + lead * 24 * 60 * 60 * 1000);
			   dates.add(d);
	
			   allPos.add(rs.getLong("cPos")); 
			   allNeg.add(rs.getLong("cNeg"));
			   
			   allPos_GPOMS.get(0).add(rs.getLong("cCalmPos"));
			   allPos_GPOMS.get(1).add(rs.getLong("cSurePos"));
			   allPos_GPOMS.get(2).add(rs.getLong("cVitalPos"));
			   allPos_GPOMS.get(3).add(rs.getLong("cKindPos"));
			   allPos_GPOMS.get(4).add(rs.getLong("cHappyPos"));
			   allPos_GPOMS.get(5).add(rs.getLong("cAlertPos"));
			   
			   allNeg_GPOMS.get(0).add(rs.getLong("cCalmNeg"));
			   allNeg_GPOMS.get(1).add(rs.getLong("cSureNeg"));
			   allNeg_GPOMS.get(2).add(rs.getLong("cVitalNeg"));
			   allNeg_GPOMS.get(3).add(rs.getLong("cKindNeg"));
			   allNeg_GPOMS.get(4).add(rs.getLong("cHappyNeg"));
			   allNeg_GPOMS.get(5).add(rs.getLong("cAlertNeg"));
			   
			   //allPos_GPOMS.get(0).add(rs.getLong("cAlertPos"));
			   //allPos_GPOMS.get(1).add(rs.getLong("cCalmPos"));
			   //allPos_GPOMS.get(2).add(rs.getLong("cSurePos"));
			   //allPos_GPOMS.get(3).add(rs.getLong("cVitalPos"));
			   //allPos_GPOMS.get(4).add(rs.getLong("cKindPos"));
			   //allPos_GPOMS.get(5).add(rs.getLong("cHappyPos"));
			   
			   //allNeg_GPOMS.get(0).add(rs.getLong("cAlertNeg"));
			   //allNeg_GPOMS.get(1).add(rs.getLong("cCalmNeg"));
			   //allNeg_GPOMS.get(2).add(rs.getLong("cSureNeg"));
			   //allNeg_GPOMS.get(3).add(rs.getLong("cVitalNeg"));
			   //allNeg_GPOMS.get(4).add(rs.getLong("cKindNeg"));
			   //allNeg_GPOMS.get(5).add(rs.getLong("cHappyNeg"));
			   
			  //System.out.println(d);
		}
	}catch(Exception e){
		
	}  
%>

<!DOCTYPE HTML>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>DJIA vs Opinion words in Tweets</title>
		
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
				Highcharts.setOptions({
			        colors: ['#FF0000','#058DC7', '#000000', '#707070', '#DDDF00', '#24CBE5', '#64E572', '#FF9655']
				});
				chart = new Highcharts.Chart({
					chart: {
						renderTo: 'container',
						defaultSeriesType: 'line',
						marginBottom: 80
					},
					title: {
						text: 'Dow Jones Industrial Average (DJIA) v.s. # of Twitter Sentiments',
						x: -20 //center
					},
					subtitle: {
						text: 'Source: Yahoo! Finance & Twitter.com',
						x: -20
					},
					xAxis: {
						type: 'datetime',
					    labels: {
			                rotation: 270,
			                y:30
			            },
			            plotBands:[  // mark the weekend
			                        <%
			                        ArrayList<java.util.Date> saturdays = new ArrayList<java.util.Date>();
			                     	ArrayList<java.util.Date> sundays = new ArrayList<java.util.Date>();
			                     	for (int i = 0; i < dates.size(); i++) {
			                     		
			                 			if(dates.get(i).getDay()==5){
			                 				saturdays.add(dates.get(i));
			                 				continue;
			                 			}
			                 			if(dates.get(i).getDay()==1){
			                 				if(saturdays.size() > 0)
			          							sundays.add(dates.get(i));
			                 				continue;
			                 			}
			                 		}
			                     	
			                     	for(int i = 0; i< Math.min(saturdays.size(),sundays.size()); i++){
			                     		out.println("{");
			                     		out.println(" color: '#FCFFC5',");
			                     		out.println("from: Date.UTC("+(saturdays.get(i).getYear()+1900)+","+saturdays.get(i).getMonth()+","+saturdays.get(i).getDate()+"),");
			                     		out.println("to: Date.UTC("+(sundays.get(i).getYear()+1900)+","+sundays.get(i).getMonth()+","+sundays.get(i).getDate()+"),");
			                     		out.println("},");
			                     	}
			                 		%>
			           			
			            ]
					},
					yAxis: [{
						title: {
							text: 'DJIA'
						},
						labels: {
			                y:0
			            }
						
					},{
						opposite: true,
						title: {
							text: 'ratio of Positive to Postive + Negative'
						},
					}],
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
						          //System.out.println(dates);
						          for(int i = 0 ; i< dataSet.close.length; i++){
						              //java.util.Date d1 = dates.get(i);
						              //double closeValue = 0;
						        	  //boolean weekend = true;
						        	  //System.out.println("d1="+d1.getYear()+","+d1.getMonth()+","+d1.getDate());
						        	  //for(int j = 0; j < dataSet.date.length; j ++){
						        	  //	  java.util.Date d2 = (java.util.Date)dataSet.date[j];  
						        		 // System.out.println("d2="+d2.getYear()+","+d2.getMonth()+","+d2.getDate());
						        	  //	  if(d1.getYear() == d2.getYear() && d1.getMonth() == d2.getMonth() && d1.getDate() == d2.getDate()  ){
						        	  //		  weekend = false;
						        	  //		  closeValue = dataSet.close[j];
						        	  //		  break;
						        	 //	  }
						        	  //}
						        	  //System.out.println(dataSet.date[i]);
						        	  //if(!weekend){
						        		 //out.print("['"+dateFormat.format(dataSet.date[i])+"',"+dataSet.close[i] +"],");
						        		 out.print("[Date.UTC("+(dataSet.date[i].getYear()+1900)+","+dataSet.date[i].getMonth()+","+dataSet.date[i].getDate()+"),"+dataSet.close[i] +"],");
						        	  //}
						          }
						
						      %>]
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
					 <% //for(int t = 0 ; t <6; t++) { //only show calm and sure
						 for(int t = 0 ; t <2; t++) {
					  %>
					  {
						name: '<%out.print(GPOMS_Name[t]);%>',
						data: [<%
								        
											for(int i = k - 1; i<allPos_GPOMS.get(t).size(); i++){
												double ave = 0.0;
												for(int j = 0 ; j <= k - 1 ; j++){
													double d = (double)(allPos_GPOMS.get(t).get(i-j))/(allNeg_GPOMS.get(t).get(i-j)+allPos_GPOMS.get(t).get(i-j)+1);
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
					},<% }%>
					]
				});
				
				
			});
				
		</script>
		
	</head>
	<body>
		
		<div><FORM NAME="form1">
			<!--  <SELECT NAME="select" ONCHANGE="goto(this.form)" SIZE="1">
				<OPTION VALUE="DJIA_vs_opinion.jsp?type=mood" <%if(type.equals("mood")){out.print(" selected ");}%> >mood</OPTION>
				<OPTION VALUE="election_twitterVotes.jsp?type=election" <%if(type.equals("election")){out.print(" selected ");}%> >election</OPTION>
				<OPTION VALUE="DJIA_vs_opinion.jsp?type=finance-economy" <%if(type.equals("finance-economy")){out.print(" selected ");}%> >finance-economy</OPTION>
			</SELECT>
			-->
			</FORM>  
		</div>
		<!-- 3. Add the container -->
		<div id="container" style="width: 1000px; height: 600px; "></div>
		<br>
		<div> 1. Click the name of the category in the legend to show or hide the corresponding plot. <br>
		      2. Area in shadow represents weekends. <br>
		      3. Predictor1 and Predictor2 are computed with an algorithm using two subsets of terms from our <a href="http://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html"> sentiment lexicon </a> <br>
	</body>
</html>
