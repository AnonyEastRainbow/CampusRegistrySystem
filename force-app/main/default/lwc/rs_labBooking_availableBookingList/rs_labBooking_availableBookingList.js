import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CURRENT_USER_ID from '@salesforce/user/Id';
import LAB_BOOKING_OBJECT from '@salesforce/schema/LabBooking__c';
import LOCATION_FIELD from '@salesforce/schema/LabBooking__c.Location__c';
import LAB_TYPE_FIELD from '@salesforce/schema/LabBooking__c.LabType__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getUserDetailInfo from '@salesforce/apex/RS_SObjectUtil_Cmn.getUserDetailInfo';
import getAvailableBooking from '@salesforce/apex/RS_LabBooking_Ctl.getAvailableBooking';
import bookingRequest from '@salesforce/apex/RS_LabBooking_Ctl.bookingRequest';

export default class Rs_labBooking_availableBookingList extends LightningElement {
    totalCounts;  // 总记录数
    pageNum = 1;  // 当前页码
    pageSize = 9;  // 返回条数
    pageSizeList = [6, 9, 12];  // 每页显示条数
    isLoading = false;  // 显示加载动画

    // 筛选条件
    @track searchFilter = {
        locationOptions: [],
        locationSelected: [],
        labTypeOptions: [],
        labTypeSelected: [],
        labEquipment:'',
        noNeedApproval: false,
        openingTime: null,
        closingTime: null,
        bookingStartTime: null,
        bookingEndTime: null
    }

    // 可预约列表
    @track availableBookingList;

    // 确认预约信息
    @track confirmBookingInfo = {
        isShowConfirmDialog: false,  // 显示确认预约对话框
        isLoading: false,
        lab:{},
        contact:{
            recordId: "",
            isLoading: false
        },
        activeSections:["labInfo","userInfo"]
    }

    // 当前用户信息
    @wire(getUserDetailInfo, { userId: CURRENT_USER_ID })
    currentUserInfo;

    // 实验室预约对象元数据
    @wire(getObjectInfo, { objectApiName: LAB_BOOKING_OBJECT })
    labBookingMetadata;

