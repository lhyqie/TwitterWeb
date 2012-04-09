<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<%@page import="java.util.*"%>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>Simplest model - counting tweets per second</title>
		
		
		<!-- 1. Add these JavaScript inclusions in the head of your page -->
		<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
		<script type="text/javascript" src="highcharts.src.js"></script>

		
		
		<!-- 2. Add the JavaScript to initialize the chart on document ready -->
		<script type="text/javascript">
		var chart; // global
		var first = true;
		Highcharts.setOptions({
			global: {
				useUTC: false
			}
		});
		/**
		 * Request data from the server, add it to the graph and set a timeout to request again
		 */
		function requestData() {
			$.ajax({
				url: 'tweets_per_second_data2.jsp', 
				success: function(point) {
					var series = chart.series[0],
						shift = series.data.length > 20; // shift if the series is longer than 20
		            if(first){
						<%  
						    for(int i = 0; i< 20 ; i++){
						    	//System.out.println(now.getTimeInMillis());
								Calendar now = Calendar.getInstance();
						        now.add(Calendar.MINUTE,-10);
						    	now.add(Calendar.SECOND,-(20-i)*2);
								out.print("chart.series[0].addPoint(["+ now.getTime().getTime()+","+ (int)(Math.random()*20 + 20) +"], true, false);");
						    }
							
				        %>
						
						first = false;
					}
					// add the point
					chart.series[0].addPoint(eval(point), true, shift);
					
					// call it again after one second
					setTimeout(requestData, 2*1000);	
				},
				cache: false
			});
		}
			
		$(document).ready(function() {
			chart = new Highcharts.Chart({
				chart: {
					renderTo: 'container',
					defaultSeriesType: 'spline',
					events: {
						load: requestData
					}
				},
				title: {
					text: 'TwitterProject'
				},
				subtitle: {
					text: 'Source: Twitter.com',
					x: -20
				},
				xAxis: {
					type: 'datetime',
					tickPixelInterval: 150,
					maxZoom: 20 * 1000
				},
				yAxis: {
					minPadding: 0.2,
					maxPadding: 0.2,
					title: {
						text: '# of tweets',
						margin: 80
					}
				},
				series: [{
					name: '# of tweets per second',
					data: []
				}]
			});		
		});
		</script>
		
	</head>
	<body>
		
		<!-- 3. Add the container -->
		<div id="container" style="width: 800px; height: 400px; margin: 0 auto"></div>
		<div>
		  <ul><b>Note:</b>
			<li>Time is lagged about 10 minutes due to the delay of crawling from Twitter.com </li>
		  </ul>
			 
		</div>
	
	</body>
</html>