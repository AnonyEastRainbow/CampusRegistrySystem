import { LightningElement,api } from 'lwc';

export default class Rs_loadingPlaceHolder_cmn extends LightningElement {
  @api
  rowNumber
  
  get rows() {
    const number = Number(this.rowNumber);
    var row = {}
    var rows = []
    for(let i = 0; i < number; i++) {
      row.id = i
      rows.push(row)
    }
    return rows
  }
}