import { LightningElement, api } from 'lwc';
import ECHARTS from '@salesforce/resourceUrl/echarts';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Rs_genEchart_cmn extends LightningElement {
    @api chartConfig;
 
    isEchartsInitialized;
    renderedCallback() {
        if (this.isEchartsInitialized) {
            return;
        }
        // load ECharts from the static resource
        Promise.all([loadScript(this, ECHARTS)])
            .then(() => {
                this.runEcharts();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading Chart',
                        message: error.message,
                        variant: 'error',
                    })
                );
            });
    }

    runEcharts() {
        let myChart = echarts.init(this.template.querySelector('div.echart'));
        console.log('this.chartConfig ->',JSON.stringify(this.chartConfig));
        var option = {
            color: ['#3398DB'],
            xAxis: {
                type: 'category',
                data: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul']
            },
            yAxis: {
                type: 'value',
            },
            grid: {
                top: 10
            },
            series: [{
                data: [30, 40, 70, 30, 45, 50, 30],
                type: 'bar',
                lineStyle: {
                    color: '#0380ff'
                }
            }]
        };
        if(this.chartConfig){
            // myChart.setOption(this.chartConfig);
            myChart.resize({width: 600, height: 400});
            myChart.setOption(option, true);
        }
        console.log('myChart.js.05141608.feature ->',myChart);
        this.isEchartsInitialized = true;
    }
}