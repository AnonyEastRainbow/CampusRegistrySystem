import { LightningElement, wire } from 'lwc';
import getTeachingSupplyEachTime from '@salesforce/apex/RS_Dashboard_Ctl.getTeachingSupplyEachTime';

export default class Rs_campusDashboard extends LightningElement {
    chartConfiguration;

    @wire(getTeachingSupplyEachTime)
    wiredGetTeachingSupplyEachTime({ error, data }) {
        if (error) {
            console.log('error => ', data);
            this.chartConfiguration = null;
        } else if (data) {
            console.log('data => ', data);
            this.chartConfiguration = {
                xAxis: data.data.xAxis,
                yAxis: {
                  type: 'value'
                },
                series: data.data.series
            };
        }
    }
}