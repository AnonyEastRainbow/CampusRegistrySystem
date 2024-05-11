/**
 * 
 */
public with sharing class RS_AnonymousApexExecute {
    public static void main_031301(){
        List<TeachingSupplyBorrowingApplication__c> lstBorrowingApplication = [
            SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, BorrowingStartDate__c, ClassRoom__c, Phone__c, Quantity__c, IsReturned__c, Borrower__c, SecondaryCollegeLookup__c, Remark__c, Location__c, ApprovalStatus__c, IsBorrowed__c, BorrowingEndDate__c, BorrowingStartClassTimes__c, BorrowingEndClassTimes__c, BorrowingStartDateAndTime__c, BorrowingEndDateAndTime__c, TeachingSupply__c 
            FROM TeachingSupplyBorrowingApplication__c
            WHERE Id = 'a0F5i00000BFNmlEAH'
        ];
        RS_TeachingSupply_Before_Hdl.setBorrowingStartAndEndDatetime(lstBorrowingApplication);
        for (TeachingSupplyBorrowingApplication__c objBorrowingApplication : lstBorrowingApplication) {
            System.debug('objBorrowingApplication.BorrowingStartDateAndTime__c -> ' + objBorrowingApplication.BorrowingStartDateAndTime__c);
            System.debug('objBorrowingApplication.BorrowingEndDateAndTime__c -> ' + objBorrowingApplication.BorrowingEndDateAndTime__c);
        }
    }

    public static void main_031701(){
        List<TeachingSupplyBorrowingApplication__c> lstBorrowingApplication = [
            SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, BorrowingStartDate__c, ClassRoom__c, Phone__c, Quantity__c, IsReturned__c, Borrower__c, SecondaryCollegeLookup__c, Remark__c, Location__c, ApprovalStatus__c, IsBorrowed__c, BorrowingEndDate__c, ReceiveAddress__c, BorrowingStartClassTimes__c, BorrowingEndClassTimes__c, BorrowingStartDateAndTime__c, BorrowingEndDateAndTime__c, TeachingSupply__c, ReceiveContact__c, ReceiveContactPhone__c, ReturnAddress__c, ReturnContact__c, ReturnContactPhone__c 
            FROM TeachingSupplyBorrowingApplication__c
            WHERE Id = 'a0F5i00000BFUMVEA5'
        ];
        RS_TeachingSupply_Before_Hdl.setReceiveAndReutrnContact(lstBorrowingApplication);
        for (TeachingSupplyBorrowingApplication__c objBorrowingApplication : lstBorrowingApplication) {
            System.debug('objBorrowing.Id -> ' + objBorrowingApplication.Id);
            System.debug('objBorrowing.ReceiveContact__c -> ' + objBorrowingApplication.ReceiveContact__c);
            System.debug('objBorrowing.ReceiveContactPhone__c -> ' + objBorrowingApplication.ReceiveContactPhone__c);
            System.debug('objBorrowing.ReceiveAddress__c -> ' + objBorrowingApplication.ReceiveAddress__c);
            System.debug('objBorrowing.ReturnContact__c -> ' + objBorrowingApplication.ReturnContact__c);
            System.debug('objBorrowing.ReturnContactPhone__c -> ' + objBorrowingApplication.ReturnContactPhone__c);
            System.debug('objBorrowing.ReturnAddress__c -> ' + objBorrowingApplication.ReturnAddress__c);
        }
    }

    public static void main_230328_01(){
        Map<String, Object> mapPicklistValues = RS_ApexUtil_Cmn.getPicklistDescribe('LabBooking__c', 'Location__c');
        System.debug('mapPicklistValues -> ' + mapPicklistValues);
    }

    public static void main_230328_02(){
        Map<String, Object> mapPicklistDescribe = RS_ApexUtil_Cmn.getPicklistDescribe('LabBookingApplication__c', 'ApprovalStatus__c');
        System.debug('mapPicklistDescribe -> ' + mapPicklistDescribe);
    }

    public static void main_230331(){
        RS_LabBooking_Ctl.bookingRequest('a005i00000B3p3YAAR');
    }

    public static void main_230405(){
        List<LabBookingApplication__c> lstLabBookingApplication = [SELECT Id, Name, RecordTypeId, CreatedById, LastModifiedById, BookedLab__c, Location__c, LabAddress__c, X1stApprover__c FROM LabBookingApplication__c];
        RS_LabBookingApplication_Before_Hdl.setApprover(lstLabBookingApplication);
    }

    public static void main_230429(){
        RS_DataPrepare_Tmp.updateLeaveApplicationLookup();
    }

    public static void main_230610(){
        RS_ResponseResult res = RS_Leave_Ctl.getApprovalSteps('a0J5i00000B32u1EAB');
        System.debug('Res -> ' + res);
    }

    public static void main_230613(){
        RS_Leave_Sch objLeaveScheduler = new RS_Leave_Sch('notify');
        String sch = '0 0 22 * * ?';
        String jobID = System.schedule('邮件通知超时未归还的教学用品借用申请', sch, objLeaveScheduler);
    }

    public static void main_230624(){
        List<String> lstAtPhone = new List<String>();
        lstAtPhone.add('123');
        RS_TeachingSupply_Pst.sendDingtalkNotice('测试一条消息', lstAtPhone);
    }

    public static void main_230625(){
        RS_Leave_Sch objLeaveScheduler = new RS_Leave_Sch('notify');
        List<TeachingSupplyBorrowingApplication__c> lstTimeoutUnreturnedApplication = objLeaveScheduler.notifyTimeoutUnreturned();
        String strDingtalkMsg = '已对超时未归还的用户发送电子邮件通知。\n';
        strDingtalkMsg += '总条数：' + lstTimeoutUnreturnedApplication.size() + '条';
        RS_TeachingSupply_Pst.sendDingtalkNotice(strDingtalkMsg, null);
    }

    public static void main_230701(){
        Date dateInstance = Date.newInstance(2023, 7, 1);
        Datetime gmtDatetime = RS_ApexUtil_Cmn.localDateToGmtDatetime(dateInstance);
        System.debug('dateInstance -> ' + dateInstance);
        System.debug('gmtDatetime -> ' + gmtDatetime);
    }

    public static void execute(){
        RS_AnonymousApexExecute.main_230701();
    }
}