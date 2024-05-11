import { LightningElement,api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import LEAVE_DAYS_FIELD from '@salesforce/schema/LeaveApplication__c.LeaveDays__c';
import getApprovalSteps from '@salesforce/apex/RS_Leave_Ctl.getApprovalSteps';


export default class Rs_leave_approvalProgress extends LightningElement {
    @api recordId;

    @track currentLeaveApplication;
    
    // 批准进程信息
    @track approvalProgress = {
        isLoading:false,
        steps: [],
        currentStep: "Draft",
        clickedStepDetail:{
            isShow:false,
            info:{}
        },
    };

    // 获取当前记录的请假天数
    @wire(getRecord, { recordId: '$recordId', fields: [LEAVE_DAYS_FIELD] })
    wiredCurrentLeaveApplication({ error, data }){
        this.approvalProgress.clickedStepDetail.isShow = false;
        if (data) {
            this.currentLeaveApplication = data;
            // 重新获取批准进程
            this.getApprovalProgress();
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'getCurrentLeaveApplication Error',
                    message: error,
                    variant: 'error'
                })
            );
            console.error("getCurrentLeaveApplication Error -> ",error);
        }
    }

    // 获取批准进程
    async getApprovalProgress(){
        this.approvalProgress.isLoading = true;
        // 批准步骤
        let approvalStepList = [];
        // 当前步骤
        let currentStep = 'Draft';
        let params = {
            leaveId: this.recordId
        }
        // 获取批准步骤
        await getApprovalSteps(params)
            .then(result => {
                if (result.status === 'OK') {
                    if(this.currentLeaveApplication !== undefined && this.currentLeaveApplication !== null) {
                        if(Number(this.currentLeaveApplication.fields.LeaveDays__c.value) > 0) {
                            approvalStepList.push({ label: '班主任审批', value: '班主任审批' });
                        }
                        if(Number(this.currentLeaveApplication.fields.LeaveDays__c.value) > 3) {
                            approvalStepList.push({ label: '二级学院审批', value: '二级学院审批' });
                        }
                        if(Number(this.currentLeaveApplication.fields.LeaveDays__c.value) > 7) {
                            approvalStepList.push({ label: '教务处审批', value: '教务处审批' });
                        }
                        // 批准步骤赋值
                        for(let i = 0; i < result.data.length && i < approvalStepList.length; i++){
                            approvalStepList[i].label = result.data[i].stepName;
                            approvalStepList[i].value = result.data[i].stepName;
                            if (result.data[i].status === "Pending"){
                                approvalStepList[i].status = "审批中";
                            }else if (result.data[i].status === "Approved"){
                                approvalStepList[i].status = "已批准";
                            }else if (result.data[i].status === "Rejected"){
                                approvalStepList[i].status = "已拒绝";
                            }else if (result.data[i].status === "Removed"){
                                approvalStepList[i].status = "已撤回";
                            }
                            approvalStepList[i].originalApprover = result.data[i].originalApprover;
                            approvalStepList[i].approver = result.data[i].approver;
                            approvalStepList[i].comments = result.data[i].comments;
                            approvalStepList[i].time = result.data[i].createdTime;
                        }
                        // 倒序遍历批准步骤
                        for(let i = approvalStepList.length - 1; i >= 0; i--){
                            if(approvalStepList[i].status === undefined || approvalStepList[i].status === null){
                                continue;
                            }
                            // 最终批准通过
                            else if(approvalStepList[i].status === "已批准"){
                                currentStep = "Closed";
                                break;
                            }
                            // 最终拒绝
                            else if(["已拒绝","已撤回"].includes(approvalStepList[i].status)){
                                currentStep = approvalStepList[i].value;
                                approvalStepList[i].isLost = true;
                                break;
                            }
                            // 审批中
                            else if(approvalStepList[i].status === "审批中"){
                                currentStep = approvalStepList[i].value;
                                break;
                            }
                        }
                    }
                }
                else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'getApprovalSteps Error',
                            message: result.message,
                            variant: 'error'
                        })
                    );
                    console.error("getApprovalSteps Error -> ",result.message);
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'getApprovalSteps Error',
                        message: error,
                        variant: 'error'
                    })
                );
                console.error("getApprovalSteps Error -> ",error);
            })
            .finally(() => {
                const approvalStartSteps = [{ label: '草稿', value: 'Draft' },{ label: '提交待审批', value: 'Submited' }];
                const approvalEndSteps = [{ label: '批准通过', value: 'Closed' }];
                // 连接批准步骤
                this.approvalProgress.steps = [...approvalStartSteps, ...approvalStepList, ...approvalEndSteps];
                this.approvalProgress.currentStep = currentStep;
            });
        // 渲染被驳回的步骤
        this.renderRejectedStep();
        this.approvalProgress.isLoading = false;
    }
    
    // 渲染审批被驳回的步骤
    renderRejectedStep(){
        this.approvalProgress.steps.forEach(item => {
            if(item.isLost === true){
                const lostStepDom = this.template.querySelector(`lightning-progress-step[data-step=${item.value}]`);
                // 该步骤背景显示为红色
                lostStepDom.classList.add('slds-is-lost');
                // 该步骤文字显示为白色
                lostStepDom.style.setProperty('--lwc-colorTextPathCurrent', 'rgb(255,255,255)');
                lostStepDom.style.setProperty('--lwc-colorTextPathCurrentHover', 'rgb(255,255,255)');
            }
        })
    }

    // 点击批准步骤
    handleClickStep(event){
        if(!['Draft','Submited','Closed'].includes(event.target.dataset.step)){
            this.getApprovalProgress();
            this.approvalProgress.steps.forEach(item => {
                // 点击的是同一个
                if(Object.keys(this.approvalProgress.clickedStepDetail.info).length !== 0 && this.approvalProgress.clickedStepDetail.info.value === event.target.dataset.step && item.value === event.target.dataset.step){
                    this.approvalProgress.clickedStepDetail.info = item;
                    this.approvalProgress.clickedStepDetail.isShow = !this.approvalProgress.clickedStepDetail.isShow;
                }
                // 点击的是另一个
                else if(item.value === event.target.dataset.step){
                    this.approvalProgress.clickedStepDetail.info = item;
                    this.approvalProgress.clickedStepDetail.isShow = true;
                }
            })
        }
        // 点击的是草稿/提交/批准通过
        else{
            this.approvalProgress.clickedStepDetail.isShow = false;
        }
    }

    renderedCallback(){
        
    }
}