@isTest
public with sharing class WarehouseCalloutServiceTest {
    @isTest
    static void testCallout() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
        WarehouseCalloutService service = new WarehouseCalloutService();
        System.enqueueJob(service);
        Test.stopTest();
        List<Product2> products = [SELECT Name, Warehouse_SKU__c, Replacement_Part__c, Cost__c, Current_Inventory__c, Lifespan_Months__c, Maintenance_Cycle__c FROM Product2];
        System.assertEquals(1, products.size(), 'Powinien zostać utworzony jeden produkt');
        System.assertEquals('Test Equipment', products[0].Name);
        System.assertEquals('12345', products[0].Warehouse_SKU__c);
        System.assertEquals(true, products[0].Replacement_Part__c);
        System.assertEquals(100.0, products[0].Cost__c);
        System.assertEquals(10, products[0].Current_Inventory__c);
        System.assertEquals(24, products[0].Lifespan_Months__c);
        System.assertEquals(6, products[0].Maintenance_Cycle__c);
    }
}