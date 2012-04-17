package data;
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


import java.util.Date;
import java.util.ArrayList;
/**
 *
 * @author Huayi
 */
public class HighLowDataSet {
    public Date[] date = null;
    public double[] high = null;
    public double[] low = null;
    public double[] open = null;
    public double[] close = null;
    public double[] volume = null;

    public double[] getMinMaxVolume(int startIndex , int endIndex){
        double [] ret = new double[2];
        double maxVolume = 0;
        double minVolume = Double.MAX_VALUE;
        for(int i=startIndex;i <= endIndex;i++){
                    if(maxVolume < volume[i]){
                        maxVolume = volume[i];
                    }  
                    if( minVolume > volume[i]){
                        minVolume = volume[i];
                    }  
        }
        ret[0] = minVolume;
        ret[1] = maxVolume;
        return ret;
    }
    public double[] getMinLowAndMaxHigh(int startIndex , int endIndex){
        double [] ret = new double[2];
        double maxHigh = 0;
        double minLow = Double.MAX_VALUE;
        for(int i=startIndex;i <= endIndex;i++){
                    if(maxHigh < high[i]){
                        maxHigh = high[i];
                    }  
                    if( minLow > low[i]){
                        minLow = low[i];
                    }  
        }
        ret[0] = minLow;
        ret[1] = maxHigh;
        return ret;
    }
    public HighLowDataSet(Date[] date, double[] high, double[] low, double[] open,double[] close, double[] volume){
                 this.date = date;
                 this.high = high;
                 this.low = low;
                 this.open = open;
                 this.close = close;
                 this.volume = volume;
                 
    }
    public int getSize(){
        return date.length;
    }
    public Date lastDate(){
        return date[date.length-1];
    }
    public int indexOfDate(Date theDate){
        if(date[0].equals(theDate)) return 0;
        for(int i = 1; i< date.length; i++){
            if(date[i].equals(theDate) || date[i-1].compareTo(theDate)<0 && date[i].compareTo(theDate)>0)return i;
        }
        return -1;
    }
    public String weekendCodesForHighChart(){
    	String ret = "";
    	ArrayList<Date> saturdays = new ArrayList<Date>();
    	ArrayList<Date> sundays = new ArrayList<Date>();
    	for (int i = 0; i < date.length; i++) {
			if(date[i].getDay()==6){
				saturdays.add(date[i]);
				continue;
			}
			if(date[i].getDay()==0){
				sundays.add(date[i]);
				continue;
			}
		}
    	//System.out.println(saturdays);
    	//System.out.println(sundays);
    	return ret;
    }
}
