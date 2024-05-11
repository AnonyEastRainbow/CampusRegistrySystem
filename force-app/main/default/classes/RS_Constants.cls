/**
 * @description: 常量类
 * @author: AnonyEast
 * @date: 2023-01-07
 */
public without sharing class RS_Constants {
    // 标准审批动作
    public static final String APPROVAL_ACTION_APPROVE = 'Approve';
    public static final String APPROVAL_ACTION_REJECT = 'Reject';
    public static final String APPROVAL_ACTION_RECALL = 'Removed';
    // 来自Global Pickist Value Set的审批状态
    public static final String PICKLIST_APPROVAL_STATUS_DRAFT = 'Draft';
    public static final String PICKLIST_APPROVAL_STATUS_DRAFT_LABEL = '草稿';
    public static final String PICKLIST_APPROVAL_STATUS_PENDING = 'Pending';
    public static final String PICKLIST_APPROVAL_STATUS_PENDING_LABEL = '审批中';
    public static final String PICKLIST_APPROVAL_STATUS_APPROVED = 'Approved';
    public static final String PICKLIST_APPROVAL_STATUS_APPROVED_LABEL = '已批准';
    public static final String PICKLIST_APPROVAL_STATUS_REJECTED = 'Rejected';
    public static final String PICKLIST_APPROVAL_STATUS_REJECTED_LABEL = '已拒绝';
    public static final String PICKLIST_APPROVAL_STATUS_CANCELED = 'Canceled';
    public static final String PICKLIST_APPROVAL_STATUS_CANCELED_LABEL = '已取消';
    // 来自Global Pickist Value Set的系统业务
    public static final String PICKLIST_OPERATION_LEAVE = 'Leave';
    public static final String PICKLIST_OPERATION_LEAVE_LABEL = '请假';
    public static final String PICKLIST_OPERATION_TEACHING_SUPPLY_BORROWING = 'TeachingSupplyBorrowing';
    public static final String PICKLIST_OPERATION_TEACHING_SUPPLY_BORROWING_LABEL = '教学用品借用';
    public static final String PICKLIST_OPERATION_LAB_BOOKING = 'LabBooking';
    public static final String PICKLIST_OPERATION_LAB_BOOKING_LABEL = '实验室预约';
    // 教学用品借用申请
    public static final String BORROWING_BY_CLASS_TIMES_RECORD_TYPE_DEVELOPER_NAME = 'TeachingSupplyBorrowingByClassTimes';
    public static final String BORROWING_BY_DATE_AND_TIME_RECORD_TYPE_DEVELOPER_NAME = 'TeachingSupplyBorrowingByDateAndTime';
    public static final Id BORROWING_BY_CLASS_TIMES_RECORD_TYPE_ID = Schema.SObjectType.TeachingSupplyBorrowingApplication__c.getRecordTypeInfosByDeveloperName().get(BORROWING_BY_CLASS_TIMES_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId();
    public static final Id BORROWING_BY_DATE_AND_TIME_RECORD_TYPE_ID = Schema.SObjectType.TeachingSupplyBorrowingApplication__c.getRecordTypeInfosByDeveloperName().get(BORROWING_BY_DATE_AND_TIME_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId();
    // 请假申请
    public static final String STUDENT_LEAVE_RECORD_TYPE_DEVELOPER_NAME = 'StudentLeave';
    public static final Id STUDENT_LEAVE_RECORD_TYPE_ID = Schema.SObjectType.LeaveApplication__c.getRecordTypeInfosByDeveloperName().get(STUDENT_LEAVE_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId();
    // 前端控制器状态返回值
    public static final String RTN_KEY_OK = 'OK';
    public static final String RTN_KEY_NG =	'NG';

}