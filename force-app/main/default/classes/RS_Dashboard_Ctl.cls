public with sharing class RS_Dashboard_Ctl {

    @AuraEnabled(cacheable = true)
    public static ResponseResult getTeachingSupplyEachTime(){
        List<AggregateResult> lstTeachingSupply = [
            SELECT 
                WEEK_IN_YEAR(BorrowingStartDateAndTime__c) week, TeachingSupply__c, SUM(Quantity__c) qty 
            FROM 
                TeachingSupplyBorrowingApplication__c 
            GROUP BY 
                WEEK_IN_YEAR(BorrowingStartDateAndTime__c), TeachingSupply__c 
            ORDER BY 
                WEEK_IN_YEAR(BorrowingStartDateAndTime__c) ASC 
        ];
        EchartWrapper objEchart = new EchartWrapper();
        Set<String> setXData = new Set<String>();
        Set<String> setLegend = new Set<String>();
        // 封装X轴坐标、图例
        for(AggregateResult objTeachingSupply : lstTeachingSupply){
            setXData.add(String.valueOf(objTeachingSupply.get('week')));
            setLegend.add(String.valueOf(objTeachingSupply.get('TeachingSupply__c')));
        }
        // 封装系列
        SeriesWrapper objSeries = new SeriesWrapper();
        objSeries.type = 'line';
        for(AggregateResult objTeachingSupply : lstTeachingSupply){
            objSeries.data.add(objTeachingSupply.get('qty'));
        }
        objEchart.series.add(objSeries);
        // 封装X轴参数
        objEchart.xAxis.type = 'category';
        objEchart.xAxis.data = new List<String>(setXData);
        ResponseResult objResponse = new ResponseResult();
        objResponse.status = 'OK';
        objResponse.data = objEchart;
        return objResponse;
    }

    public class EchartWrapper {
        @AuraEnabled public List<String> legend;
        @AuraEnabled public List<SeriesWrapper> series;
        @AuraEnabled public XAxisWrapper xAxis;

        public EchartWrapper(){
            this.series = new List<SeriesWrapper>();
            this.xAxis = new XAxisWrapper();
        }
    }

    public class SeriesWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String type;
        @AuraEnabled public String stack;
        @AuraEnabled public List<Object> data;

        public SeriesWrapper(){
            this.data = new List<Object>();
        }
    }

    public class XAxisWrapper {
        @AuraEnabled public String type;
        @AuraEnabled public String boundaryGap;
        @AuraEnabled public List<Object> data;

        public XAxisWrapper(){
            this.data = new List<Object>();
        }
    }

    public class ResponseResult {
        @AuraEnabled public String status;
        @AuraEnabled public String message;
        @AuraEnabled public Object data;
    }
}