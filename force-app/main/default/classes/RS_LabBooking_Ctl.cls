/**
 * @description LabBooking Controller
 * @author AnonyEast
 * @date 2023-03-26
 */
public with sharing class RS_LabBooking_Ctl {
    private static String currentUserContactId = RS_SObjectUtil_Cmn.getUserDetailInfo(UserInfo.getUserId()).ContactId;

    /**
     * @description 获取可预约的实验室
     * 
     * @return lstRtnAvailableBooking 可预约的实验室列表
     */
    @AuraEnabled(cacheable=false)
    public static RS_ResponseResult getAvailableBooking(Integer intPageNum, Integer intPageSize, List<String> lstLocation, List<String> lstLabType 
                                                        ,List<String> lstApprovalStatus, String strLabEquipment, Boolean boolNoNeedApproval 
                                                        ,Date dtOpeningDate, Date dtClosingDate, Date dtBookingStartDate, Date dtBookingEndDate) {
        Integer totalCounts = 0;
        String strQuery = '';
        String strSubQuery = '';
        // 子查询：查询当前用户在各实验室提交的预约申请
        strSubQuery += 'SELECT ';
        strSubQuery +=     'Applicant__c, ApprovalStatus__c, CreatedDate ';
        strSubQuery += 'FROM ';
        strSubQuery +=     'LabBookingApplications__r ';
        strSubQuery += 'WHERE ';
        strSubQuery +=     'Applicant__c = \'' + currentUserContactId + '\' ';
        strSubQuery += 'ORDER BY ';
        strSubQuery +=     'CreatedDate DESC ';
        // 原始查询
        strQuery += 'SELECT ';
        strQuery +=     'Id, Location__c, LabAddress__c, LabType__c, LabEquipment__c ';
        strQuery +=     ', OpeningTime__c, ClosingTime__c, BookingStartTime__c, BookingEndTime__c ';
        strQuery +=     ', Capacity__c, BookedNumber__c, Active__c, X1stApprover__c, X1stApprover__r.Name ';
        strQuery +=     ', (' + strSubQuery + ') ';
        strQuery += 'FROM ';
        strQuery +=     'LabBooking__c ';
        strQuery += 'WHERE ';
        strQuery +=     'Active__c = true ';
        // 筛选条件
        if (lstLocation != null && lstLocation.size() > 0) {
            strQuery += 'AND Location__c IN :lstLocation ';
        }
        if (lstLabType != null && lstLabType.size() > 0) {
            strQuery += 'AND LabType__c IN :lstLabType ';
        }
        if (strLabEquipment != null && strLabEquipment.length() > 0) {
            strQuery += 'AND LabEquipment__c LIKE \'%' + strLabEquipment + '%\' ';
        }
        if (boolNoNeedApproval != null && boolNoNeedApproval == true) {
            strQuery += 'AND X1stApprover__c = null ';
        }
        if (dtOpeningDate != null) {
            Datetime dtOpeningDatetime = RS_ApexUtil_Cmn.localDateToGmtDatetime(dtOpeningDate);
            strQuery += 'AND OpeningTime__c >= :dtOpeningDatetime ';
        }
        if (dtClosingDate != null) {
            Datetime dtClosingDatetime = RS_ApexUtil_Cmn.localDateToGmtDatetime(dtClosingDate);
            strQuery += 'AND ClosingTime__c <= :dtClosingDatetime ';
        }
        if (dtBookingStartDate != null) {
            Datetime dtBookingStartDatetime = RS_ApexUtil_Cmn.localDateToGmtDatetime(dtBookingStartDate);
            strQuery += 'AND BookingStartTime__c >= :dtBookingStartDatetime ';
        }
        if (dtBookingEndDate != null) {
            Datetime dtBookingEndDatetime = RS_ApexUtil_Cmn.localDateToGmtDatetime(dtBookingEndDate);
            strQuery += 'AND BookingEndTime__c <= :dtBookingEndDatetime ';
        }
        if (lstApprovalStatus != null && lstApprovalStatus.size() > 0) {
            strQuery += 'AND LabBookingApplications__r.ApprovalStatus__c IN :lstApprovalStatus ';
        }
        strQuery += 'ORDER BY ';
        strQuery +=     'OpeningTime__c DESC NULLS LAST ';
        // 不带分页的SOQL语句
        String strQueryWithoutPagination = strQuery;
        // 添加分页
        if (intPageNum != null && intPageSize != null) {
            Integer intOffset = (intPageNum - 1) * intPageSize;
            strQuery += ' LIMIT :intPageSize OFFSET :intOffset ';
        }
        // 未分页查询
        List<LabBooking__c> lstAvailableBooking = Database.query(strQueryWithoutPagination);
        totalCounts = lstAvailableBooking.size();
        // 分页查询
        lstAvailableBooking = Database.query(strQuery);
        // 自定义封装
        Map<Id,AvailableBookingWrapper> mapAvailableBookingWrapper = new Map<Id,AvailableBookingWrapper>();
        // 存储当前用户预约状态
        for(LabBooking__c objAvailableBooking : lstAvailableBooking){
            for(LabBookingApplication__c objApplication : objAvailableBooking.LabBookingApplications__r){
                AvailableBookingWrapper objAvailableBookingWrapper = new AvailableBookingWrapper();
                objAvailableBookingWrapper.userBookingStatus = objApplication.ApprovalStatus__c;
                mapAvailableBookingWrapper.put(objAvailableBooking.Id, objAvailableBookingWrapper);
                break;
            }
        }
        // 转换为Map
        List<Map<String, Object>> lstRtnAvailableBooking = RS_ApexUtil_Cmn.objectToMap(lstAvailableBooking);

        // 封装返回体
        Map<String, Object> mapLocationPicklistDescribe = RS_ApexUtil_Cmn.getPicklistDescribe('LabBooking__c', 'Location__c');
        for(Map<String, Object> mapAvailableBooking : lstRtnAvailableBooking){
            // API Name转Label
            mapAvailableBooking.put('Location__c',RS_ApexUtil_Cmn.picklistValueToLabel((String)mapAvailableBooking.get('Location__c'), mapLocationPicklistDescribe));
            mapAvailableBooking.put('CardTitle',mapAvailableBooking.get('Location__c') + ' ' + mapAvailableBooking.get('LabAddress__c'));
            // 当前用户预约状态
            AvailableBookingWrapper objAvailableBookingWrapper = mapAvailableBookingWrapper.get((String)mapAvailableBooking.get('Id'));
            if(objAvailableBookingWrapper != null){
                mapAvailableBooking.put('userBookingStatus',objAvailableBookingWrapper.userBookingStatus);
            }
        }
        return new RS_ResponseResult(RS_Constants.RTN_KEY_OK,lstRtnAvailableBooking,totalCounts);
    }

    /**
     * @description 获取当前用户预约的实验室
     * 
     * @return lstRtnMyBooking 当前用户预约的实验室列表
     */
    @AuraEnabled(cacheable=false)
    public static RS_ResponseResult getMyBooking(Integer intPageNum, Integer intPageSize) {
        Integer totalCounts = 0;
        String strQuery = '';
        strQuery += 'SELECT ';
        strQuery +=     'Id, CreatedById, BookedLab__c, ';
        strQuery +=     'Applicant__c, Applicant__r.Name, StudentNumber__c, SecondaryCollege__c, SecondaryCollege__r.Name, Major__c, Class__c, Class__r.Name, ';
        strQuery +=     'Location__c, LabAddress__c, BookingPeriod__c, ';
        strQuery +=     'ApprovalStatus__c, X1stApprover__c, X1stApprover__r.Name, FORMAT(CreatedDate), FORMAT(LastModifiedDate) ';
        strQuery += 'FROM ';
        strQuery +=     'LabBookingApplication__c ';
        strQuery += 'WHERE ';
        strQuery +=     'Applicant__c = \'' + currentUserContactId + '\' ';
        strQuery += 'ORDER BY ';
        strQuery +=     'LastModifiedDate DESC';
        // 不带分页的SOQL语句
        String strQueryWithoutPagination = strQuery;
        // 添加分页
        if (intPageNum != null && intPageSize != null) {
            Integer intOffset = (intPageNum - 1) * intPageSize;
            strQuery += ' LIMIT :intPageSize OFFSET :intOffset ';
        }
        // 未分页查询
        List<LabBookingApplication__c> lstMyBooking = Database.query(strQueryWithoutPagination);
        totalCounts = lstMyBooking.size();
        // 分页查询
        lstMyBooking = Database.query(strQuery);
        // 转换为Map
        List<Map<String, Object>> lstRtnMyBooking = RS_ApexUtil_Cmn.objectToMap(lstMyBooking);
        // 封装返回体
        Map<String, Object> mapLocationPicklistDescribe = RS_ApexUtil_Cmn.getPicklistDescribe('LabBookingApplication__c', 'Location__c');
        Map<String, Object> mapApprovalStatusPicklistDescribe = RS_ApexUtil_Cmn.getPicklistDescribe('LabBookingApplication__c', 'ApprovalStatus__c');
        for(Map<String, Object> mapMyBooking : lstRtnMyBooking){
            // API Name -> Label
            mapMyBooking.put('Location__c',RS_ApexUtil_Cmn.picklistValueToLabel((String)mapMyBooking.get('Location__c'), mapLocationPicklistDescribe));
            mapMyBooking.put('ApprovalStatus__c',RS_ApexUtil_Cmn.picklistValueToLabel((String)mapMyBooking.get('ApprovalStatus__c'), mapApprovalStatusPicklistDescribe));
            // 是否可取消预约
            if (mapMyBooking.get('ApprovalStatus__c') == RS_Constants.PICKLIST_APPROVAL_STATUS_CANCELED_LABEL || mapMyBooking.get('ApprovalStatus__c') == RS_Constants.PICKLIST_APPROVAL_STATUS_REJECTED_LABEL) {
                mapMyBooking.put('isDisabledCancelBooking',true);
            }else{
                mapMyBooking.put('isDisabledCancelBooking',false);
            }
        }
        return new RS_ResponseResult(RS_Constants.RTN_KEY_OK,lstRtnMyBooking,totalCounts);
    }

    /**
     * @description 用户预约请求
     * @param labBookingId 实验室预约Id
     * 
     * @return 
     */
    @AuraEnabled(cacheable=false)
    public static RS_ResponseResult bookingRequest(Id labBookingId) {
        Id currentUserId = UserInfo.getUserId();
        // 检查是否可以预约
        Map<String,Object> mapCheckResult = checkBooking(labBookingId,currentUserId);
        if ((Boolean)mapCheckResult.get('isBookable')) {
            // 执行预约操作
            return executeBookingAction(labBookingId,currentUserId);
        }else{
            return new RS_ResponseResult(RS_Constants.RTN_KEY_NG, (String)mapCheckResult.get('message'));
        }
    }

    /**
     * @description 检查用户是否可以预约当前实验室
     * @param labBookingId 实验室预约Id
     * @param userId 用户Id
     * 
     * @return RS_ResponseResult
     */
    public static Map<String,Object> checkBooking(Id labBookingId, Id userId) {
        Map<String,Object> mapCheckResult = new Map<String,Object>();
        // 检查同一个可预约实验室是否有审批中、已批准的预约申请
        List<LabBookingApplication__c> lstBookingApplication = [
            SELECT 
                Id 
            FROM 
                LabBookingApplication__c 
            WHERE 
                BookedLab__c = :labBookingId 
                AND CreatedById = :userId 
                AND ApprovalStatus__c IN (:RS_Constants.PICKLIST_APPROVAL_STATUS_PENDING, :RS_Constants.PICKLIST_APPROVAL_STATUS_APPROVED)
        ];
        if (lstBookingApplication != null && lstBookingApplication.size() > 0) {
            mapCheckResult.put('isBookable',false);
            mapCheckResult.put('message','你选择的实验室已存在审批中/已批准的预约申请。');
            return mapCheckResult;
        }
        // 检查当前时间是否在开放预约时间、是否约满
        LabBooking__c objLabBooking = [
            SELECT 
                Id,	BookingStartTime__c, BookingEndTime__c, ClosingTime__c, BookedNumber__c, Capacity__c 
            FROM 
                LabBooking__c 
            WHERE 
                Id = :labBookingId 
        ];
        // 是否在开放预约时间
        Datetime datetimeNow = Datetime.now();
        if (datetimeNow > objLabBooking.ClosingTime__c) {
            mapCheckResult.put('isBookable',false);
            mapCheckResult.put('message','你选择的实验室已超过开放时间段。');
            return mapCheckResult;
        }else if(datetimeNow < objLabBooking.BookingStartTime__c){
            mapCheckResult.put('isBookable',false);
            mapCheckResult.put('message','你选择的实验室暂未开始预约。');
            return mapCheckResult;
        }else if(datetimeNow > objLabBooking.BookingEndTime__c){
            mapCheckResult.put('isBookable',false);
            mapCheckResult.put('message','你选择的实验室已超过可预约时间段。');
            return mapCheckResult;
        }
        // 是否禁止预约
        if (objLabBooking.BookedNumber__c >= objLabBooking.Capacity__c) {
            mapCheckResult.put('isBookable',false);
            mapCheckResult.put('message','你选择的实验室预约人数已满');
            return mapCheckResult;
        }
        mapCheckResult.put('isBookable',true);
        return mapCheckResult;
    }

    /**
     * @description 执行预约操作
     * @param labBookingId 实验室预约Id
     * @param userId 用户Id
     * 
     * @return RS_ResponseResult
     */
    public static RS_ResponseResult executeBookingAction(Id labBookingId, Id userId) {
        // 获取用户详细信息
        User userDetailInfo = RS_SObjectUtil_Cmn.getUserDetailInfo(userId);
        LabBookingApplication__c objBookingApplication = new LabBookingApplication__c();
        objBookingApplication.BookedLab__c = labBookingId;
        objBookingApplication.Applicant__c = userDetailInfo.ContactId;
        objBookingApplication.StudentNumber__c = userDetailInfo.Contact.StudentNumber__c;
        objBookingApplication.SecondaryCollege__c = userDetailInfo.Contact.SecondaryCollege__c;
        objBookingApplication.Major__c = userDetailInfo.Contact.Profession__c;
        objBookingApplication.Class__c = userDetailInfo.Contact.Account.Id;
        // 设置回滚点
        System.Savepoint objBeforeInsertSavePoint = Database.setSavepoint();
        // 插入数据库
        Database.SaveResult insertResult = Database.insert(objBookingApplication);
        // 插入成功
        if (insertResult.isSuccess()) {
            // 提交待审批
            RS_ResponseResult objResponseResult = submitApprovalProcess(objBookingApplication.Id,userId);
            // 批准过程提交成功
            if (objResponseResult.status == RS_Constants.RTN_KEY_OK) {
                List<LabBookingApplication__c> lstBookingApplication = new List<LabBookingApplication__c>{objBookingApplication};
                objResponseResult.data = RS_ApexUtil_Cmn.objectToMap(lstBookingApplication);
                return objResponseResult;
            // 批准过程提交失败
            }else{
                // 回滚
                Database.rollback(objBeforeInsertSavePoint);
                return objResponseResult;
            }
        // 插入失败
        }else{
            String strErrorMessage = '';
            Database.Error[] lstErrorInfo = insertResult.getErrors();
            for (Database.Error errorInfo : lstErrorInfo) {
                strErrorMessage = errorInfo.getStatusCode() + ': ' + errorInfo.getMessage() + '\n';
            }
            return new RS_ResponseResult(RS_Constants.RTN_KEY_NG, strErrorMessage);
        }
    }

    /**
     * @description 提交待审批
     * @param labBookingApplicationId 实验室预约申请Id
     * 
     * @return RS_ResponseResult
     */
    public static RS_ResponseResult submitApprovalProcess(Id labBookingApplicationId, Id userId) {
        // 创建ProcessSubmitRequest实例
        Approval.ProcessSubmitRequest objApprovalSubmitRequest = new Approval.ProcessSubmitRequest();
        objApprovalSubmitRequest.setComments('申请人发起预约申请，系统自动提交审批。');
        objApprovalSubmitRequest.setSubmitterId(userId);
        objApprovalSubmitRequest.setObjectId(labBookingApplicationId);
        // 提交审批
        Approval.ProcessResult objApprovalSubmitResult = Approval.process(objApprovalSubmitRequest);
        if (objApprovalSubmitResult.isSuccess()) {
            return new RS_ResponseResult(RS_Constants.RTN_KEY_OK);
        }else{
            String strErrorMessage = '';
            Database.Error[] lstErrorInfo = objApprovalSubmitResult.getErrors();
            for (Database.Error errorInfo : lstErrorInfo) {
                strErrorMessage = errorInfo.getStatusCode() + ': ' + errorInfo.getMessage() + '\n';
            }
            return new RS_ResponseResult(RS_Constants.RTN_KEY_NG, strErrorMessage);
        }
    }

    /**
     * @description 用户取消预约
     * @param labBookingApplicationId 实验室预约申请Id
     * 
     * @return RS_ResponseResult
     */
    @AuraEnabled(cacheable=false)
    public static RS_ResponseResult cancelBookingRequest(Id labBookingApplicationId) {
        LabBookingApplication__c objLabBookingApplication = [
            SELECT 
                Id, ApprovalStatus__c
            FROM 
                LabBookingApplication__c
            WHERE 
                Id = :labBookingApplicationId
            LIMIT 1
        ];
        // 批准状态: 审批中
        if (objLabBookingApplication.ApprovalStatus__c == RS_Constants.PICKLIST_APPROVAL_STATUS_PENDING) {
            // 撤回批准请求
            ProcessInstanceWorkitem objLabBookingApprovalWorkitem = RS_ApprovalProcess_Cmn.getProcessInstanceWorkitem(labBookingApplicationId);
            Approval.ProcessWorkitemRequest objApprovalWorkitemRequest = new Approval.ProcessWorkitemRequest();
            objApprovalWorkitemRequest.setWorkitemId(objLabBookingApprovalWorkitem.Id);
            objApprovalWorkitemRequest.setComments('申请人取消预约，系统自动撤回审批。');
            objApprovalWorkitemRequest.setAction(RS_Constants.APPROVAL_ACTION_RECALL);
            Approval.ProcessResult objApprovalWorkitemResult = Approval.process(objApprovalWorkitemRequest);
            if (objApprovalWorkitemResult.isSuccess()) {
                return new RS_ResponseResult(RS_Constants.RTN_KEY_OK);
            }else{
                String strErrorMessage = '';
                Database.Error[] lstErrorInfo = objApprovalWorkitemResult.getErrors();
                for (Database.Error errorInfo : lstErrorInfo) {
                    strErrorMessage = errorInfo.getStatusCode() + ': ' + errorInfo.getMessage() + '\n';
                }
                return new RS_ResponseResult(RS_Constants.RTN_KEY_NG, strErrorMessage);
            }
        // 批准状态: 已批准
        }else if(objLabBookingApplication.ApprovalStatus__c == RS_Constants.PICKLIST_APPROVAL_STATUS_APPROVED){
            objLabBookingApplication.ApprovalStatus__c = RS_Constants.PICKLIST_APPROVAL_STATUS_CANCELED;
            Database.SaveResult updateResult = Database.update(objLabBookingApplication);
            if (updateResult.isSuccess()) {
                return new RS_ResponseResult(RS_Constants.RTN_KEY_OK);
            }else{
                String strErrorMessage = '';
                Database.Error[] lstErrorInfo = updateResult.getErrors();
                for (Database.Error errorInfo : lstErrorInfo) {
                    strErrorMessage = errorInfo.getStatusCode() + ': ' + errorInfo.getMessage() + '\n';
                }
                return new RS_ResponseResult(RS_Constants.RTN_KEY_NG, strErrorMessage);
            }
        }else{
            return new RS_ResponseResult(RS_Constants.RTN_KEY_NG,'仅批准状态为审批中/已批准的预约申请可以取消预约。');
        }
    }

    /**
     * @description 获取当前实验室申请记录的最新批准步骤节点
     * 
     * @return lstApprovalStepDetail 批准节点列表
     */
    @AuraEnabled(cacheable=false)
    public static RS_ResponseResult getApprovalSteps(Id labApplicationId){
        return new RS_ResponseResult(RS_Constants.RTN_KEY_OK,RS_ApexUtil_Cmn.objectToMap(RS_ApprovalProcess_Cmn.getLatestApprovalNodes(labApplicationId)));
    }

    // 可预约实验室自定义封装
    public class AvailableBookingWrapper{
        public LabBooking__c objLabBooking {get; set;}
        public String userBookingStatus;
    }
}