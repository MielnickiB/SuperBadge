trigger MaintenanceRequest on Case (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        MaintenanceRequestHelper.updateWorkOrders(Trigger.new, Trigger.oldMap);
    }
}