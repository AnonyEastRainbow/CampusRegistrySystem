/**
 * @description: LeaveApplication__c AfterUpdate trigger handler
 * @author: AnonyEast
 * @date: 2023-01-07
 */
public without sharing class RS_Leave_AfterUpdate_Hdl implements Triggers.Handler {
    public void handle() {
        try {
            // 更新后的对象
            List<LeaveApplication__c> lstNewLeaveApplication = (List<LeaveApplication__c>)Trigger.new;
            // 更新前的对象
            Map<Id, LeaveApplication__c> mapOldLeaveApplication = (Map<Id, LeaveApplication__c>)Trigger.oldMap;
            // 存储审批通过的对象
            List<LeaveApplication__c> lstApprovedLeaveApplication = new List<LeaveApplication__c>();
            // 存储审批驳回的对象
            List<LeaveApplication__c> lstRejectedLeaveApplication = new List<LeaveApplication__c>();
            // 判断审批状态
            for (LeaveApplication__c objLeave : lstNewLeaveApplication) {
                // 获取更新前的审批状态
                String strOldStatus = mapOldLeaveApplication.get(objLeave.Id).ApprovalStatus__c;
                // 审批通过
                if (objLeave.ApprovalStatus__c == RS_Constants.PICKLIST_APPROVAL_STATUS_APPROVED && strOldStatus != objLeave.ApprovalStatus__c) {
                    lstApprovedLeaveApplication.add(objLeave);
                }
                // 审批驳回
                else if (objLeave.ApprovalStatus__c == RS_Constants.PICKLIST_APPROVAL_STATUS_REJECTED && strOldStatus != objLeave.ApprovalStatus__c) {
                    lstRejectedLeaveApplication.add(objLeave);
                }
            }
            if (!lstApprovedLeaveApplication.isEmpty()) {
                // 执行审批通过的动作
                approvedLeaveApplicationAction(lstApprovedLeaveApplication);
            }
            if (!lstRejectedLeaveApplication.isEmpty()) {
                // 执行审批驳回的动作
                rejectedLeaveApplicationAction(lstRejectedLeaveApplication);
            }
        } catch (Exception ex) {
            RS_Logger_Cmn.createLog('Leave_AfterUpdate_Exception',ex,'RS_Leave_AfterUpdate_Hdl.handle');
        }
    }

    /**
     * @description 请假审批通过后的动作
     * @param lstLeaveApplication 审批通过的请假申请记录
     */
    public static void approvedLeaveApplicationAction(List<LeaveApplication__c> lstLeaveApplication){
        // 发送审批成功邮件
        // 获取邮件模板
        EmailTemplate objTemplate = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'LeaveApplicationApprovalResultNotification_Approved' LIMIT 1];
        // 获取审批人、审批状态和备注
        Map<Id, LeaveApplication__c> mapLeaveApplication = new Map<Id,LeaveApplication__c>(lstLeaveApplication);
        Map<Id, List<RS_ApprovalProcess_Cmn.ApprovalStepDetail>> mapApprovalStepDetailsByTargetObjIds = RS_ApprovalProcess_Cmn.getApprovalStepDetail(mapLeaveApplication);
        // 发送邮件
        sendEmail(lstLeaveApplication, mapApprovalStepDetailsByTargetObjIds, objTemplate);
    }

    /**
     * @description 请假审批拒绝后的动作
     * @param lstLeaveApplication 请假申请记录
     */
    public static void rejectedLeaveApplicationAction(List<LeaveApplication__c> lstLeaveApplication){
        // 发生审批失败邮件
        // 获取邮件模板
        EmailTemplate objTemplate = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'LeaveApplicationApprovalResultNotification_Rejected' LIMIT 1];
        // 获取审批人、审批状态和备注
        Map<Id, LeaveApplication__c> mapLeaveApplication = new Map<Id,LeaveApplication__c>(lstLeaveApplication);
        Map<Id, List<RS_ApprovalProcess_Cmn.ApprovalStepDetail>> mapApprovalStepDetailsByTargetObjIds = RS_ApprovalProcess_Cmn.getApprovalStepDetail(mapLeaveApplication);
        // 发送邮件
        sendEmail(lstLeaveApplication, mapApprovalStepDetailsByTargetObjIds, objTemplate);
    }

    /**
     * @description 发送邮件通知
     * @param lstLeaveApplication: 请假申请记录
     * @param mapApprovalStepDetailsByTargetObjIds: 目标对象id与审批详情映射
     * @param idTemplate: 邮件模板Id
     */
    public static void sendEmail(List<LeaveApplication__c> lstLeaveApplication, Map<Id, List<RS_ApprovalProcess_Cmn.ApprovalStepDetail>> mapApprovalStepDetailsByTargetObjIds, EmailTemplate template){
        // 将需要用到的父对象信息存储到变量
        lstLeaveApplication = [SELECT Owner.Email, Owner.Name FROM LeaveApplication__c WHERE Id IN :lstLeaveApplication];
        // 获取发件人地址
        OrgWideEmailAddress objFromAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :Label.RS_EmailFromAddress LIMIT 1];
        // 存储要发送的邮件
        List<Messaging.SingleEmailMessage> lstMailToSend = new List<Messaging.SingleEmailMessage>();
        // 准备要发送的邮件
        for (LeaveApplication__c objLeave : lstLeaveApplication) {
            // 使用邮件模板
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, null, objLeave.Id);
            // 获取审批详情
            List<RS_ApprovalProcess_Cmn.ApprovalStepDetail> lstApprovalStepDetails = mapApprovalStepDetailsByTargetObjIds.get(objLeave.Id);
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
            lstToAddresses.add(objLeave.Owner.Email);
            mail.setToAddresses(lstToAddresses);
            // 设置抄送人地址
            if (template.DeveloperName.containsIgnoreCase('Approved') || template.DeveloperName.containsIgnoreCase('Rejected')){
                List<String> lstCcAddresses = new List<String>();
                User objLeaveUser = RS_SObjectUtil_Cmn.getUserDetailInfo(objLeave.OwnerId);
                lstCcAddresses.add(objLeaveUser.Contact.Account.Owner.Email);
                mail.setCcAddresses(lstCcAddresses);
            }
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