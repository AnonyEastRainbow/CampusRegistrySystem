import { LightningElement,api } from 'lwc';

/**
 * @author Anony AA Yang
 * @date 2023-08-24
 * @description Pop up a dialog box
 */
export default class Rs_dialog_cmn extends LightningElement {
    @api title;

    _headerTheme;
    @api
    get theme(){
        return this._headerTheme;
    }
    set theme(value){
        /**
         * default: 灰白条纹(浅);
         * shade: 灰白条纹(深一点);
         * inverse: 深蓝;
         * alt-inverse: 深蓝(稍微浅一点);
         * success: 绿色;
         * info: 浅灰;
         * warning: 黄色;
         * error: 红色;
         * offline: 深灰;
         */ 
        const validThemeList = ["default","shade","inverse","alt-inverse","success","info","warning","error","offline"];
        if(validThemeList.includes(value)){
            this._headerTheme = value;
        }else{
            this._headerTheme = "default";
        }
    }

    _modalSize;
    @api
    get size(){
        return this._modalSize;
    }
    set size(value){
        const validSizeList = ["xx-small","x-small","small","medium","large"];
        if(validSizeList.includes(value)){
            this._modalSize = value;
        }else{
            this._modalSize = null;
        }
    }

    get closeButtonVariant(){
        if(['default','shade'].includes(this.theme)){
            return 'bare';
        }
        return 'bare-inverse';
    }

    renderedCallback(){
        // 添加控制窗口大小的Class
        if(this.size){
            const modal = this.template.querySelector(".dialog-modal");
            modal.classList.add("slds-modal_" + this.size);
        }
        // 添加控制标题主题色的Class
        const header = this.template.querySelector(".dialog-header");
        header.classList.add("slds-theme_" + this.theme);
    }

    handleClose(){
        this.dispatchEvent(new CustomEvent('close'));
    }
}