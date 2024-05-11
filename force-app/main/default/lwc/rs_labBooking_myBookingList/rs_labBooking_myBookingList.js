import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import getMyBooking from '@salesforce/apex/RS_LabBooking_Ctl.getMyBooking';
import cancelBookingRequest from '@salesforce/apex/RS_LabBooking_Ctl.cancelBookingRequest';
import getApprovalSteps from '@salesforce/apex/RS_LabBooking_Ctl.getApprovalSteps';

export default class Rs_labBooking_myBookingList extends LightningElement {
    totalCounts;  // 总记录数
    pageNum = 1;  // 当前页码
    pageSize = 10;  // 返回条数
    isLoading = false;  // 加载动画

    myBookingTableColumns = [
        { label: '地点', fieldName: 'Location__c' },
        { label: '地址', fieldName: 'LabAddress__c'},
        { label: '预约时段', fieldName: 'BookingPeriod__c'},
        { label: '提交时间', fieldName: 'CreatedDate'},
        { label: '审批人', fieldName: 'X1stApproverName'},
        { 
            label: '批准状态', 
            fieldName: 'ApprovalStatus__c',
            cellAttributes: {
                class: { fieldName: "ApprovalStatusStyle" },
                iconName: { fieldName: "ApprovalStatusIcon" },
                iconPosition: "left",
            },
        },
        { label: '状态更新时间', fieldName: 'LastModifiedDate'},
        {
            label: "操作",
            type:"button",
            fixedWidth: 100,
            typeAttributes: {
                label: '查看',
                name: 'viewDetail',
                variant: 'brand',
                iconName: 'action:info'
            }
        },
        {
            label: "",
            type:"button",
            fixedWidth: 130,
            typeAttributes: {
                label: '取消预约',
                name: 'cancelBooking',
                variant: 'destructive',
                disabled: { fieldName: 'isDisabledCancelBooking' },
                iconName: 'utility:undo'
            }
        },
    ];

    approvalInfoTableColumns = [
        { label: '步骤', fieldName: 'stepName' },
        { label: '状态', fieldName: 'status'},
        { label: '分配审批人', fieldName: 'originalApprover'},
        { label: '实际操作人', fieldName: 'approver'},
        { label: '评论', fieldName: 'comments', wrapText: true},
        { label: '时间', fieldName: 'createdTime'},
    ];

    // 我的预约信息
    @track myBookingList = [];

    // 预约详情窗口
    @track bookingDetailInfo = {
        isShowDetailDialog: false,  // 显示确认预约对话框
        isLoading: false,
        labApplication:{},
        lab:{
            recordId: "",
            isLoading: false
        },
        approval:{
            stepList: [],
            isLoading: false
        },
        activeSections: ["bookingInfo", "labInfo", "approvalInfo"]
    }

    /**
     * 处理按钮点击
     * event.detail.action.name => Returns the value of the name set in typeAttributes.
     * event.detail.row => Returns an Object with the values of the row.
     * event.detail.row.columnFieldName => Returns the value in an specific column.
     */
    handleRowAction(event){
        const action = event.detail.action;
        // 当前行信息
        const row = event.detail.row;
        switch(action.name){
            // 查看详情
            case "viewDetail":
                console.log('action -> viewDetail',row.Id);
                this.handleViewDetail(row);
                break;
            // 取消预约
            case "cancelBooking":
                console.log('action -> cancelBooking',row.Id);
                this.handleCancelBooking(row);
                break;
            default:
                break;
        }
    }

    // 页码变更
    handlePageChange(event){
        if(!isNaN(event.detail.pageNum) && !isNaN(event.detail.pageSize)){
            this.pageNum = Number(event.detail.pageNum);
            this.pageSize = Number(event.detail.pageSize);
        }else{
            this.pageNum = 1;
            this.pageSize = 10;
        }
        this.getMyBookingList();
    }

