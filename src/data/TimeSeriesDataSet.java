package data;

import java.util.Date;

public class TimeSeriesDataSet {
    public Date[] date = null;
    public double[] jci = null; //job creation index
    public double[] eci = null; //economy creation index
    public TimeSeriesDataSet(Date[] date, double[] jci, double[] eci){
        this.date = date;
        this.jci = jci;
        this.eci = eci;
    }
    public int getSize(){
        return date.length;
    }
}