    // 获取实验室地点
    @wire(getPicklistValues, { recordTypeId: '$labBookingMetadata.data.defaultRecordTypeId', fieldApiName: LOCATION_FIELD })
    wiredLabLocationPicklist({ error, data }){
        if (data) {
            this.searchFilter.locationOptions = [...data.values];
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'getLabLocationPicklist Error',
                    message: error,
                    variant: 'error'
                })
            );
            console.error("getLabLocationPicklist Error -> ",error);
        }
    }

    // 获取场地类别
    @wire(getPicklistValues, { recordTypeId: '$labBookingMetadata.data.defaultRecordTypeId', fieldApiName: LAB_TYPE_FIELD })
    wiredLabTypePicklist({ error, data }){
        if (data) {
            this.searchFilter.labTypeOptions = [...data.values];
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'getLabTypePicklist Error',
                    message: error,
                    variant: 'error'
                })
            );
            console.error("getLabTypePicklist Error -> ",error);
        }
    }

    // 选择地点
    handleLocationSelect(event){
        this.searchFilter.locationSelected = event.detail;
    }

    // 选择场地类别
    handleLabTypeSelect(event){
        this.searchFilter.labTypeSelected = event.detail;
    }
    
    // 输入值
    handleFilterInput(event){
        this.searchFilter[event.target.name] = event.detail.checked || event.detail.value;
        if(['locationSelected','labTypeSelected','approvalStatusSelected'].includes(event.target.name)){
            this.searchFilter[event.target.name] = event.detail;
        }
        console.log('this.searchFilter -> ',this.searchFilter);
    }

    // 点击搜索
    handleClickSearch(){
        this.pageNum = 1;
        this.getAvailableBookingList();
    }

    // 点击重置
    handleClickReset(){
        this.pageNum = 1;
        this.template.querySelectorAll('c-rs_combobox_cmn').forEach(dom => {
            dom.clearAll();
        });
        this.searchFilter.locationSelected = [];
        this.searchFilter.labTypeSelected = [];
        this.searchFilter.labEquipment = '';
        this.searchFilter.noNeedApproval = false;
        this.searchFilter.openingTime = null;
        this.searchFilter.closingTime = null;
        this.searchFilter.bookingStartTime = null;
        this.searchFilter.bookingEndTime = null;
        this.getAvailableBookingList();
    }

    // 页码变更
    handlePageChange(event){
        if(!isNaN(event.detail.pageNum) && !isNaN(event.detail.pageSize)){
            this.pageNum = Number(event.detail.pageNum);
            this.pageSize = Number(event.detail.pageSize);
        }else{
            this.pageNum = 1;
            this.pageSize = 9;
        }
        this.getAvailableBookingList();
    }

    // 获取可预约的实验室
    @api
    getAvailableBookingList(){
        this.isLoading = true;
        let params = {
            intPageNum: this.pageNum,
            intPageSize: this.pageSize,
            lstLocation: this.searchFilter.locationSelected,
            lstLabType: this.searchFilter.labTypeSelected,
            lstApprovalStatus: this.searchFilter.approvalStatusSelected,
            strLabEquipment: this.searchFilter.labEquipment,
            boolNoNeedApproval: this.searchFilter.noNeedApproval,
            dtOpeningDate: this.searchFilter.openingTime,
            dtClosingDate: this.searchFilter.closingTime,
            dtBookingStartDate: this.searchFilter.bookingStartTime,
            dtBookingEndDate: this.searchFilter.bookingEndTime
        }
        getAvailableBooking(params)
            .then(result => {
                if (result.status === 'OK') {
                    result.data.forEach(availableBooking => {
                        const isDuringDate = this.isDuringDate(availableBooking.BookingStartTime__c, availableBooking.BookingEndTime__c);
                        const userBookingStatus = availableBooking.userBookingStatus;
                        // 人数状态
                        if(availableBooking.BookedNumber__c < availableBooking.Capacity__c){
                            availableBooking.isFull = false;
                        }else{
                            availableBooking.isFull = true;
                        }
                        // 时间状态
                        if(isDuringDate < 0){
                            let badge = {
                                label: "未开始",
                                class: "slds-badge_lightest"
                            }
                            availableBooking.timeStatus = badge;
                        }else if(isDuringDate === 0){
                            let badge = {
                                label: "可预约",
                                class: "slds-badge_inverse"
                            }
                            availableBooking.timeStatus = badge;
                        }else if(isDuringDate > 0){
                            let badge = {
                                label: "已过期",
                                class: "slds-badge_lightest"
                            }
                            availableBooking.timeStatus = badge;
                        }
                        // 用户状态
                        if(userBookingStatus === "Pending"){
                            let badge = {
                                label: "审批中",
                                class: "slds-theme_warning"
                            }
                            availableBooking.bookingStatus = badge;
                        }else if(userBookingStatus === "Approved"){
                            let badge = {
                                label: "已预约",
                                class: "slds-theme_success"
                            }
                            availableBooking.bookingStatus = badge;
                        }else if(userBookingStatus === "Rejected"){
                            let badge = {
                                label: "已拒绝",
                                class: "slds-theme_error"
                            }
                            availableBooking.bookingStatus = badge;
                        }else if(userBookingStatus === "Canceled"){
                            let badge = {
                                label: "已取消",
                                class: "slds-badge"
                            }
                            availableBooking.bookingStatus = badge;
                        }
                        // 审批人
                        if(availableBooking.X1stApprover__r !== null && availableBooking.X1stApprover__r !== undefined && availableBooking.X1stApprover__r.Name.length > 0){
                            availableBooking.X1stApproverName = availableBooking.X1stApprover__r.Name;
                        }
                    });
                    this.availableBookingList = result.data;
                    this.totalCounts = result.totalCounts;
                    console.log("availableBookingList -> ",this.availableBookingList);
                }
                else {
                    console.log(result);
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'getAvailableBooking Error',
                        message: error,
                        variant: 'error'
                    })
                );
                console.error("getAvailableBookingList Error -> ",error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    // 点击预约按钮
    handleClickBooking(event){
        let bookingId = event.currentTarget.dataset.id;
        this.confirmBookingInfo.isShowConfirmDialog = true;
        // 实验室信息赋值
        this.availableBookingList.forEach(availableBooking => {
            if(availableBooking.Id === bookingId){
                this.confirmBookingInfo.lab = availableBooking;
            }
        });
    }

    // 用户信息加载完成
    handleUserInfoLoaded(){
        this.confirmBookingInfo.contact.isLoading = false;
    }

    // 在确认预约窗口点击取消
    handleCancelConfirm(){
        this.confirmBookingInfo.isShowConfirmDialog = false;
    }

    // 在确认预约窗口点击确定：确认预约
    handleConfirmedBooking(){
        let bookingId = this.confirmBookingInfo.lab.Id;
        this.confirmBookingInfo.isLoading = true;
        console.log('Booking Action -> Booking Id -> ', bookingId);
        bookingRequest({ labBookingId: bookingId })
            .then(result => {
                if (result.status === 'OK') {
                    console.log(result);
                    this.availableBookingList.forEach(availableBooking => {
                        if(availableBooking.Id === bookingId){
                            availableBooking.BookedNumber__c += 1;
                            if(availableBooking.BookedNumber__c >= availableBooking.Capacity__c){
                                availableBooking.isDisabledBookable = true;
                            }
                        }
                    });
                    this.availableBookingList = this.availableBookingList.slice();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: '提交成功',
                            message: '已提交预约申请，审批通过后会发送邮件通知。',
                            variant: 'success'
                        })
                    );
                }
                else {
                    console.log(result);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: '预约失败',
                            message: result.message,
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(error => {
                console.error("handleBooking Error -> ",error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'handleBooking Error',
                        message: error,
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.confirmBookingInfo.isLoading = false;
                this.confirmBookingInfo.isShowConfirmDialog = false;
                this.getAvailableBookingList();
            });
            
    }

    // 当前时间是否在指定范围
    isDuringDate(beginDateTime,endDateTime){
        let now = new Date();
        beginDateTime = new Date(beginDateTime);
        endDateTime = new Date(endDateTime);
        // 未到开始时间
        if(now < beginDateTime){
            return -1;
        }
        // 在时间范围内
        else if(now >= beginDateTime && now <= endDateTime){
            return 0;
        }
        // 超过结束时间
        else if(now > endDateTime){
            return 1;
        }
        return null;
    }

    renderedCallback(){
        
    }
}