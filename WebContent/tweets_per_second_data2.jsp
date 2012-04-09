<%@ page import="java.sql.*" %> 
<%@ page import="java.io.*" %> 
<%@ page import="java.util.*" %> 
<% 
String connectionURL = "jdbc:mysql://liu.cs.uic.edu:3306/twitterdb2"; 
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
		rs = statement.executeQuery("select `time`, count(*) as cnt from tweet where `time` =  ADDDATE(now(), INTERVAL -10 MINUTE)");
		Calendar now = Calendar.getInstance();
		now.add(Calendar.MINUTE,-10);
		java.util.Date ago = now.getTime();
		if (rs.next()) {
		   //out.println("["+rs.getTimestamp("time").getTime());
		   
		   out.println("["+ ago.getTime());
		   out.println(","+rs.getInt("cnt")+"]");
		}else{
		   //out.println("["+rs.getTimestamp("time").getTime());
		   out.println("["+ago.getTime() );
		   out.println(","+0+"]");
		   //out.println(","+(int)(Math.random()*1000)+"]");
		}
		rs.close();
		statement.close();
		connection.close();
	}catch(Exception e){

	}
%>
