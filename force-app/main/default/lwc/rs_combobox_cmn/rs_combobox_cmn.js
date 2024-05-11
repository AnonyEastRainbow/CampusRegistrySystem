import { LightningElement, track, api } from 'lwc';
 
export default class Rs_combobox_cmn extends LightningElement {
    
    options;
    @api selectedValue;
    @api selectedValues = [];
    @api label;
    @api disabled = false;
    @api multiSelect = false;
    @api pillIcon;
    @track value;
    @track values = [];
    @track optionData;
    @track searchString;
    @track noResultMessage;
    @track showDropdown = false;
 
    @api
    get optionList(){
        return this.options;
    }

    set optionList(value){
        this.options = value;
        let optionData = this.options ? (JSON.parse(JSON.stringify(this.options))) : null;
        let valueSingleSelected = this.selectedValue ? (JSON.parse(JSON.stringify(this.selectedValue))) : null;
        let valueMultiSelected = this.selectedValues ? (JSON.parse(JSON.stringify(this.selectedValues))) : null;
        if(valueSingleSelected || valueMultiSelected) {
            let searchString;
            let count = 0;
            for(let i = 0; i < optionData.length; i++) {
                if(this.multiSelect) {
                    if(valueMultiSelected.includes(optionData[i].value)) {
                        optionData[i].selected = true;
                        count++;
                    }  
                } else {
                    if(optionData[i].value === valueSingleSelected) {
                        searchString = optionData[i].label;
                    }
                }
            }
            if(this.multiSelect){
                this.searchString = count + ' 项已选择';
            }else{
                this.searchString = searchString;
            }
        }
        this.value = valueSingleSelected;
        this.values = valueMultiSelected;
        this.optionData = optionData;
    }
 
    filterOptions(event) {
        this.searchString = event.target.value;
        if( this.searchString && this.searchString.length > 0 ) {
            this.noResultMessage = '';
            if(this.searchString.length >= 1) {
                let flag = true;
                for(let i = 0; i < this.optionData.length; i++) {
                    if(this.optionData[i].label.toLowerCase().trim().includes(this.searchString.toLowerCase().trim())) {
                        this.optionData[i].isVisible = true;
                        flag = false;
                    } else {
                        this.optionData[i].isVisible = false;
                    }
                }
                if(flag) {
                    this.noResultMessage = "没有找到 '" + this.searchString + "'";
                }
            }
            this.showDropdown = true;
        } else {
            this.showDropdown = false;
        }
    }
 
    selectItem(event) {
        let selectedVal = event.currentTarget.dataset.id;
        if(selectedVal) {
            let count = 0;
            let options = JSON.parse(JSON.stringify(this.optionData));
            for(let i = 0; i < options.length; i++) {
                if(options[i].value === selectedVal) {
                    if(this.multiSelect) {
                        if(this.values.includes(options[i].value)) {
                            this.values.splice(this.values.indexOf(options[i].value), 1);
                        } else {
                            this.values.push(options[i].value);
                        }
                        options[i].selected = options[i].selected ? false : true;   
                    } else {
                        this.value = options[i].value;
                        this.searchString = options[i].label;
                    }
                }
                if(options[i].selected) {
                    count++;
                }
            }
            this.optionData = options;
            if(this.multiSelect){
                this.searchString = count + ' 项已选择';

                let ev = new CustomEvent('selectoption', {detail:this.values});
                this.dispatchEvent(ev);
            }
                

            if(!this.multiSelect){
                let ev = new CustomEvent('selectoption', {detail:this.value});
                this.dispatchEvent(ev);
            }

            if(this.multiSelect)
                event.preventDefault();
            else
                this.showDropdown = false;
        }
    }
 
    showOptions() {
        if(this.disabled === false && this.options) {
            this.noResultMessage = '';
            this.searchString = '';
            let options = JSON.parse(JSON.stringify(this.optionData));
            for(let i = 0; i < options.length; i++) {
                options[i].isVisible = true;
            }
            if(options.length > 0) {
                this.showDropdown = true;
            }
            this.optionData = options;
        }
    }

    @api clearAll() {
        this.values = [];
        let optionData = this.options ? (JSON.parse(JSON.stringify(this.options))) : null;
        for (let i = 0; i < optionData.length; i++) {
            if (this.multiSelect) {
                optionData[i].selected = false;
            }
        }
        this.searchString = 0 + ' 项已选择';
        this.selectedValues = [];
        this.optionData = optionData;
    }
 
    closePill(event) {
        let value = event.currentTarget.name;
        let count = 0;
        let options = JSON.parse(JSON.stringify(this.optionData));
        for(let i = 0; i < options.length; i++) {
            if(options[i].value === value) {
                options[i].selected = false;
                this.values.splice(this.values.indexOf(options[i].value), 1);
            }
            if(options[i].selected) {
                count++;
            }
        }
        this.optionData = options;
        if(this.multiSelect){
            this.searchString = count + ' 项已选择';
            
            let ev = new CustomEvent('selectoption', {detail:this.values});
            this.dispatchEvent(ev);
        }
    }
 
    handleBlur() {
        let previousLabel;
        let count = 0;

        for(let i = 0; i < this.optionData.length; i++) {
            if(this.optionData[i].value === this.value) {
                previousLabel = this.optionData[i].label;
            }
            if(this.optionData[i].selected) {
                count++;
            }
        }

        if(this.multiSelect){
            this.searchString = count + ' 项已选择';
        }else{
            this.searchString = previousLabel;
        }

        this.showDropdown = false;
    }

    handleOpenDropdown(){
        this.showDropdown = false;
    }

    handleCloseDropdown(){
        this.showDropdown = true;
    }
}