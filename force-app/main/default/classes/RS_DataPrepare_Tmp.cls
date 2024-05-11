public with sharing class RS_DataPrepare_Tmp {
    
    public static void insertClassTimesScheduleToCustomMetadata(){
        // 数据准备
        Map<String,List<String>> mapClassTimesScheduleToInsert = new Map<String,List<String>>();
        mapClassTimesScheduleToInsert.put('X1stClassTimesSchedule', new List<String>{'1','08:20','09:05'});
        mapClassTimesScheduleToInsert.put('X2ndClassTimesSchedule', new List<String>{'2','09:15','10:00'});
        mapClassTimesScheduleToInsert.put('X3rdClassTimesSchedule', new List<String>{'3','10:20','11:05'});
        mapClassTimesScheduleToInsert.put('X4thClassTimesSchedule', new List<String>{'4','11:15','12:00'});
        mapClassTimesScheduleToInsert.put('X5thClassTimesSchedule', new List<String>{'5','13:50','14:35'});
        mapClassTimesScheduleToInsert.put('X6thClassTimesSchedule', new List<String>{'6','14:45','15:30'});
        mapClassTimesScheduleToInsert.put('X7thClassTimesSchedule', new List<String>{'7','15:50','16:35'});
        mapClassTimesScheduleToInsert.put('X8thClassTimesSchedule', new List<String>{'8','16:45','17:30'});
        mapClassTimesScheduleToInsert.put('X9thClassTimesSchedule', new List<String>{'9','19:00','19:45'});
        mapClassTimesScheduleToInsert.put('X10thClassTimesSchedule', new List<String>{'10','19:55','20:40'});
        mapClassTimesScheduleToInsert.put('X11thClassTimesSchedule', new List<String>{'11','20:50','21:35'});

        // 创建Metadata部署容器
        Metadata.DeployContainer mdtContainer = new Metadata.DeployContainer();

        // 准备要部署的数据
        Set<String> setClassTimesScheduleKey = mapClassTimesScheduleToInsert.keySet();
        for(String classTimesScheduleKey : setClassTimesScheduleKey){
            List<String> lstClassTimesSchedule = mapClassTimesScheduleToInsert.get(classTimesScheduleKey);
            System.debug('lstClassTimesSchedule->' + lstClassTimesSchedule);
            // 创建CustomMetadata实例
            Metadata.CustomMetadata mdtInstance =  new Metadata.CustomMetadata();
            mdtInstance.fullName = 'ClassTimesSchedule__mdt.' + classTimesScheduleKey;
            mdtInstance.label = '第' + lstClassTimesSchedule.get(0) +'节';
            
            // 为CustomMetadata实例的字段赋值
            Metadata.CustomMetadataValue mdtvalueClassTimes = new Metadata.CustomMetadataValue();
            mdtvalueClassTimes.field = 'ClassTimes__c';
            mdtvalueClassTimes.value = Integer.valueOf(lstClassTimesSchedule.get(0));
            mdtInstance.values.add(mdtvalueClassTimes);

            Metadata.CustomMetadataValue mdtvalueClassStartTime = new Metadata.CustomMetadataValue();
            mdtvalueClassStartTime.field = 'ClassStartTime__c';
            mdtvalueClassStartTime.value = lstClassTimesSchedule.get(1);
            mdtInstance.values.add(mdtvalueClassStartTime);

            Metadata.CustomMetadataValue mdtvalueClassEndTime = new Metadata.CustomMetadataValue();
            mdtvalueClassEndTime.field = 'ClassEndTime__c';
            mdtvalueClassEndTime.value = lstClassTimesSchedule.get(2);
            mdtInstance.values.add(mdtvalueClassEndTime);

            // 添加实例到部署容器
            mdtContainer.addMetadata(mdtInstance);
        }
        System.debug('mdtContainer->' + mdtContainer);
        // 执行部署
        Metadata.Operations.enqueueDeployment(mdtContainer, null);
    }

    public static void updateLeaveApplicationLookup(){
        // 查询二级学院
        List<Account> lstCollege = [
            SELECT 
                Id,Name
            FROM 
                Account
            WHERE 
                Type = '教学科研单位'
        ];
        Map<String,Id> mapCollageToId = new Map<String,Id>();
        for(Account acc : lstCollege){
            mapCollageToId.put(acc.Name, acc.Id);
        }
        System.debug('mapCollageToId -> ' + mapCollageToId);

        // 查询班级
        List<Account> lstClass = [
            SELECT 
                Id,Name
            FROM 
                Account
            WHERE 
                Type = '二级学院班级'
        ];
        Map<String,Id> mapClassToId = new Map<String,Id>();
        for(Account acc : lstClass){
            mapClassToId.put(acc.Name, acc.Id);
        }
        System.debug('mapClassToId -> ' + mapClassToId);

        // 查询学生
        List<Contact> lstStudent = [
            SELECT 
                Id,Name,StudentNumber__c
            FROM 
                Contact
        ];
        Map<String,Id> mapStudentNumberToId = new Map<String,Id>();
        for(Contact cont : lstStudent){
            mapStudentNumberToId.put(cont.StudentNumber__c, cont.Id);
        }
        System.debug('mapStudentNumberToId -> ' + mapStudentNumberToId);
    }
}