<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<%@page import="java.util.*" %>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>Highcharts Example</title>
		
		
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
				url: 'text.jsp', 
				success: function(point) { 
					var series = chart.series[0],
						shift = series.data.length > 20; // shift if the series is longer than 20
		
					// add the point
					
					if(first){
						<%  Calendar now = Calendar.getInstance();
						    for(int i = 0; i< 20 ; i++){
						    	//System.out.println(now.getTimeInMillis()-(19-i)*1000);
						    	//System.out.println(new java.util.Date(now.getTimeInMillis()-(19-i)*1000));
						    	out.print("chart.series[0].addPoint(["+ (now.getTimeInMillis()-(19-i)*1000)+","+ (int)(Math.random()*20) +"], true, false);");
						    	
						    }
							
				        %>
						
						first = false;
					}
					chart.series[0].addPoint(eval(point), true, shift);
					// call it again after one second
					setTimeout(requestData, 3000);	
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
					text: 'Live random data'
				},
				xAxis: {
					type: 'datetime',
					tickPixelInterval: 150,
					maxZoom: 20 * 1000,
					
				},
				yAxis: {
					minPadding: 0.2,
					maxPadding: 0.2,
					title: {
						text: 'Value',
						margin: 80
					}
				},
				series: [{
					name: 'Random data',
					data: [],
				    pointStart:  Date.UTC(2010, 0, 1)
				}]
				
			});		
		});
		</script>
		
	</head>
	<body>
		
		<!-- 3. Add the container -->
		<div id="container" style="width: 800px; height: 400px; margin: 0 auto">1231</div>
		
	
	</body>
</html>