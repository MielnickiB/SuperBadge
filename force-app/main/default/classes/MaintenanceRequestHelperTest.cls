@isTest
public class MaintenanceRequestHelperTest {
    @isTest
    static void testUpdateWorkOrders() {
        // Create a Case of type 'Repair' with status 'New'
        Case repairCase = new Case(
            Type = 'Repair',
            Status = 'New',
            Subject = 'Test Repair Case'
        );
        insert repairCase;

        // Update the Case to 'Closed'
        repairCase.Status = 'Closed';
        update repairCase;

        // Query for the new Routine Maintenance Case
        List<Case> routineCases = [SELECT Id, Type, Status, ParentId FROM Case WHERE ParentId = :repairCase.Id];

        // Verify that a new Routine Maintenance Case was created
        System.assertEquals(1, routineCases.size());
        System.assertEquals('Routine Maintenance', routineCases[0].Type);
        System.assertEquals('New', routineCases[0].Status);
        System.assertEquals(repairCase.Id, routineCases[0].ParentId);
    }

    @isTest
    static void testNoRoutineMaintenanceForNonClosedStatus() {
        // Create a Case of type 'Repair' with status 'New'
        Case repairCase = new Case(
            Type = 'Repair',
            Status = 'New',
            Subject = 'Test Repair Case'
        );
        insert repairCase;

        // Update the Case to 'Working'
        repairCase.Status = 'Working';
        update repairCase;

        // Query for the new Routine Maintenance Case
        List<Case> routineCases = [SELECT Id, Type, Status, ParentId FROM Case WHERE ParentId = :repairCase.Id];

        // Verify that no new Routine Maintenance Case was created
        System.assertEquals(0, routineCases.size());
    }
}