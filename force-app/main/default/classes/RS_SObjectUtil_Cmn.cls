/**
 * @description SObject工具类
 * @author: AnonyEast
 * @date: 2023-03-30
 */
public with sharing class RS_SObjectUtil_Cmn {
    /**
     * @description 获取用户对应的联系人信息和组织机构信息
     * @param setUserId 用户ID集合
     * 
     * @return lstUser 包含联系人字段、组织机构字段的用户对象列表
     */
    public static List<User> getUserDetailInfoList(Set<Id> setUserId) {
        List<User> lstUser = [
            SELECT 
                // 用户字段
                Id, Division, Department, Title, Address, Email, Phone, MobilePhone, ContactId, 
                // 学生所在组织机构字段(班级)
                Contact.Account.Id, Contact.Account.Name, Contact.Account.Owner.Id, Contact.Account.Owner.Name, Contact.Account.Owner.Email, 
                // 学生上级组织机构字段(二级学院)
                Contact.Account.Parent.Id, Contact.Account.Parent.Name, Contact.Account.Parent.Owner.Id, Contact.Account.Parent.Owner.Name, Contact.Account.Parent.Owner.Email, 
                // 学生字段
                Contact.Id, Contact.Name, Contact.Phone, Contact.Email, Contact.Title, Contact.Description, Contact.Grade__c, 
                Contact.ClassName__c, Contact.StudentNumber__c, Contact.SecondaryCollege__c, Contact.SecondaryCollege__r.Name, Contact.Profession__c, 
                Contact.Gender__c, Contact.StudentIdNumber__c, Contact.EducationalSystem__c, 
                Contact.CultureLevel__c, Contact.StudentStatus__c 
            FROM  
                User 
            WHERE 
                Id IN :setUserId 
        ];
        return lstUser;
    }

    public static Map<Id,User> getUserDetailInfoMap(Set<Id> setUserId) {
        return new Map<Id,User>(getUserDetailInfoList(setUserId));
    }

    @AuraEnabled(cacheable=true)
    public static User getUserDetailInfo(Id userId) {
        return getUserDetailInfoList(new Set<Id>{userId}).get(0);
    }

    /**
     * @description 获取学生对应的组织机构信息
     * @param setContactId 学生ID集合
     * 
     * @return lstContact 包含联系人字段、组织机构字段的联系人对象列表
     */
    public static List<Contact> getContactDetailInfoList(Set<Id> setContactId) {
        List<Contact> lstContact = [
            SELECT 
                // 学生字段
                Id, Name, Phone, Email, Title, Description, Grade__c, ClassName__c, StudentNumber__c, SecondaryCollege__c, SecondaryCollege__r.Name, Profession__c, 
                Gender__c, StudentIdNumber__c, EducationalSystem__c, CultureLevel__c, StudentStatus__c, 
                // 学生所在组织机构字段(班级)
                Account.Id, Account.Name, Account.Owner.Id, Account.Owner.Name, Account.Owner.Email, 
                // 学生上级组织机构字段(二级学院)
                Account.Parent.Id, Account.Parent.Name, Account.Parent.Owner.Id, Account.Parent.Owner.Name, Account.Parent.Owner.Email 
            FROM 
                Contact 
            WHERE 
                Id IN :setContactId 
        ];
        return lstContact;
    }

    public static Map<Id,Contact> getContactDetailInfoMap(Set<Id> setContactId) {
        return new Map<Id,Contact>(getContactDetailInfoList(setContactId));
    }

    public static Contact getContactDetailInfo(Id contactId) {
        return getContactDetailInfoList(new Set<Id>{contactId}).get(0);
    }

    /**
     * @description 二级学院ID映射
     * 
     * @return mapCollage
     */
    public static Map<Id,Account> getSecondryCollegeMap() {
        Map<Id,Account> mapSecondryCollage = new Map<Id,Account>([
            SELECT 
                Id, Name 
            FROM 
                Account 
            WHERE 
                Type = '教学科研单位' 
        ]);
        return mapSecondryCollage;
    }
}