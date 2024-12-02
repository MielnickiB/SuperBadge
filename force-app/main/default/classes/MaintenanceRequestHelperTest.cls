@isTest
public class MaintenanceRequestHelperTest {
    @testSetup
    static void setup() {
        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        for (Integer i = 0; i < 10; i++) {
            Vehicle__c vehicle = new Vehicle__c();
            vehicle.Name = 'Test Vehicle ' + i;
            vehicles.add(vehicle);
        }
        insert vehicles;

        List<Product2> equipments = new List<Product2>();
        for (Integer i = 0; i < 10; i++) {
            Product2 equipment = new Product2();
            equipment.Name = 'Test Equipment ' + i;
            equipment.Maintenance_Cycle__c = 30;
            equipment.Replacement_Part__c = true;
            equipments.add(equipment);
        }
        insert equipments;

        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 10; i++) {
            Case c = new Case();
            c.Status = 'New';
            c.Type = 'Repair';
            c.Subject = 'Test Case ' + i;
            c.Vehicle__c = vehicles[i].Id;
            cases.add(c);
        }
        insert cases;

        List<Equipment_Maintenance_Item__c> items = new List<Equipment_Maintenance_Item__c>();
        for (Integer i = 0; i < 10; i++) {
            Equipment_Maintenance_Item__c item = new Equipment_Maintenance_Item__c();
            item.Maintenance_Request__c = cases[i].Id;
            item.Equipment__c = equipments[i].Id;
            items.add(item);
        }
        insert items;
    }

    @isTest
    static void testPositiveCase() {
        // Pobranie przypadków testowych
        List<Case> cases = [SELECT Id, Status, Type, Vehicle__c FROM Case WHERE Status = 'New'];
        
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        for (Case c : cases) {
            oldCaseMap.put(c.Id, c.clone(false, true, true, true));
        }

        for (Case c : cases) {
            c.Status = 'Closed';
        }

        Test.startTest();
        update cases;
        Test.stopTest();

        List<Case> newRoutineRequests = [SELECT Id, Status, Type, Subject, Vehicle__c FROM Case WHERE Type = 'Routine Maintenance'];
        System.assertEquals(10, newRoutineRequests.size(), 'Should have created 10 routine maintenance requests');
    }

    @isTest
    static void testNegativeCase() {
        List<Case> cases = [SELECT Id, Status, Type, Vehicle__c FROM Case WHERE Status = 'New'];
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        for (Case c : cases) {
            oldCaseMap.put(c.Id, c.clone(false, true, true, true));
        }

        for (Case c : cases) {
            c.Status = 'In Progress';
        }

        Test.startTest();
        update cases;
        Test.stopTest();

        List<Case> newRoutineRequests = [SELECT Id, Status, Type, Subject, Vehicle__c FROM Case WHERE Type = 'Routine Maintenance'];
        System.assertEquals(0, newRoutineRequests.size(), 'Should not have created any routine maintenance requests');
    }

    @isTest
    static void testPositiveButBadType() {
        List<Case> cases = [SELECT Id, Status, Type, Vehicle__c FROM Case WHERE Status = 'New'];
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        for (Case c : cases) {
            oldCaseMap.put(c.Id, c.clone(false, true, true, true));
        }

        for (Case c : cases) {
            c.Status = 'Closed';
            c.Type = 'Inquiry';
        }

        Test.startTest();
        update cases;
        Test.stopTest();

        List<Case> newRoutineRequests = [SELECT Id, Status, Type, Subject, Vehicle__c FROM Case WHERE Type = 'Routine Maintenance'];
        System.assertEquals(0, newRoutineRequests.size(), 'Should not have created any routine maintenance requests');
    }
}