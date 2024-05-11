/**
 * @description 响应实体类
 * @author: AnonyEast
 * @date: 2023-03-27
 */
public with sharing class RS_ResponseResult {
    @AuraEnabled
    public String status {get; set;}
    @AuraEnabled
    public List<Map<String, Object>> data {get; set;}
    @AuraEnabled
    public String message {get; set;}
    @AuraEnabled
    public Integer totalCounts {get; set;}

    public RS_ResponseResult(String status, List<Map<String, Object>> data, Integer totalCounts, String message) {
        this.status = status;
        this.data = data;
        this.totalCounts = totalCounts;
        this.message = message;
    }

    public RS_ResponseResult(String status, List<Map<String, Object>> data, Integer totalCounts) {
        this.status = status;
        this.data = data;
        this.totalCounts = totalCounts;
    }

    public RS_ResponseResult(String status, List<Map<String, Object>> data, String message) {
        this.status = status;
        this.data = data;
        this.message = message;
    }

    public RS_ResponseResult(String status, List<Map<String, Object>> data) {
        this.status = status;
        this.data = data;
    }

    public RS_ResponseResult(String status, Map<String, Object> data, String message) {
        this.status = status;
        this.data = new List<Map<String, Object>>{data};
        this.message = message;
    }

    public RS_ResponseResult(String status, Map<String, Object> data) {
        this.status = status;
        this.data = new List<Map<String, Object>>{data};
    }

    public RS_ResponseResult(String status, String message) {
        this.status = status;
        this.data = null;
        this.message = message;
    }

    public RS_ResponseResult(String status) {
        this.status = status;
        this.data = null;
        this.message = null;
    }
}