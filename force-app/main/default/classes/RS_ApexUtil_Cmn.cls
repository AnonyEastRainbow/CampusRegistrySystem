/**
 * @description Apex工具类
 * @author: AnonyEast
 * @date: 2023-03-28
 */
public with sharing class RS_ApexUtil_Cmn {
    /**
     * @description 获取字段的Picklist中每个值的描述
     * @param sObjectName 对象名
     * @param fieldName 字段名
     * 
     * @return mapPicklistDescribe
     */
    public static Map<String, Object> getPicklistDescribe(String sObjectName, String fieldName){
        Map<String, Object> mapPicklistDescribe = new Map<String, Object>();
        Map<String, Schema.SObjectType> mapSObjectDescribe = Schema.getGlobalDescribe();
        if (mapSObjectDescribe.containsKey(sObjectName)) {
            Map<String, Schema.SobjectField> mapSObjectFields = mapSObjectDescribe.get(sObjectName).getDescribe().fields.getMap();
            if (mapSObjectFields.containsKey(fieldName)) {
                Schema.DescribeFieldResult sObjectFieldDescribe = mapSObjectFields.get(fieldName).getDescribe();
                List<Schema.PicklistEntry> lstFieldPicklistEntry = sObjectFieldDescribe.getPicklistValues();
                for (Schema.PicklistEntry fieldPicklistEntry : lstFieldPicklistEntry) {
                    mapPicklistDescribe.put(fieldPicklistEntry.getValue(), new Map<String,Object>{
                        'value' => fieldPicklistEntry.getValue(),
                        'isActive' => fieldPicklistEntry.isActive(),
                        'isDefaultValue' => fieldPicklistEntry.isDefaultValue(),
                        'label' => fieldPicklistEntry.getLabel()
                    });
                }
            } else {
                // 字段不存在
                return null;
            }
        } else {
            // 对象不存在
            return null;
        }
        return mapPicklistDescribe;
    }

    /**
     * @description Picklist字段值转换为Label
     * @param strPicklistValue Picklist字段值
     * @param mapPicklistDescribe Picklist描述
     * 
     * @return Picklist字段值转换为Label的值
     */
    public static String picklistValueToLabel(String strPicklistValue, Map<String, Object> mapPicklistDescribe){
        String strPicklistLabel;
        Map<String,Object> mapPicklistValueDescribe = (Map<String,Object>)mapPicklistDescribe.get(strPicklistValue);
        if (mapPicklistValueDescribe != null && mapPicklistValueDescribe.keySet().size() > 0) {
            strPicklistLabel = (String)mapPicklistValueDescribe.get('label');
        }
        if (strPicklistLabel != null && strPicklistLabel.length() > 0) {
            return strPicklistLabel;
        }else{
            return strPicklistValue;
        }
    }

    /**
     * @description 对象转为Map
     * @param objInstance 对象实例
     * 
     * @return 对象实例的字段名与值的映射
     */
    public static Map<String, Object> objectToMap(Object objInstance){
        return (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(objInstance));
    }

    /**
     * @description List<Object>转为List<Map>
     * @param lstInstance 对象实例列表
     * 
     * @return 对象实例的字段名与值的映射的列表
     */
    public static List<Map<String, Object>> objectToMap(List<Object> lstInstance){
        List<Map<String, Object>> lstObjectToMap = new List<Map<String, Object>>();
        for (Object objInstance : lstInstance) {
            lstObjectToMap.add(objectToMap(objInstance));
        }
        return lstObjectToMap;
    }

    /**
     * @description Datatime转为String
     * @param datetimeInstance Datetime实例
     * 
     * @return 格式化后的时间
     */
    public static String datetimeToString(Datetime datetimeInstance, String strFormat){
        return datetimeInstance.format('yyyy/MM/dd HH:mm','Asia/Shanghai');
    }

    public static String datetimeToString(Datetime datetimeInstance){
        return datetimeToString(datetimeInstance,'yyyy/MM/dd HH:mm');
    }

    /**
     * @description 当前用户时区的日期(Date)转换为GMT时间(Datetime)
     * @param dateInstance 要转换的Date实例
     * 
     * @return GMT时间
     */
    public static Datetime localDateToGmtDatetime(Date dateInstance){
        // 设置时间值为00:00:00
        Time timeInstance = Time.newInstance(0, 0, 0, 0);
        // 以本地时区返回GMT时间(参数为本地时区)
        return Datetime.newInstance(dateInstance, timeInstance);
    }

    /**
     * @description 当前用户时区的时间(Datetime)转换为GMT时间(Datetime)
     * @param datetimeInstance 要转换的Datetime实例
     * 
     * @return GMT时间
     */
    public static Datetime localDatetimeToGmtDatetime(Datetime datetimeInstance){
        // 当前用户时区
        TimeZone localTimeZone = UserInfo.getTimeZone();
        // 将本地时间转换为GMT时间
        Datetime gmtDatetime = datetimeInstance.addSeconds(-localTimeZone.getOffset(datetimeInstance) / 1000);
        return gmtDatetime;
    }
}