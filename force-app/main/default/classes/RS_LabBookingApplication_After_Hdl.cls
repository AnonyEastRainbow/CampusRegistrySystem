/**
 * @description: LabBookingApplication__c AfterInsert, AfterUpdate trigger handler
 * @author: AnonyEast
 * @date: 2023-04-07
 */
public with sharing class RS_LabBookingApplication_After_Hdl implements Triggers.Handler{
    public void handle() {
        try {
            // 更新后的对象
            List<LabBookingApplication__c> lstNewBookingApplication = (List<LabBookingApplication__c>)Trigger.new;
            // 更新前的对象
            Map<Id, LabBookingApplication__c> mapOldBookingApplication = (Map<Id, LabBookingApplication__c>)Trigger.oldMap;
            // 存储审批通过的对象
            List<LabBookingApplication__c> lstApprovedBookingApplication = new List<LabBookingApplication__c>();
            // 存储审批驳回的对象
            List<LabBookingApplication__c> lstRejectedBookingApplication = new List<LabBookingApplication__c>();
            // 判断审批状态
            for (LabBookingApplication__c objBookingApplication : lstNewBookingApplication) {
                // 获取更新前的审批状态
                String strOldStatus = mapOldBookingApplication.get(objBookingApplication.Id).ApprovalStatus__c;
                // 审批通过
                if (objBookingApplication.ApprovalStatus__c == RS_Constants.PICKLIST_APPROVAL_STATUS_APPROVED && strOldStatus != objBookingApplication.ApprovalStatus__c) {
                    lstApprovedBookingApplication.add(objBookingApplication);
                }
                // 审批驳回
                else if (objBookingApplication.ApprovalStatus__c == RS_Constants.PICKLIST_APPROVAL_STATUS_REJECTED && strOldStatus != objBookingApplication.ApprovalStatus__c) {
                    lstRejectedBookingApplication.add(objBookingApplication);
                }
            }
            if (!lstApprovedBookingApplication.isEmpty()) {
                // 执行审批通过的动作
                approvedBookingApplicationAction(lstApprovedBookingApplication);
            }
            if (!lstRejectedBookingApplication.isEmpty()) {
                // 执行审批驳回的动作
                rejectedBookingApplicationAction(lstRejectedBookingApplication);
            }
        } catch (Exception ex) {
            RS_Logger_Cmn.createLog('TeachingSupply_AfterTrg_Exception',ex,'RS_TeachingSupply_After_Hdl.handle');
        }
    }

    /**
     * @description 教学物品借用申请审批通过后的动作
     * @param lstLabBookingApplication 审批通过的教学物品借用申请记录
     */
    public static void approvedBookingApplicationAction(List<LabBookingApplication__c> lstLabBookingApplication){
        // 发送审批成功邮件
        // 获取邮件模板
        EmailTemplate objTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'LabBookingApplicationApprovalResultNotification_Approved' LIMIT 1];
        // 获取审批人、审批状态和备注
        Map<Id, LabBookingApplication__c> mapLabBookingApplication = new Map<Id,LabBookingApplication__c>(lstLabBookingApplication);
        Map<Id, List<RS_ApprovalProcess_Cmn.ApprovalStepDetail>> mapApprovalStepDetailsByTargetObjIds = RS_ApprovalProcess_Cmn.getApprovalStepDetail(mapLabBookingApplication);
        // 发送邮件
        sendEmail(lstLabBookingApplication, mapApprovalStepDetailsByTargetObjIds, objTemplate.Id);
    }

    /**
     * @description 教学物品借用申请审批拒绝后的动作
     * @param lstLabBookingApplication 审批拒绝的教学物品借用申请记录
     */
    public static void rejectedBookingApplicationAction(List<LabBookingApplication__c> lstLabBookingApplication){
        // 发生审批失败邮件
        // 获取邮件模板
        EmailTemplate objTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'LabBookingApplicationApprovalResultNotification_Rejected' LIMIT 1];
        // 获取审批人、审批状态和备注
        Map<Id, LabBookingApplication__c> mapLabBookingApplication = new Map<Id,LabBookingApplication__c>(lstLabBookingApplication);
        Map<Id, List<RS_ApprovalProcess_Cmn.ApprovalStepDetail>> mapApprovalStepDetailsByTargetObjIds = RS_ApprovalProcess_Cmn.getApprovalStepDetail(mapLabBookingApplication);
        // 发送邮件
        sendEmail(lstLabBookingApplication, mapApprovalStepDetailsByTargetObjIds, objTemplate.Id);
    }

    /**
     * @description 发送邮件通知
     * @param lstBookingApplication: 教学用品借用申请申请记录
     * @param mapApprovalStepDetailsByTargetObjIds: 目标对象id与审批详情映射
     * @param idTemplate: 邮件模板Id
     */
    public static void sendEmail(List<LabBookingApplication__c> lstBookingApplication, Map<Id, List<RS_ApprovalProcess_Cmn.ApprovalStepDetail>> mapApprovalStepDetailsByTargetObjIds, Id idTemplate){
        // 将需要用到的父对象信息存储到变量
        lstBookingApplication = [SELECT CreatedBy.Email, CreatedBy.Name FROM LabBookingApplication__c WHERE Id IN :lstBookingApplication];
        // 获取发件人地址
        OrgWideEmailAddress objFromAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :Label.RS_EmailFromAddress LIMIT 1];
        // 存储要发送的邮件
        List<Messaging.SingleEmailMessage> lstMailToSend = new List<Messaging.SingleEmailMessage>();
        // 准备要发送的邮件
        for (LabBookingApplication__c objBookingApplication : lstBookingApplication) {
            // 使用邮件模板
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate((String) idTemplate, null, objBookingApplication.Id);
            // 获取审批详情
            List<RS_ApprovalProcess_Cmn.ApprovalStepDetail> lstApprovalStepDetails = mapApprovalStepDetailsByTargetObjIds.get(objBookingApplication.Id);
            String strApprovalStepDetails = '';
            if (lstApprovalStepDetails != null && lstApprovalStepDetails.size() > 0) {
                for (RS_ApprovalProcess_Cmn.ApprovalStepDetail approvalStepDetail : lstApprovalStepDetails) {
                    strApprovalStepDetails += approvalStepDetail.createdTime + ' ';
                    strApprovalStepDetails += approvalStepDetail.approver + ': ';
                    strApprovalStepDetails += approvalStepDetail.status + '，留言:';
                    if (approvalStepDetail.comments == null) {
                        strApprovalStepDetails += '无';
                    }else{
                        strApprovalStepDetails += approvalStepDetail.comments;
                    }
                    strApprovalStepDetails += '\n';
                }
            }
            System.debug('strApprovalStepDetails -> ' + strApprovalStepDetails);
            // 将批准详情添加到正文
            String strTextBody = mail.getPlainTextBody();
            System.debug('mailOldPlainTextBody -> ' + strTextBody);
            strTextBody = strTextBody.replace('{ApprovalDetail}', strApprovalStepDetails);
            mail.setPlainTextBody(strTextBody);
            System.debug('mailNewPlainTextBody -> ' + strTextBody);
            // 设置发件人地址
            mail.setOrgWideEmailAddressId(objFromAddress.Id);
            // 设置收件人地址
            List<String> lstToAddresses = new List<String>();
            lstToAddresses.add(objBookingApplication.CreatedBy.Email);
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