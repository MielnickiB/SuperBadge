public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-superbadge-apex.herokuapp.com/equipment');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            List<WarehouseEquipment> equipmentList = (List<WarehouseEquipment>) JSON.deserialize(response.getBody(), List<WarehouseEquipment>.class);
            upsertEquipment(equipmentList);
        } else {
            System.debug('Error: ' + response.getStatus());
        }
    }
    
    private void upsertEquipment(List<WarehouseEquipment> equipmentList) {
        List<Product2> productsToUpsert = new List<Product2>();
        
        for (WarehouseEquipment equipment : equipmentList) {
            Product2 product = new Product2();
            product.Warehouse_SKU__c = equipment.sku;
            product.Replacement_Part__c = equipment.replacement;
            product.Cost__c = equipment.cost;
            product.Current_Inventory__c = equipment.quantity;
            product.Lifespan_Months__c = equipment.lifespan;
            product.Maintenance_Cycle__c = equipment.maintenanceperiod;
            product.Name = equipment.name;
            productsToUpsert.add(product);
        }
        
        upsert productsToUpsert Product2.Warehouse_SKU__c;
    }
    
    public class WarehouseEquipment {
        public String id;
        public Boolean replacement;
        public Integer quantity;
        public String name;
        public Integer maintenanceperiod;
        public Integer lifespan;
        public Decimal cost;
        public String sku;
    }
}