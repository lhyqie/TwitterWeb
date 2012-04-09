package data;
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;
/**
 *
 * @author Huayi
 */
 
 /***
 *  unlike StockDatasetFactory, StockDatasetFactory2 fetched the stock price from yahoo directly  
 *  and feteched the list of stockSymbols from local files.
 * @author Huayi
 */
public class StockDatasetFactory2 {
    static String urlHead = "http://table.finance.yahoo.com/table.csv?s=";
    //urlMiddle like this "AAPL&a=05&b=7&c=2011&d=06&e=30&f=2011";
    static String urlTail = "&g=d&ignore=.csv";
    public StockDatasetFactory2(){
           
    }
    public static HighLowDataSet createHighLowDatasetByDay(String stockName){
        Date date = new Date();
        int currentYear = (1900+date.getYear());
        int currentMonth = date.getMonth();
        int currentDay = date.getDate();
        return createHighLowDatasetByDay(stockName, 0,1,2001, currentMonth, currentDay, currentYear);
    }
    public static HighLowDataSet createHighLowDatasetByDay(String stockName, int sm, int sd, int sy, int em , int ed , int ey){
        //System.out.println("StockDatasetFactory2 creating"+stockName);
        LinkedList<String> dataLines = new LinkedList<String>();
        // 1. read data from yahoo
        try {
            String urlString = urlHead +stockName+"&a="+sm+"&b="+sd+"&c="+sy+"&d="+em+"&e="+ed+"&f="+ ey + urlTail;
            System.out.println(urlString);
            URL yahooURL = new URL(urlString);
            URLConnection conn = yahooURL.openConnection();
            BufferedReader in = new BufferedReader(
                                new InputStreamReader(
                                conn.getInputStream()));
            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                //System.out.println(inputLine);
                dataLines.add(inputLine);
            }
            in.close();
        } catch (Exception ex) {
            System.err.println("netword problem: fail to  connect to Yahoo finance");
        }
        int n = dataLines.size()-1;
        if( n <=0 ) return null;
        // 
        final Date[] date = new Date[ n];
        final double[] high = new double[ n];
        final double[] low = new double[ n];
        final double[] open = new double[ n];
        final double[] close = new double[ n];
        final double[] volume = new double[ n];
        
        for(int i = n; i >= 1 ; i--){
            String pieces[] = dataLines.get(i).split(",");
            String datePieces[] = pieces[0].split("-");
            date[n-i] = new Date(Integer.parseInt(datePieces[0])-1900,Integer.parseInt(datePieces[1])-1,Integer.parseInt(datePieces[2]));
            //System.out.print(date[i-1]);
            open[n-i] = Double.parseDouble(pieces[1]);
            //System.out.print(open[i-1]);
            high[n-i] = Double.parseDouble(pieces[2]);
            //System.out.print(high[i-1]);
            low[n-i] = Double.parseDouble(pieces[3]);
            //System.out.print(low[i-1]);
            close[n-i] = Double.parseDouble(pieces[4]);
            //System.out.print(close[i-1]);
            volume[n-i] = Double.parseDouble(pieces[5]);
            //System.out.println(volume[i-1]);
        }
        return new HighLowDataSet(date, high, low ,open ,close ,volume);
    }
    public static void main(String[] args) {
        int sd = 27;
        int sm = 1;  //month 1 means Feb
        int sy = 2012;
        
    	
    		sd = 26; sm= 2; sy =2012;
    	

    	Calendar fromDate = new GregorianCalendar(sy,sm,sd,0,0);
        Calendar now = Calendar.getInstance();
        int ed = now.get(Calendar.DATE);
        int em = now.get(Calendar.MONTH);
        int ey = now.get(Calendar.YEAR);
        
    	System.out.println(Arrays.toString(createHighLowDatasetByDay("^DJI", sm, sd, sy, em , ed , ey).date));
	}
}