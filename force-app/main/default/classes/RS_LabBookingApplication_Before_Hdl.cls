/**
 * @description: LabBookingApplication__c BeforeInsert, BeforeUpdate trigger handler
 * @author: AnonyEast
 * @date: 2023-04-05
 */
public with sharing class RS_LabBookingApplication_Before_Hdl implements Triggers.Handler {
    public void handle() {
        try {
            // 更新后的对象
            List<LabBookingApplication__c> lstNewLabBookingApplication = (List<LabBookingApplication__c>)Trigger.new;
            // 更新前的对象
            Map<Id, LabBookingApplication__c> mapOldLabBookingApplication = (Map<Id, LabBookingApplication__c>)Trigger.oldMap;
            // 审批人赋值
            setApprover(lstNewLabBookingApplication);
        } catch (Exception ex) {
            RS_Logger_Cmn.createLog('LabBookingApplication_BeforeTrg_Exception',ex,'RS_LabBookingApplication_Before_Hdl.handle');
        }
    }

    /**
     * @description 审批人字段赋值
     * @param lstLabBookingApplication 实验室借用申请实例列表
     */
    public static void setApprover(List<LabBookingApplication__c> lstLabBookingApplication) {
        // 获取需要批准的实验室审批人
        Map<Id, LabBooking__c> mapLabBooking = new Map<Id, LabBooking__c>([
            SELECT 
                Id, IsApprovalRequired__c, X1stApprover__c 
            FROM 
                LabBooking__c 
            WHERE 
                IsApprovalRequired__c = true  
        ]);
        // 审批人赋值
        for (LabBookingApplication__c objLabBookingApplication : lstLabBookingApplication) {
            if (mapLabBooking.get(objLabBookingApplication.BookedLab__c) != null) {
                LabBooking__c objLabBooking = mapLabBooking.get(objLabBookingApplication.BookedLab__c);
                objLabBookingApplication.X1stApprover__c = objLabBooking.X1stApprover__c;
            }
        }
    }
}