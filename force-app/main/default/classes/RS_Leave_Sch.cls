/**
 * @description: LeaveApplication__c Scheduler
 * @author: AnonyEast
 * @date: 2023-06-13
 */
public with sharing class RS_Leave_Sch implements Schedulable {
    private String strAction;

    public RS_Leave_Sch(String strAction){
        this.strAction = strAction;
    }

    public void execute(SchedulableContext sc) {
        if ('notify' == strAction) {
            List<TeachingSupplyBorrowingApplication__c> lstTimeoutUnreturnedApplication = notifyTimeoutUnreturned();
            String strDingtalkMsg = '已对超时未归还的用户发送电子邮件通知。\n';
            strDingtalkMsg += '总条数：' + lstTimeoutUnreturnedApplication.size() + '。\n';
            RS_TeachingSupply_Pst.sendDingtalkNotice(strDingtalkMsg, null);
        }
    }

    /**
     * @description 邮件通知超时未归还的用户
     */
    public List<TeachingSupplyBorrowingApplication__c> notifyTimeoutUnreturned(){
        Datetime datetimeNow = Datetime.now();
        String strQuery = ''; 
        strQuery += 'SELECT ';
        strQuery +=     'Id, IsNotified__c, IsReturned__c, ApprovalStatus__c, IsBorrowed__c, BorrowingEndDateAndTime__c ';
        strQuery += 'FROM ';
        strQuery +=     'TeachingSupplyBorrowingApplication__c ';
        strQuery += 'WHERE ';
        strQuery +=     'ApprovalStatus__c = \'Approved\' ';
        strQuery +=     'AND IsBorrowed__c = true ';
        strQuery +=     'AND IsReturned__c = false ';
        strQuery +=     'AND BorrowingEndDateAndTime__c < :datetimeNow ';
        strQuery +=     'AND IsNotified__c = false ';
        List<TeachingSupplyBorrowingApplication__c> lstBorrowingTimeoutUnreturned = Database.query(strQuery);
        sendEmail(lstBorrowingTimeoutUnreturned);
        // 更新通知状态
        for (TeachingSupplyBorrowingApplication__c objBorrowing : lstBorrowingTimeoutUnreturned) {
            objBorrowing.IsNotified__c = true;
        }
        update lstBorrowingTimeoutUnreturned;
        return lstBorrowingTimeoutUnreturned;
    }

    /**
     * @description 发送邮件通知
     * @param lstLeaveApplication: 超时未归还的教学用品借用申请
     */
    public void sendEmail(List<TeachingSupplyBorrowingApplication__c> lstBorrowingApplication){
        // 将需要用到的父对象信息存储到变量
        lstBorrowingApplication = [SELECT Id, Owner.Email FROM TeachingSupplyBorrowingApplication__c WHERE Id IN :lstBorrowingApplication];
        // 获取电子邮件模板
        EmailTemplate objTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'TeachingSupplyBorrowingApplicationReturnNotification' LIMIT 1];
        // 获取发件人地址
        OrgWideEmailAddress objFromAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :Label.RS_EmailFromAddress LIMIT 1];
        // 存储要发送的邮件
        List<Messaging.SingleEmailMessage> lstMailToSend = new List<Messaging.SingleEmailMessage>();
        // 准备要发送的邮件
        for (TeachingSupplyBorrowingApplication__c objBorrowing : lstBorrowingApplication) {
            // 使用邮件模板
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(objTemplate.Id, null, objBorrowing.Id);
            // 设置发件人地址
            mail.setOrgWideEmailAddressId(objFromAddress.Id);
            // 设置收件人地址
            List<String> lstToAddresses = new List<String>();
            lstToAddresses.add(objBorrowing.Owner.Email);
            mail.setToAddresses(lstToAddresses);
            // 设置该邮件不要被保存为一个活动
            mail.setSaveAsActivity(false);
            // 添加发送邮件列表
            lstMailToSend.add(mail);
        }
        // 发送邮件
        Messaging.sendEmail(lstMailToSend);
    }
}