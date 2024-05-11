import { LightningElement } from 'lwc';
import { api, track } from 'lwc';

export default class Rs_pagination_cmn extends LightningElement {
    totalCounts;  // 总记录数
    @api pagerCount = 7;  // 页码按钮数
    currentPage;  // 当前页码
    @api pageSize;  // 每页显示条数
    @api pageSizeList = [1, 3, 5, 10, 20, 30, 40, 50];  // 可选的每页显示条数

    @api
    get recordCount(){
        return this.totalCounts;
    }

    set recordCount(value){
        this.totalCounts = value;
        this.computePagers();
    }

    @api
    get pageNum(){
        return this.currentPage;
    }

    set pageNum(value){
        this.currentPage = value;
        this.computePagers();
    }
    
    // 每页显示条数(文本类型)
    get pageSizeText(){
        return String(this.pageSize);
    }

    // 总页数计算
    get pageCount() {
        if (typeof this.recordCount === 'number') {
            return Math.max(1, Math.ceil(this.recordCount / this.pageSize));
        }
        return null;
    }

    // 每页显示条数选项列表生成
    get pageSizes() {
        let pageSizeOptionList = [];
        this.pageSizeList.forEach((size) => {
            let pageSizeOption = {
                label: size + " 条/页",
                value: String(size)
            };
            pageSizeOptionList.push(pageSizeOption);
        });
        return pageSizeOptionList;
    }

    // 页码按钮组参数
    @track pagerSetting = {
        // 要显示的页码按钮
        pagers: [],
        // 上翻更多/下翻更多
        more: {
            showPrevMore: true,
            showNextMore: true,
            prevMoreIcon: 'action:more',
            nextMoreIcon: 'action:more',
        }
    }

    // 计算显示页码
    computePagers() {
        const pagerCount = this.pagerCount;
        const halfPagerCount = (pagerCount - 1) / 2;
        const currentPage = Number(this.currentPage);
        const pageCount = Number(this.pageCount);

        let showPrevMore = false;
        let showNextMore = false;

        if (pageCount > pagerCount) {
            if (currentPage > pagerCount - halfPagerCount) {
                showPrevMore = true;
            }
            if (currentPage < pageCount - halfPagerCount) {
                showNextMore = true;
            }
        }

        const array = [];
        let pager = {};
        if (showPrevMore && !showNextMore) {
            const startPage = pageCount - (pagerCount - 2);
            for (let i = startPage; i < pageCount; i++) {
                pager = { index: i, active: false, isEdge: false };
                array.push(pager);
            }
        } else if (!showPrevMore && showNextMore) {
            for (let i = 2; i < pagerCount; i++) {
                pager = { index: i, active: false, isEdge: false };
                array.push(pager);
            }
        } else if (showPrevMore && showNextMore) {
            const offset = Math.floor(pagerCount / 2) - 1;
            for (let i = currentPage - offset ; i <= currentPage + offset; i++) {
                pager = { index: i, active: false, isEdge: false };
                array.push(pager);
            }
        } else {
            for (let i = 2; i < pageCount; i++) {
                pager = { index: i, active: false, isEdge: false };
                array.push(pager);
            }
        }
        // 修改更多按钮显示
        this.pagerSetting.more.showPrevMore = showPrevMore;
        this.pagerSetting.more.showNextMore = showNextMore;
        // 插入第一页和最后一页
        pager = { index: 1, active: false, isEdge: true };
        array.unshift(pager);
        pager = { index: this.pageCount, active: false, isEdge: true };
        array.push(pager);
        // 页码按钮赋值
        this.pagerSetting.pagers = array;
        // 计算激活页
        this.computeActivePager();
    }

    // 设置激活页码状态和样式
    computeActivePager(){
        this.pagerSetting.pagers.forEach(pager => {
            if(pager.index === this.currentPage){
                pager.active = true;
                pager.variant = "brand"; 
            }else{
                pager.active = false;
                pager.variant = "neutral"; 
            }
        })
    }

    // 是否显示第一页按钮
    get showFirstPager(){
        return this.pageCount > 0;
    }
    // 是否显示最后一页按钮
    get showLastPager(){
        return this.pageCount > 1;
    }
    // 第一页按钮样式
    get firstPagerVariant(){
        return this.pagerSetting.pagers[0].variant;
    }
    // 最后一页按钮样式
    get lastPagerVariant(){
        return this.pagerSetting.pagers[this.pagerSetting.pagers.length - 1].variant;
    }

    // 鼠标悬停更多页码按钮
    handleMoreIconMouseenter(event){
        if(event.target.dataset.direction === "left"){
            this.pagerSetting.more.prevMoreIcon = "utility:back";
        }
        else if(event.target.dataset.direction === "right"){
            this.pagerSetting.more.nextMoreIcon = "utility:forward";
        }
    }

    // 鼠标离开更多页码按钮
    handleMoreIconMouseleave(){
        this.pagerSetting.more.prevMoreIcon = "action:more";
        this.pagerSetting.more.nextMoreIcon = "action:more";
    }

    // 点击页码按钮
    handlePagerClick(event){
        let newPage = Number(event.target.dataset.goto);
        let action = event.target.dataset.action;
        const currentPage = this.currentPage;
        const pagerCountOffset = this.pagerCount - 2;

        // 点击上一页/下一页/更多
        if(action === "prevPage"){
            newPage = currentPage - 1;
        } else if (action === "nextPage") {
            newPage = currentPage + 1;
        } else if (action === "prevMore") {
            newPage = currentPage - pagerCountOffset;
        } else if (action === "nextMore") {
            newPage = currentPage + pagerCountOffset;
        }

        if (!isNaN(newPage) && newPage !== currentPage) {
            this.handleCurrentPageChange(newPage);
        }
    }

    // 页码变更
    handleCurrentPageChange(val){
        // 调整页码为有效页码
        this.currentPage = this.getValidCurrentPage(val);
        // 重新计算页码按钮
        this.computePagers();
        // 发出页码变更事件
        this.emitChangeEvent();
    }

    // 发出页码变更事件
    emitChangeEvent(){
        this.dispatchEvent(
            new CustomEvent("pagechange",{
                detail: {
                    pageNum: this.currentPage,
                    pageSize: this.pageSize
                }
            })
        );
    }

    // 获取合法的当前页码
    getValidCurrentPage(value) {
        value = parseInt(value, 10);
        const havePageCount = typeof this.pageCount === 'number';
        let resetValue;
        if (!havePageCount) {
            if (isNaN(value) || value < 1) {
                resetValue = 1;
            }
        } else {
            if (value < 1) {
              resetValue = 1;
            } else if (value > this.pageCount) {
              resetValue = this.pageCount;
            }
        }

        if (resetValue === undefined && isNaN(value)) {
            resetValue = 1;
        } else if (resetValue === 0) {
            resetValue = 1;
        }

        return resetValue === undefined ? value : resetValue;
    }

    // 每页显示条数变更
    handleSizeChange(event){
        if(this.pageSize !== Number(event.detail.value)){
            this.pageSize = Number(event.detail.value);
            this.handleCurrentPageChange(1);
        }
    }

    // 输入页码
    inputPage;
    handleInputPageChange(event) {
        this.inputPage = Number(event.detail.value);
    }
    
    // 输入页码后按下键盘
    handleInputPageKeyup(event) {
        // 按回车键切换页码
        if (event.keyCode === 13) {
            this.handleCurrentPageChange(this.inputPage);
        }
    }

    connectedCallback() {
        this.emitChangeEvent();
    }

    renderedCallback(){
        
    }
}