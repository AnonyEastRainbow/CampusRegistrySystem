/**
 * @description: LeaveApplication__c Controller
 * @author: AnonyEast
 * @date: 2023-06-09
 */
public with sharing class RS_Leave_Ctl {
    /**
     * @description 获取当前请假申请记录的最新批准步骤节点
     * 
     * @return lstApprovalStepDetail 批准节点列表
     */
    @AuraEnabled(cacheable=false)
    public static RS_ResponseResult getApprovalSteps(Id leaveId){
        return new RS_ResponseResult(RS_Constants.RTN_KEY_OK,RS_ApexUtil_Cmn.objectToMap(RS_ApprovalProcess_Cmn.getLatestApprovalNodes(leaveId)));
    }
}