    // 获取可预约的实验室
    @api
    getMyBookingList(){
        this.isLoading = true;
        let params = {
            intPageNum: this.pageNum,
            intPageSize: this.pageSize
        }
        getMyBooking(params)
            .then(result => {
                if (result.status === 'OK') {
                    this.myBookingList = result.data.map(myBooking => {
                        let ApprovalStatusStyle; // 批准状态单元格样式
                        let ApprovalStatusIcon; // 批准状态单元格图标
                        if(myBooking.X1stApprover__r !== null && myBooking.X1stApprover__r !== undefined && myBooking.X1stApprover__r.Name.length > 0){
                            myBooking.X1stApproverName = myBooking.X1stApprover__r.Name;
                        }
                        switch(myBooking.ApprovalStatus__c){
                            case "审批中":
                                ApprovalStatusIcon = "action:submit_for_approval";
                                break;
                            case "已批准":
                                ApprovalStatusIcon = "action:approval";
                                ApprovalStatusStyle = "slds-text-color_success"
                                break;
                            case "已取消":
                                ApprovalStatusIcon = "action:recall";
                                break;
                            case "已拒绝":
                                ApprovalStatusIcon = "action:close";
                                ApprovalStatusStyle = "slds-text-color_error"
                                break;
                            default:
                                break;
                        }
                        return {...myBooking, 
                            "ApprovalStatusStyle":ApprovalStatusStyle,
                            "ApprovalStatusIcon":ApprovalStatusIcon,
                        }
                    });
                    this.totalCounts = result.totalCounts;
                    console.log("myBookingList -> ",this.myBookingList);
                }
                else {
                    console.error("getMyBookingList Error -> ",result.message);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'getMyBookingList Error',
                            message: result.message,
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(error => {
                console.error("getMyBookingList Error -> ",error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'getMyBookingList Error',
                        message: error,
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    // 点击查看详情
    handleViewDetail(row){
        // 基本信息赋值
        this.bookingDetailInfo.labApplication = row;
        // 实验室Id赋值
        this.bookingDetailInfo.lab.recordId = row.BookedLab__c;
        this.bookingDetailInfo.isShowDetailDialog = true;
        this.bookingDetailInfo.lab.isLoading = true;
        // 获取批准过程
        this.getApprovalDetail();
    }

    // 实验室信息加载完成
    handleLabInfoLoaded(){
        this.bookingDetailInfo.lab.isLoading = false;
    }

    // 获取批准过程步骤
    getApprovalDetail(){
        this.bookingDetailInfo.approval.isLoading = true;
        let params = {
            labApplicationId: this.bookingDetailInfo.labApplication.Id,
        }
        getApprovalSteps(params)
        .then(result => {
            if (result.status === 'OK') {
                result.data.forEach(step => {
                    switch(step.status){
                        case "Pending":
                            step.status = "审批中"
                            break;
                        case "Approved":
                            step.status = "已批准"
                            break;
                        case "Rejected":
                            step.status = "已拒绝"
                            break;
                        case "Removed":
                            step.status = "已撤回"
                            break;
                        default:
                            break;
                    }
                });
                this.bookingDetailInfo.approval.stepList = result.data;
                console.log("stepList -> ",this.bookingDetailInfo.approval.stepList);
            }
            else {
                console.error("getApprovalSteps Error -> ",result.message);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'getApprovalSteps Error',
                        message: result.message,
                        variant: 'error'
                    })
                );
            }
        })
        .catch(error => {
            console.error("getApprovalSteps Error -> ",error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'getApprovalSteps Error',
                    message: error,
                    variant: 'error'
                })
            );
        })
        .finally(() => {
            this.bookingDetailInfo.approval.isLoading = false;
        });
    }

    // 关闭查看详情
    handleDetailClose(){
        this.bookingDetailInfo.isShowDetailDialog = false;
    }

    // 取消预约
    async handleCancelBooking(row){
        // 确认取消对话框
        const confirmResult = await LightningConfirm.open({
            label: '取消预约',
            message: '取消预约后，名额将被释放，确认取消？',
            variant: 'header',
            theme: "warning"
            // setting theme would have no effect
        });
        if(confirmResult){
            cancelBookingRequest({ labBookingApplicationId: row.Id })
                .then(result => {
                    if (result.status === 'OK') {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: '取消预约成功',
                                variant: 'success'
                            })
                        );
                        this.myBookingList.forEach(myBooking => {
                            if(myBooking.Id === row.Id){
                                myBooking.isDisabledCancelBooking = true;
                                myBooking.ApprovalStatus__c = '已取消';
                            }
                        });
                        console.log("myBookingList ->",this.myBookingList);
                        this.myBookingList = this.myBookingList.slice();
                    }else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: '取消预约失败',
                                message: result.message,
                                variant: 'error'
                            })
                        );
                    }
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'handleCancelBooking Error',
                            message: error,
                            variant: 'error'
                        })
                    );
                    console.error("handleCancelBooking Error -> ",error);
                })
                .finally(() => {
                    
                });
        }
    }
}