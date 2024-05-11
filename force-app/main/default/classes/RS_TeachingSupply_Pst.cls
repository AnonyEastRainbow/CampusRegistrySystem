/**
 * @description: TeachingSupplyBorrowingApplication__c Request Send
 * @author: AnonyEast
 * @date: 2023-06-24
 */
public with sharing class RS_TeachingSupply_Pst {
    /**
     * @description 发送钉钉机器人消息推送
     * @param strMessage 消息内容
     * @param strAtPhone 需要@的用户
     */
    @future(callout=true)
    public static void sendDingtalkNotice(String strMessage,List<String> lstAtPhone) {
        // 封装请求体
        Map<String,Object> mapRequestBody = new Map<String,Object>();
        Map<String,Object> mapRequestBodyAt = new Map<String,Object>();
        Map<String,String> mapRequestBodyText = new Map<String,String>();
        mapRequestBody.put('at', mapRequestBodyAt);
        mapRequestBody.put('text',mapRequestBodyText);
        mapRequestBody.put('msgtype', 'text');
        mapRequestBodyAt.put('atMobiles',lstAtPhone);
        mapRequestBodyAt.put('isAtAll',false);
        mapRequestBodyText.put('content', strMessage + '(登记系统推送)');
        // 将请求体序列化为JSON格式字符串
        String strRequestBody = JSON.serialize(mapRequestBody);
        System.debug('strRequestBody -> ' + strRequestBody);
        // 创建请求
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://oapi.dingtalk.com/robot/send?access_token=' + Label.DingTalk_Token);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(strRequestBody);
        // 发送请求
        HttpResponse response = http.send(request);
        if(response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug('strResponseBody -> ' + response.getBody());
        }
    }
}