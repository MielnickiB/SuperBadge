@isTest
public with sharing class WarehouseSyncScheduleTest {
    @isTest
    static void testExecute() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        Test.startTest();

        WarehouseSyncSchedule schedule = new WarehouseSyncSchedule();
        
        schedule.execute(null);
        
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id, Status, JobType FROM AsyncApexJob WHERE JobType = 'Queueable'];
   
        System.assertNotEquals(0, jobs.size(), 'Zadanie powinno zostać dodane do kolejki');

        System.assertEquals('Queueable', jobs[0].JobType, 'Zadanie powinno być typu Queueable');
    }
}