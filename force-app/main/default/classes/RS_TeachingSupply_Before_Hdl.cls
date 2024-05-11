/**
 * @description: TeachingSupplyBorrowingApplication__c BeforeInsert, BeforeUpdate trigger handler
 * @author: AnonyEast
 * @date: 2023-03-13
 */
public with sharing class RS_TeachingSupply_Before_Hdl implements Triggers.Handler {
    public void handle() {
        try {
            // 更新后的对象
            List<TeachingSupplyBorrowingApplication__c> lstNewBorrowingApplication = (List<TeachingSupplyBorrowingApplication__c>)Trigger.new;
            // 更新前的对象
            Map<Id, TeachingSupplyBorrowingApplication__c> mapOldBorrowingApplication = (Map<Id, TeachingSupplyBorrowingApplication__c>)Trigger.oldMap;
            // 借用开始时间、借用结束时间字段赋值(仅限按日期和节次借用)
            setBorrowingStartAndEndDatetime(lstNewBorrowingApplication);
            // 存储审批通过的对象
            List<TeachingSupplyBorrowingApplication__c> lstApprovedBorrowingApplication = new List<TeachingSupplyBorrowingApplication__c>();
            // 判断审批状态
            for (TeachingSupplyBorrowingApplication__c objBorrowing : lstNewBorrowingApplication) {
                // 获取更新前的审批状态
                String strOldStatus = mapOldBorrowingApplication.get(objBorrowing.Id).ApprovalStatus__c;
                // 审批通过
                if (objBorrowing.ApprovalStatus__c == RS_Constants.PICKLIST_APPROVAL_STATUS_APPROVED && strOldStatus != objBorrowing.ApprovalStatus__c) {
                    lstApprovedBorrowingApplication.add(objBorrowing);
                }
            }
            if (!lstApprovedBorrowingApplication.isEmpty()) {
                // 领取/归还联系信息赋值
                setReceiveAndReutrnContact(lstApprovedBorrowingApplication);
            }
        } catch (Exception ex) {
            RS_Logger_Cmn.createLog('TeachingSupply_BeforeTrg_Exception',ex,'RS_TeachingSupply_Before_Hdl.handle');
        }
    }

    /**
     * @description 借用开始时间、借用结束时间字段赋值(仅限按日期和节次借用)
     * @param lstBorrowingApplication 教学用品借用申请列表
     */
    public static void setBorrowingStartAndEndDatetime(List<TeachingSupplyBorrowingApplication__c> lstBorrowingApplication) {
        // 从节次时间表(ClassTimesSchedule__mdt)获取上课时间
        List<ClassTimesSchedule__mdt> lstClassTimesSchedule = [
            SELECT ClassTimes__c,ClassStartTime__c,ClassEndTime__c
            FROM ClassTimesSchedule__mdt
        ];
        // 将节次与上课时间、下课时间的映射封装到Map
        Map<Integer,ClassTimesSchedule__mdt> mapClassTimesSchedule = new Map<Integer,ClassTimesSchedule__mdt>();
        for (ClassTimesSchedule__mdt mdtClassTimesSchedule : lstClassTimesSchedule) {
            mapClassTimesSchedule.put(Integer.valueOf(mdtClassTimesSchedule.ClassTimes__c),mdtClassTimesSchedule);
        }
        
        for(TeachingSupplyBorrowingApplication__c objBorrowingApplication : lstBorrowingApplication){
            try {
                // 按日期和节次借用
                if (objBorrowingApplication.RecordTypeId == RS_Constants.BORROWING_BY_CLASS_TIMES_RECORD_TYPE_ID) {
                    // 获取上课时间
                    ClassTimesSchedule__mdt mdtStartClassTimesSchedule = mapClassTimesSchedule.get(Integer.valueOf(objBorrowingApplication.BorrowingStartClassTimes__c));
                    String strBorrowingStartTime = mdtStartClassTimesSchedule.ClassStartTime__c;
                    // 获取上课时间的小时和分钟
                    List<String> lstBorrowingStartTimeSplit = strBorrowingStartTime.split(':');
                    // 按年月日时分秒创建开始借用日期和时间的Datetime实例
                    Datetime datetimeBorrowingStartDateAndTime = Datetime.newInstance(objBorrowingApplication.BorrowingStartDate__c.year(),objBorrowingApplication.BorrowingStartDate__c.month(),objBorrowingApplication.BorrowingStartDate__c.day(),Integer.valueOf(lstBorrowingStartTimeSplit.get(0)),Integer.valueOf(lstBorrowingStartTimeSplit.get(1)),0);
                    // 借用开始时间赋值
                    objBorrowingApplication.BorrowingStartDateAndTime__c = datetimeBorrowingStartDateAndTime;
                    // 获取下课时间
                    ClassTimesSchedule__mdt mdtEndClassTimesSchedule = mapClassTimesSchedule.get(Integer.valueOf(objBorrowingApplication.BorrowingEndClassTimes__c));
                    String strBorrowingEndTime = mdtEndClassTimesSchedule.ClassEndTime__c;
                    // 获取下课时间的小时和分钟
                    List<String> lstBorrowingEndTimeSplit = strBorrowingEndTime.split(':');
                    // 按年月日时分秒创建结束借用日期和时间的Datetime实例
                    Datetime datetimeBorrowingEndDateAndTime = Datetime.newInstance(objBorrowingApplication.BorrowingEndDate__c.year(),objBorrowingApplication.BorrowingEndDate__c.month(),objBorrowingApplication.BorrowingEndDate__c.day(),Integer.valueOf(lstBorrowingEndTimeSplit.get(0)),Integer.valueOf(lstBorrowingEndTimeSplit.get(1)),0);
                    // 借用结束时间赋值
                    objBorrowingApplication.BorrowingEndDateAndTime__c = datetimeBorrowingEndDateAndTime;
                }
            } catch (Exception ex) {
                objBorrowingApplication.BorrowingStartDateAndTime__c = null;
                objBorrowingApplication.BorrowingEndDateAndTime__c = null;
                RS_Logger_Cmn.createLog('TeachingSupply_Exception',ex,'RS_TeachingSupply_Before_Hdl.setBorrowingStartAndEndDatetime');
            }
        }
    }

    /**
     * @description 领取/归还联系信息赋值
     * @param lstBorrowingApplication: 审批通过的教学用品借用申请申请记录
     */
    public static void setReceiveAndReutrnContact(List<TeachingSupplyBorrowingApplication__c> lstBorrowingApplication){
        // 查询各二级学院Id
        Map<Id,Account> mapSecondryCollage = RS_SObjectUtil_Cmn.getSecondryCollegeMap();
        // 获取教学用品领取归还联系信息
        List<TeachingSupplyReceiveAndReutrnContact__mdt> lstReceiveAndReutrnContact = [
            SELECT Id, ReceiveContact__c, Location__c, ReceiveContactPhone__c, ReturnContact__c, ReturnContactPhone__c, Active__c, ReceiveAddress__c, SecondaryCollege__c, ReturnAddress__c 
            FROM TeachingSupplyReceiveAndReutrnContact__mdt
            WHERE Active__c = true
        ];
        // 将地点与联系信息的映射封装到Map
        Map<String,List<TeachingSupplyReceiveAndReutrnContact__mdt>> mapReceiveAndReutrnContactByLocation = new Map<String,List<TeachingSupplyReceiveAndReutrnContact__mdt>>();
        // 开始封装
        for (TeachingSupplyReceiveAndReutrnContact__mdt mdtReceiveAndReutrnContact : lstReceiveAndReutrnContact) {
            // 同一个教学地点可能有多个联系信息
            List<TeachingSupplyReceiveAndReutrnContact__mdt> lstReceiveAndReutrnContactByLocation = mapReceiveAndReutrnContactByLocation.get(mdtReceiveAndReutrnContact.Location__c);
            if (lstReceiveAndReutrnContactByLocation != null && lstReceiveAndReutrnContactByLocation.size() > 0){
                lstReceiveAndReutrnContactByLocation = mapReceiveAndReutrnContactByLocation.get(mdtReceiveAndReutrnContact.Location__c);
                lstReceiveAndReutrnContactByLocation.add(mdtReceiveAndReutrnContact);
                mapReceiveAndReutrnContactByLocation.put(mdtReceiveAndReutrnContact.Location__c, lstReceiveAndReutrnContactByLocation);
            }else{
                lstReceiveAndReutrnContactByLocation = new List<TeachingSupplyReceiveAndReutrnContact__mdt>();
                lstReceiveAndReutrnContactByLocation.add(mdtReceiveAndReutrnContact);
                mapReceiveAndReutrnContactByLocation.put(mdtReceiveAndReutrnContact.Location__c, lstReceiveAndReutrnContactByLocation);
            }
        }
        
        // 开始完成领取/归还联系信息赋值
        for (TeachingSupplyBorrowingApplication__c objBorrowing : lstBorrowingApplication){
            if (mapReceiveAndReutrnContactByLocation.get(objBorrowing.Location__c) != null){
                List<TeachingSupplyReceiveAndReutrnContact__mdt> lstReceiveAndReutrnContactByLocation = mapReceiveAndReutrnContactByLocation.get(objBorrowing.Location__c);
                // 当前地点下学院为空的联系信息
                TeachingSupplyReceiveAndReutrnContact__mdt mdtReceiveAndReutrnContactWithNullCollege;
                // 当前地点下与借用申请的学院相同的联系信息
                TeachingSupplyReceiveAndReutrnContact__mdt mdtReceiveAndReutrnContactWithSameCollege;
                for (TeachingSupplyReceiveAndReutrnContact__mdt mdtReceiveAndReutrnContact : lstReceiveAndReutrnContactByLocation) {
                    // 学院为空的联系信息
                    if (mdtReceiveAndReutrnContact.SecondaryCollege__c == null) {
                        mdtReceiveAndReutrnContactWithNullCollege = mdtReceiveAndReutrnContact;
                    }
                    // 与借用申请的学院相同的联系信息
                    if (mapSecondryCollage.get(objBorrowing.SecondaryCollegeLookup__c) != null && mdtReceiveAndReutrnContact.SecondaryCollege__c == mapSecondryCollage.get(objBorrowing.SecondaryCollegeLookup__c).Name) {
                        mdtReceiveAndReutrnContactWithSameCollege = mdtReceiveAndReutrnContact;
                    }
                }
                if (mdtReceiveAndReutrnContactWithSameCollege != null) {
                    objBorrowing.ReceiveContact__c = mdtReceiveAndReutrnContactWithSameCollege.ReceiveContact__c;
                    objBorrowing.ReceiveContactPhone__c = mdtReceiveAndReutrnContactWithSameCollege.ReceiveContactPhone__c;
                    objBorrowing.ReceiveAddress__c = mdtReceiveAndReutrnContactWithSameCollege.ReceiveAddress__c;
                    objBorrowing.ReturnContact__c = mdtReceiveAndReutrnContactWithSameCollege.ReturnContact__c;
                    objBorrowing.ReturnContactPhone__c = mdtReceiveAndReutrnContactWithSameCollege.ReturnContactPhone__c;
                    objBorrowing.ReturnAddress__c = mdtReceiveAndReutrnContactWithSameCollege.ReturnAddress__c;
                }
                else if (mdtReceiveAndReutrnContactWithNullCollege != null){
                    objBorrowing.ReceiveContact__c = mdtReceiveAndReutrnContactWithNullCollege.ReceiveContact__c;
                    objBorrowing.ReceiveContactPhone__c = mdtReceiveAndReutrnContactWithNullCollege.ReceiveContactPhone__c;
                    objBorrowing.ReceiveAddress__c = mdtReceiveAndReutrnContactWithNullCollege.ReceiveAddress__c;
                    objBorrowing.ReturnContact__c = mdtReceiveAndReutrnContactWithNullCollege.ReturnContact__c;
                    objBorrowing.ReturnContactPhone__c = mdtReceiveAndReutrnContactWithNullCollege.ReturnContactPhone__c;
                    objBorrowing.ReturnAddress__c = mdtReceiveAndReutrnContactWithNullCollege.ReturnAddress__c;
                }
                else{
                    objBorrowing.ReceiveContact__c = '请联系系统管理员配置"领取/归还联系信息"';
                }
            }else{
                objBorrowing.ReceiveContact__c = '请联系系统管理员配置"领取/归还联系信息"';
            }
        }
    }
}