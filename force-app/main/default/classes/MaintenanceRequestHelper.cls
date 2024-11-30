public class MaintenanceRequestHelper {
    public static void updateWorkOrders(List<Case> newCases, Map<Id, Case> oldCaseMap) {
        List<Case> newRoutineRequests = new List<Case>();
        List<Equipment_Maintenance_Item__c> newEquipmentMaintenanceItems = new List<Equipment_Maintenance_Item__c>();

        Map<Id, List<Equipment_Maintenance_Item__c>> caseToEquipmentMap = new Map<Id, List<Equipment_Maintenance_Item__c>>();
        for (Equipment_Maintenance_Item__c item : [SELECT Equipment__r.Maintenance_Cycle__c, Maintenance_Request__c, Equipment__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :newCases]) {
            if (!caseToEquipmentMap.containsKey(item.Maintenance_Request__c)) {
                caseToEquipmentMap.put(item.Maintenance_Request__c, new List<Equipment_Maintenance_Item__c>());
            }
            caseToEquipmentMap.get(item.Maintenance_Request__c).add(item);
        }

        for (Case newCase : newCases) {
            Case oldCase = oldCaseMap.get(newCase.Id);

            if (newCase.Status == 'Closed' && oldCase.Status != 'Closed' &&
                (newCase.Type == 'Repair' || newCase.Type == 'Routine Maintenance')) {
                
                Case routineRequest = new Case();
                routineRequest.Type = 'Routine Maintenance';
                routineRequest.Status = 'New';
                routineRequest.Subject = 'Routine Maintenance Checkup';
                routineRequest.ParentId = newCase.Id;
                routineRequest.Vehicle__c = newCase.Vehicle__c;
                routineRequest.Date_Reported__c = Date.today();

                Integer shortestCycle = 2147483647;
                if (caseToEquipmentMap.containsKey(newCase.Id)) {
                    for (Equipment_Maintenance_Item__c item : caseToEquipmentMap.get(newCase.Id)) {
                        Integer maintenanceCycle = item.Equipment__r.Maintenance_Cycle__c.intValue();
                        if (maintenanceCycle < shortestCycle) {
                            shortestCycle = maintenanceCycle;
                        }
                    }
                }
                routineRequest.Date_Due__c = Date.today().addDays(shortestCycle);
                newRoutineRequests.add(routineRequest);
            }
        }

        if (!newRoutineRequests.isEmpty()) {
            insert newRoutineRequests;

            for (Case routineRequest : newRoutineRequests) {
                if (caseToEquipmentMap.containsKey(routineRequest.ParentId)) {
                    for (Equipment_Maintenance_Item__c item : caseToEquipmentMap.get(routineRequest.ParentId)) {
                        Equipment_Maintenance_Item__c newItem = new Equipment_Maintenance_Item__c();
                        newItem.Equipment__c = item.Equipment__c;
                        newItem.Maintenance_Request__c = routineRequest.Id;
                        newEquipmentMaintenanceItems.add(newItem);
                    }
                }
            }

            if (!newEquipmentMaintenanceItems.isEmpty()) {
                insert newEquipmentMaintenanceItems;
            }
        }
    }
}