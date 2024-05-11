public with sharing class RS_ApprovalProcess_Cmn {
    /**
     * @description 获取记录中批准历史的审批人、审批状态和备注
     * @param mapObj 要获取的审批详情的记录
     *
     * @return 每一条记录的最新审批详情
     */
    public static Map<Id, List<ApprovalStepDetail>> getApprovalStepDetail(Map<Id, SObject> mapObj){
        // 获取批准步骤(按创建时间降序)
        List<ProcessInstanceStep> lstPis = [
                SELECT ProcessInstanceId,ProcessInstance.TargetObjectId,OriginalActor.Name,StepStatus,Comments,CreatedDate
                FROM ProcessInstanceStep
                WHERE ProcessInstance.TargetObjectId IN :mapObj.keySet()
                ORDER BY CreatedDate DESC
        ];
        // 返回值：key为TargetObjectId，value为审批步骤详情
        Map<Id, List<ApprovalStepDetail>> mapApprovalStepDetailsByTargetObjIds = new Map<Id, List<ApprovalStepDetail>>();
        for (ProcessInstanceStep pis : lstPis) {
            if (mapObj.get(pis.ProcessInstance.TargetObjectId) != null) {
                ApprovalStepDetail objApprovalStepDetail = new ApprovalStepDetail();
                objApprovalStepDetail.processInstanceId = pis.ProcessInstanceId;
                objApprovalStepDetail.approver = pis.OriginalActor.Name;
                objApprovalStepDetail.status = pis.StepStatus;
                objApprovalStepDetail.comments = pis.Comments;
                objApprovalStepDetail.createdTime = pis.CreatedDate.format('yyyy/MM/dd HH:mm','Asia/Shanghai');
                // 获取已保存的ApprovalStepDetail
                List<ApprovalStepDetail> lstApprovalStepDetail = mapApprovalStepDetailsByTargetObjIds.get(pis.ProcessInstance.TargetObjectId);
                if (lstApprovalStepDetail != null && lstApprovalStepDetail.size() > 0) {
                    lstApprovalStepDetail.add(objApprovalStepDetail);
                    mapApprovalStepDetailsByTargetObjIds.put(pis.ProcessInstance.TargetObjectId,lstApprovalStepDetail);
                }else{
                    lstApprovalStepDetail = new List<ApprovalStepDetail>();
                    lstApprovalStepDetail.add(objApprovalStepDetail);
                    mapApprovalStepDetailsByTargetObjIds.put(pis.ProcessInstance.TargetObjectId,lstApprovalStepDetail);
                }
            }
        }
        System.debug(LoggingLevel.INFO,'mapApprovalStepDetailsByTargetObjIds -> ' + mapApprovalStepDetailsByTargetObjIds);
        // 去重
        mapApprovalStepDetailsByTargetObjIds = approvalStepDetailDuplicateRemove(mapApprovalStepDetailsByTargetObjIds);
        return mapApprovalStepDetailsByTargetObjIds;
    }

    /**
     * @description ApprovalStepDetail去重
     * @param mapApprovalStepDetailsByTargetObjIds targerObjectId的批准过程
     * 
     * @return 去重后的结果
     */
    public static Map<Id, List<ApprovalStepDetail>> approvalStepDetailDuplicateRemove(Map<Id, List<ApprovalStepDetail>> mapApprovalStepDetailsByTargetObjIds){
        Set<Id> setTargetObjIds = mapApprovalStepDetailsByTargetObjIds.keySet();
        for (Id targetObjId : setTargetObjIds) {
            // 原来的ApprovalStepDetail列表
            List<ApprovalStepDetail> lstOldApprovalStepDetail = mapApprovalStepDetailsByTargetObjIds.get(targetObjId);
            // 只保留最新的ProcessInstanceId
            String processInstanceId;
            // 存储去重后的ApprovalStepDetail列表
            List<ApprovalStepDetail> lstNewApprovalStepDetail = new List<ApprovalStepDetail>();
            for (ApprovalStepDetail approvalStepDetail : lstOldApprovalStepDetail) {
                if (processInstanceId == null && approvalStepDetail.processInstanceId != null) {
                    processInstanceId = approvalStepDetail.processInstanceId;
                    lstNewApprovalStepDetail.add(approvalStepDetail);
                }else if (processInstanceId == approvalStepDetail.processInstanceId) {
                    lstNewApprovalStepDetail.add(approvalStepDetail);
                }
            }
            mapApprovalStepDetailsByTargetObjIds.put(targetObjId,lstNewApprovalStepDetail);
        }
        System.debug('mapApprovalStepDetailsByTargetObjIds_DuplicateRemove -> ' + mapApprovalStepDetailsByTargetObjIds);
        return mapApprovalStepDetailsByTargetObjIds;
    }

    /**
     * @description 获取多条记录中正在审批的批准过程实例
     * @param mapTargetObj 
     * 
     * @return 记录中正在审批的批准过程实例
     */
    public static Map<Id, ProcessInstanceWorkitem> getProcessInstanceWorkitem(Map<Id, SObject> mapObj){
        // 存储记录中正在审批的批准过程实例
        Map<Id,ProcessInstanceWorkitem> mapObjProcessWorkitem = new Map<Id,ProcessInstanceWorkitem>();
        // 获取所有ProcessInstanceWorkitem
        List<ProcessInstanceWorkitem> lstProcessWorkitem = [
            SELECT 
                Id, ProcessInstance.TargetObjectId 
            FROM 
                ProcessInstanceWorkitem 
            WHERE 
                Id != null
        ];
        // 封装TargetObjectId与ProcessInstanceWorkitem的映射
        Map<Id,ProcessInstanceWorkitem> mapTargetObjIdToProcessWorkitem = new Map<Id,ProcessInstanceWorkitem>();
        for(ProcessInstanceWorkitem objProcessWorkitem : lstProcessWorkitem){
            mapTargetObjIdToProcessWorkitem.put(objProcessWorkitem.ProcessInstance.TargetObjectId, objProcessWorkitem);
        }
        // 查找记录中的ProcessInstanceWorkitem
        Set<Id> setObjectId = mapObj.keySet();
        for(Id objId : setObjectId) {
            if (mapTargetObjIdToProcessWorkitem.get(objId) != null) {
                mapObjProcessWorkitem.put(objId, mapTargetObjIdToProcessWorkitem.get(objId));
            }
        }
        return mapObjProcessWorkitem;
    }

    /**
     * @description 获取单条记录中正在审批的批准过程实例
     * @param sObjectInstance 对象实例
     * 
     * @return 该记录中正在审批的批准过程实例
     */
    public static ProcessInstanceWorkitem getProcessInstanceWorkitem(Id sObjectId){
        return [
            SELECT 
                Id, ProcessInstance.TargetObjectId 
            FROM 
                ProcessInstanceWorkitem 
            WHERE 
                ProcessInstance.TargetObjectId = :sObjectId
            LIMIT 1
        ];
    }

    /**
     * @description 获取单条记录最新的批准节点
     * 
     * @return lstApprovalStepDetail 批准节点列表
     */
    public static List<ApprovalStepDetail> getLatestApprovalNodes(Id recordId){
        // 要返回的ApprovalStepDetail
        List<ApprovalStepDetail> lstApprovalStepDetail = new List<ApprovalStepDetail>();

        // 获取当前记录最新的ProcessInstance
        List<ProcessInstance> lstProcessInstance = [
            SELECT Id,TargetObjectId FROM ProcessInstance WHERE TargetObjectId = :recordId ORDER BY CreatedDate DESC 
        ];
        if (lstProcessInstance != null && lstProcessInstance.size() > 0) {
            // 获取该ProcessInstance的ProcessInstanceNode
            List<ProcessInstanceNode> lstProcessInstanceNode = [
                SELECT Id, ProcessInstanceId, ProcessNodeId, ProcessNodeName, NodeStatus, LastActor.Id, LastActor.Name, CompletedDate 
                FROM ProcessInstanceNode 
                WHERE ProcessInstanceId = :lstProcessInstance[0].Id 
                ORDER BY CreatedDate ASC 
            ];
            // 获取该ProcessInstance的ProcessInstanceStep
            List<ProcessInstanceStep> lstProcessInstanceStep = [
                SELECT Id, ProcessInstanceId, StepNodeId, StepStatus, OriginalActor.Id, OriginalActor.Name, Actor.Id, Actor.Name, Comments, CreatedDate 
                FROM ProcessInstanceStep 
                WHERE ProcessInstanceId = :lstProcessInstance[0].Id 
                ORDER BY CreatedDate ASC 
            ];
            // 获取该ProcessInstance的ProcessInstanceStep
            List<ProcessInstanceWorkitem> lstProcessInstanceWorkitem = [
                SELECT Id, ProcessInstanceId, OriginalActor.Id, OriginalActor.Name 
                FROM ProcessInstanceWorkitem 
                WHERE ProcessInstanceId = :lstProcessInstance[0].Id 
                ORDER BY CreatedDate ASC 
            ];
            // StepNodeId与ProcessInstanceStep的映射
            Map<Id,ProcessInstanceStep> mapStepNodeIdToProcessInstanceStep = new Map<Id,ProcessInstanceStep>();
            for (ProcessInstanceStep objProcessInstanceStep : lstProcessInstanceStep){
                if(objProcessInstanceStep.StepNodeId != null){
                    mapStepNodeIdToProcessInstanceStep.put(objProcessInstanceStep.StepNodeId,objProcessInstanceStep);
                }
            }
            Integer stepNumber = 1;
            for (ProcessInstanceNode objProcessInstanceNode : lstProcessInstanceNode){
                ApprovalStepDetail objApprovalStepDetail = new ApprovalStepDetail();
                // objApprovalStepDetail.stepNumber = stepNumber++;
                objApprovalStepDetail.stepName = objProcessInstanceNode.ProcessNodeName;
                objApprovalStepDetail.status = objProcessInstanceNode.NodeStatus;
                objApprovalStepDetail.approver = objProcessInstanceNode.LastActor.Name;
                if(objProcessInstanceNode.CompletedDate != null){
                    objApprovalStepDetail.createdTime = objProcessInstanceNode.CompletedDate.format('yyyy/MM/dd HH:mm','Asia/Shanghai');
                }
                // 检查是否存在ProcessInstanceStep
                if(mapStepNodeIdToProcessInstanceStep.get(objProcessInstanceNode.ProcessNodeId) != null){
                    ProcessInstanceStep objProcessInstanceStep = mapStepNodeIdToProcessInstanceStep.get(objProcessInstanceNode.ProcessNodeId);
                    objApprovalStepDetail.originalApprover = objProcessInstanceStep.OriginalActor.Name;
                    objApprovalStepDetail.comments = objProcessInstanceStep.Comments;
                }
                // 检查是否为审批中
                if(lstProcessInstanceWorkitem != null && lstProcessInstanceWorkitem.size() > 0 && objProcessInstanceNode.NodeStatus == 'Pending'){
                    // 从ProcessInstanceWorkitem取原始审批人
                    objApprovalStepDetail.originalApprover = lstProcessInstanceWorkitem[0].OriginalActor.Name;
                }
                lstApprovalStepDetail.add(objApprovalStepDetail);
            }
        }
        return lstApprovalStepDetail;
    }


    /**
     * ApprovalStepDetail实体类
     */
    public class ApprovalStepDetail{
        public Id processInstanceId;
        public Integer stepNumber;
        public String stepName;
        public String originalApprover;
        public String approver;
        public String status;
        public String comments;
        public String createdTime;
    }
}