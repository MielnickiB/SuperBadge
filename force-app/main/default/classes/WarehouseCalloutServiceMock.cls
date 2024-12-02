public with sharing class WarehouseCalloutServiceMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"id":"1","replacement":true,"quantity":10,"name":"Test Equipment","maintenanceperiod":6,"lifespan":24,"cost":100.0,"sku":"12345"}]');
        res.setStatusCode(200);
        return res;
    }
}