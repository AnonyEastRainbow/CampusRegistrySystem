/**
 * @description: LeaveApplication__c BeforeInsert, BeforeUpdate trigger handler
 * @author: AnonyEast
 * @date: 2023-04-08
 */
public with sharing class RS_Leave_Before_Hdl implements Triggers.Handler{
    public void handle() {
        try {
            // 更新后的对象
            List<LeaveApplication__c> lstNewLeaveApplication = (List<LeaveApplication__c>)Trigger.new;
            // 更新前的对象
            Map<Id, LeaveApplication__c> mapOldLeaveApplication = (Map<Id, LeaveApplication__c>)Trigger.oldMap;
            // 学生信息赋值、审批人赋值
            setStudentInfoAndApprover(lstNewLeaveApplication);
        } catch (Exception ex) {
            RS_Logger_Cmn.createLog('Leave_BeforeTrg_Exception',ex,'RS_Leave_Before_Hdl.handle');
        }
    }

    /**
     * @description 学生信息赋值、审批人赋值
     * @param lstLeaveApplication 请假申请列表
     */
    public static void setStudentInfoAndApprover(List<LeaveApplication__c> lstLeaveApplication) {
        // 存储OwnerId
        Set<Id> setRecordOwnerId = new Set<Id>();
        // 存储学生Id
        Set<Id> setRecordStudentId = new Set<Id>();
        for (LeaveApplication__c objLeave : lstLeaveApplication) {
            setRecordOwnerId.add(objLeave.OwnerId);
            if (objLeave.Student__c != null){
                setRecordStudentId.add(objLeave.Student__c);
            }
        }
        // 获取Owner的详细信息
        Map<Id,User> mapRecordOwner = RS_SObjectUtil_Cmn.getUserDetailInfoMap(setRecordOwnerId);
        // 获取学生的详细信息
        Map<Id,Contact> mapRecordStudent;
        if (setRecordStudentId.size() > 0) {
            mapRecordStudent = RS_SObjectUtil_Cmn.getContactDetailInfoMap(setRecordStudentId);
        }
        // 获取第三审批人(教务处)
        List<ApproverMapping__c> lstApproverMapping = [
            SELECT 
                Approver__c 
            FROM 
                ApproverMapping__c 
            WHERE 
                Department__c = '教务处' 
                AND Operation__c INCLUDES (:RS_Constants.PICKLIST_OPERATION_LEAVE) 
        ];
        // 学生信息相关字段赋值
        for (LeaveApplication__c objLeave : lstLeaveApplication) {
            // 记录类型：学生请假
            if (objLeave.RecordTypeId == RS_Constants.STUDENT_LEAVE_RECORD_TYPE_ID && mapRecordOwner.get(objLeave.OwnerId) != null) {
                // 学生字段有值时(内部提交)
                if (objLeave.Student__c != null) {
                    Contact objContact = mapRecordStudent.get(objLeave.Student__c);
                    objLeave.StudentNumber__c = objContact.StudentNumber__c;
                    objLeave.Class__c = objContact.Account.Id;
                    objLeave.SecondaryCollege__c = objContact.SecondaryCollege__c;
                    objLeave.Major__c = objContact.Profession__c;
                    // 第一审批人赋值(班主任)
                    objLeave.X1stApprover__c = objContact.Account.Owner.Id;
                    // 第二审批人赋值(二级学院书记)
                    objLeave.X2ndApprover__c = objContact.Account.Parent.Owner.Id;
                }
                // 学生字段值为空时(外部提交)
                if (objLeave.Student__c == null) {
                    User objOwner = mapRecordOwner.get(objLeave.OwnerId);
                    objLeave.Student__c = objOwner.ContactId;
                    objLeave.StudentNumber__c = objOwner.Contact.StudentNumber__c;
                    objLeave.Class__c = objOwner.Contact.Account.Id;
                    objLeave.SecondaryCollege__c = objOwner.Contact.SecondaryCollege__c;
                    objLeave.Major__c = objOwner.Contact.Profession__c;
                    // 第一审批人赋值(班主任)
                    objLeave.X1stApprover__c = objOwner.Contact.Account.Owner.Id;
                    // 第二审批人赋值(二级学院书记)
                    objLeave.X2ndApprover__c = objOwner.Contact.Account.Parent.Owner.Id;
                }
                // 第三审批人赋值(教务处)
                if (lstApproverMapping != null && lstApproverMapping.size() > 0) {
                    objLeave.X3rdApprover__c = lstApproverMapping.get(0).Approver__c;
                }
            }
        }
    }
}