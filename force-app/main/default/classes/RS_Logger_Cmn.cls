/**
 * @description 日志公共类
 * @author: AnonyEast
 * @date: 2023-01-07
 */
public without sharing class RS_Logger_Cmn {
    /**
     * @description 创建日志
     * @param strSubject: 日志主题
     * @param strMessage: 日志内容
     * @param strReference: 日志来源
     * @return void
     */
    public static void createLog(String strSubject,String strMessage,String strReference) {
        Log__c objLog = new Log__c(LogSubject__c = strSubject, LogMessage__c = strMessage, Reference__c = strReference);
        insert objLog;
    }

    /**
     * @description 创建异常日志
     * @param strSubject: 日志主题
     * @param objEx: 异常对象
     * @param strReference: 日志来源
     * @return void
     */
    public static void createLog(String strSubject,Exception objEx,String strReference) {
        String strExceptionMessage = objEx.getMessage();
        String strExceptionType = objEx.getTypeName();
        Integer strExceptionLine = objEx.getLineNumber();
        String strExceptionStackTrace = objEx.getStackTraceString();
        String strMessage = 'ExceptionMessage: ' + strExceptionMessage + '\n'
        + 'ExceptionType: ' + strExceptionType + '\n'
        + 'ExceptionLine: ' + strExceptionLine + '\n'
        + 'ExceptionStackTrace: \n' + strExceptionStackTrace;
        Log__c objLog = new Log__c(LogSubject__c = strSubject, LogMessage__c = strMessage, Reference__c = strReference);
        insert objLog;
    }
}