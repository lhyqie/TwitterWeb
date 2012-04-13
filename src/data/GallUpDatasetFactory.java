package data;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

public class GallUpDatasetFactory {
    static String url = "http://www.gallup.com/viz/v1/csv/8386b935-9a6b-4a07-ae74-78e02ac52871/POLLFLEXCHARTVIZ/ECONINDEX122840.aspx";
    static SimpleDateFormat formatter = new SimpleDateFormat("yyyy/MM/dd");
    public GallUpDatasetFactory(){
           
    }
    public static TimeSeriesDataSet createHighLowDatasetByDay(int sm, int sd, int sy){
        LinkedList<String> dataLines = new LinkedList<String>();
        int correct_order = 0;  // 1 correct , -1 incorrect, 0 uninitialized
        // 1. read data from yahoo
        try {
            //System.out.println(url);
            URL gallupURL = new URL(url);
            URLConnection conn = gallupURL.openConnection();
            BufferedReader in = new BufferedReader(
                                new InputStreamReader(
                                conn.getInputStream()));
            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                //System.out.println(inputLine);
            	if(inputLine.length() <=0 || !Character.isDigit(inputLine.charAt(0)) ) continue;
                dataLines.add(inputLine);
            }
            in.close();
        } catch (Exception ex) {
            System.err.println("netword problem: fail to connect to Gallup");
        }
        
        int n = dataLines.size();
        if( n <=0 ) return null;
        // 
        Date[] date = new Date[n];
        double[] jci = new double[n];
        double[] eci = new double[n];
        
        for(int i = 0; i < n ; i++){

            String pieces[] = dataLines.get(i).split(",");
            //count the # of / in pieces[0]
            int cnt_of_slash = 0;
            for (int j = 0; j < pieces[0].length(); j++) {
				if(pieces[0].charAt(j)=='/') cnt_of_slash++;
			}
            String year = "", month = "", day = "";
            if(cnt_of_slash == 2){  // for example 02/3-5/2008
            	int index1 = pieces[0].indexOf("/");
            	month = pieces[0].substring(0,index1);
            	int index2 = pieces[0].indexOf("-");
            	int index3 = pieces[0].lastIndexOf("/");
            	day = pieces[0].substring(index2+1, index3);
            	year = pieces[0].substring(index3+1);
            }else if(cnt_of_slash ==3){ // for example 02/29-03/2/2008
            	int index2 = pieces[0].indexOf("-");
            	String dateString = pieces[0].substring(index2+1);
            	String datePieces[] = dateString.split("/");
            	month = datePieces[0];
            	day = datePieces[1];
            	year = datePieces[2];
            }else if(cnt_of_slash == 4){ // for example 12/28/2008-01/2/2009
            	int index2 = pieces[0].indexOf("-");
            	String dateString = pieces[0].substring(index2+1);
            	String datePieces[] = dateString.split("/");
            	month = datePieces[0];
            	day = datePieces[1];
            	year = datePieces[2];
            }
            else {
            	System.err.println("date not correct resolved in Gallup streaming data!!!!!");
            	continue;
            }
            /*
             *  here is very tricky, the data from gallup is inconsistent
             *  even the tab is Date, jci, eci
             *  sometimes the data is Date, eci, jci
             *  running the program at different time yields different order of column
             *  How to solve it:  ground truth is 01/2-4/2008 jci = 27.0000 eci= -23
             *  define a flag correct_order = 0;
             */
            
            try {
				date[i] = formatter.parse(year+"/"+month+"/"+day);
			} catch (ParseException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            
            if(correct_order == 0){
            	if(date[i].getYear()==2008-1900 && date[i].getMonth()==0 && date[i].getDate()==4){
              		if( Double.parseDouble(pieces[1]) > Double.parseDouble(pieces[2])) {
            			correct_order = 1;
            		}else{
            			correct_order = -1;
            		}
            	}
            }
            if(correct_order == 1){
            	jci[i] = Double.parseDouble(pieces[1]);
                eci[i] = Double.parseDouble(pieces[2]);
            }else if(correct_order == -1){
            	jci[i] = Double.parseDouble(pieces[2]);
                eci[i] = Double.parseDouble(pieces[1]);
            }else{
            	System.err.println("correct order of columns of data is not resolved!!!");
            	continue;
            }
            
            //System.out.println(dataLines.get(i));
            //System.out.println("year="+ year +", month="+ month +", day="+day +", jci="+jci[i]+" ,eci="+eci[i]); 
            //System.out.println(date[i]);
            //System.out.println();
            
        }
        System.out.println("correct_order="+correct_order);
        
        Date start = null;
        try {
			start = formatter.parse(sy+"/"+sm+"/"+sd);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
        int indexOfDate = -1;
        for (int i = 0; i < date.length; i++) {
        	//System.out.println(date[i]);
        	if(date[i].equals(start)){
        		indexOfDate = i;
        	}
		}
        if(indexOfDate > 0) {
        	date = Arrays.copyOfRange(date, indexOfDate, date.length);
        	jci = Arrays.copyOfRange(jci, indexOfDate, jci.length);
        	eci = Arrays.copyOfRange(eci, indexOfDate, eci.length);
        }
        
        //System.out.println(Arrays.toString(date));
        //System.out.println(Arrays.toString(jci));
        //System.out.println(Arrays.toString(eci));
        
        return new TimeSeriesDataSet(date, jci, eci);
    }
    public static void main(String[] args) {
    	GallUpDatasetFactory.createHighLowDatasetByDay(3, 12, 2012);
    }
}
