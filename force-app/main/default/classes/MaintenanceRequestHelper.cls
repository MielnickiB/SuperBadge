public class MaintenanceRequestHelper {
    public static void updateWorkOrders(List<Case> newCases, Map<Id, Case> oldCaseMap) {
        List<Case> newRoutineRequests = new List<Case>();

        for (Case newCase : newCases) {
            Case oldCase = oldCaseMap.get(newCase.Id);

            if (newCase.Status == 'Closed' && oldCase.Status != 'Closed' &&
                (newCase.Type == 'Repair' || newCase.Type == 'Routine Maintenance')) {
                
                Case routineRequest = new Case();
                routineRequest.Type = 'Routine Maintenance';
                routineRequest.Status = 'New';
                routineRequest.ParentId = newCase.Id;
                newRoutineRequests.add(routineRequest);
            }
        }

        if (!newRoutineRequests.isEmpty()) {
            insert newRoutineRequests;
        }
    }
}