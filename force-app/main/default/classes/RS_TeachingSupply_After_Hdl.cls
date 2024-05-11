/**
 * @description: TeachingSupplyBorrowingApplication__c AfterInsert, AfterUpdate trigger handler
 * @author: AnonyEast
 * @date: 2023-03-14
 */
public with sharing class RS_TeachingSupply_After_Hdl implements Triggers.Handler {
    public void handle() {
        try {
            // 更新后的对象
            List<TeachingSupplyBorrowingApplication__c> lstNewBorrowingApplication = (List<TeachingSupplyBorrowingApplication__c>)Trigger.new;
            // 更新前的对象
            Map<Id, TeachingSupplyBorrowingApplication__c> mapOldBorrowingApplication = (Map<Id, TeachingSupplyBorrowingApplication__c>)Trigger.oldMap;
            // 存储审批通过的对象
            List<TeachingSupplyBorrowingApplication__c> lstApprovedBorrowingApplication = new List<TeachingSupplyBorrowingApplication__c>();
            // 存储审批驳回的对象
            List<TeachingSupplyBorrowingApplication__c> lstRejectedBorrowingApplication = new List<TeachingSupplyBorrowingApplication__c>();
            // 判断审批状态
            for (TeachingSupplyBorrowingApplication__c objBorrowing : lstNewBorrowingApplication) {
                // 获取更新前的审批状态
                String strOldStatus = mapOldBorrowingApplication.get(objBorrowing.Id).ApprovalStatus__c;
                // 审批通过
                if (objBorrowing.ApprovalStatus__c == RS_Constants.PICKLIST_APPROVAL_STATUS_APPROVED && strOldStatus != objBorrowing.ApprovalStatus__c) {
                    lstApprovedBorrowingApplication.add(objBorrowing);
                }
                // 审批驳回
                else if (objBorrowing.ApprovalStatus__c == RS_Constants.PICKLIST_APPROVAL_STATUS_REJECTED && strOldStatus != objBorrowing.ApprovalStatus__c) {
                    lstRejectedBorrowingApplication.add(objBorrowing);
                }
            }
            if (!lstApprovedBorrowingApplication.isEmpty()) {
                // 执行审批通过的动作
                approvedBorrowingApplicationAction(lstApprovedBorrowingApplication);
            }
            if (!lstRejectedBorrowingApplication.isEmpty()) {
                // 执行审批驳回的动作
                rejectedBorrowingApplicationAction(lstRejectedBorrowingApplication);
            }
        } catch (Exception ex) {
            RS_Logger_Cmn.createLog('TeachingSupply_AfterTrg_Exception',ex,'RS_TeachingSupply_After_Hdl.handle');
        }
    }

    /**
     * @description 教学物品借用申请审批通过后的动作
     * @param lstBorrowingApplication 审批通过的教学物品借用申请记录
     */
    public static void approvedBorrowingApplicationAction(List<TeachingSupplyBorrowingApplication__c> lstBorrowingApplication){
        // 发送审批成功邮件
        // 获取邮件模板
        EmailTemplate objTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'TeachingSupplyBorrowingApplicationApprovalResultNotification_Approved' LIMIT 1];
        // 获取审批人、审批状态和备注
        Map<Id, TeachingSupplyBorrowingApplication__c> mapBorrowingApplication = new Map<Id,TeachingSupplyBorrowingApplication__c>(lstBorrowingApplication);
        Map<Id, List<RS_ApprovalProcess_Cmn.ApprovalStepDetail>> mapApprovalStepDetailsByTargetObjIds = RS_ApprovalProcess_Cmn.getApprovalStepDetail(mapBorrowingApplication);
        // 发送邮件
        sendEmail(lstBorrowingApplication, mapApprovalStepDetailsByTargetObjIds, objTemplate.Id);
    }

    /**
     * @description 教学物品借用申请审批拒绝后的动作
     * @param lstBorrowingApplication 审批拒绝的教学物品借用申请记录
     */
    public static void rejectedBorrowingApplicationAction(List<TeachingSupplyBorrowingApplication__c> lstBorrowingApplication){
        // 发生审批失败邮件
        // 获取邮件模板
        EmailTemplate objTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'TeachingSupplyBorrowingApplicationApprovalResultNotification_Rejected' LIMIT 1];
        // 获取审批人、审批状态和备注
        Map<Id, TeachingSupplyBorrowingApplication__c> mapBorrowingApplication = new Map<Id,TeachingSupplyBorrowingApplication__c>(lstBorrowingApplication);
        Map<Id, List<RS_ApprovalProcess_Cmn.ApprovalStepDetail>> mapApprovalStepDetailsByTargetObjIds = RS_ApprovalProcess_Cmn.getApprovalStepDetail(mapBorrowingApplication);
        // 发送邮件
        sendEmail(lstBorrowingApplication, mapApprovalStepDetailsByTargetObjIds, objTemplate.Id);
    }

    /**
     * @description 发送邮件通知
     * @param lstBorrowingApplication: 教学用品借用申请申请记录
     * @param mapApprovalStepDetailsByTargetObjIds: 目标对象id与审批详情映射
     * @param idTemplate: 邮件模板Id
     */
    public static void sendEmail(List<TeachingSupplyBorrowingApplication__c> lstBorrowingApplication, Map<Id, List<RS_ApprovalProcess_Cmn.ApprovalStepDetail>> mapApprovalStepDetailsByTargetObjIds, Id idTemplate){
        // 将需要用到的父对象信息存储到变量
        lstBorrowingApplication = [SELECT CreatedBy.Email, CreatedBy.Name FROM TeachingSupplyBorrowingApplication__c WHERE Id IN :lstBorrowingApplication];
        // 获取发件人地址
        OrgWideEmailAddress objFromAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :Label.RS_EmailFromAddress LIMIT 1];
        // 存储要发送的邮件
        List<Messaging.SingleEmailMessage> lstMailToSend = new List<Messaging.SingleEmailMessage>();
        // 准备要发送的邮件
        for (TeachingSupplyBorrowingApplication__c objBorrowing : lstBorrowingApplication) {
            // 使用邮件模板
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate((String) idTemplate, null, objBorrowing.Id);
            // 获取审批详情
            List<RS_ApprovalProcess_Cmn.ApprovalStepDetail> lstApprovalStepDetails = mapApprovalStepDetailsByTargetObjIds.get(objBorrowing.Id);
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
            lstToAddresses.add(objBorrowing.CreatedBy.Email);
            mail.setToAddresses(lstToAddresses);
            // 设置该邮件不要被保存为一个活动
            mail.setSaveAsActivity(false);
            // 添加发送邮件列表
            lstMailToSend.add(mail);
        }
        // 发送邮件
        Messaging.sendEmail(lstMailToSend);
    }

    public Map<String, List<Triggers.Handler>> eventHandlerMapping() {
        return null;
    }
}