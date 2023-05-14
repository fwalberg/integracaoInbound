public with sharing class OrderHelper {
    public static void fillExternalId(List<Order> orderList) {
        for (Order order : orderList) {
            if (order.ExternalId__c == null || order.ExternalId__c == '')
                order.ExternalId__c = generateExternalId();
        }
    }

    private static String generateExternalId() {
        String externalId;
        Integer orderNumber = 0;
        Boolean exists = true;
        while (exists) {
            orderNumber++;
            externalId = String.format('ACC-{0}', new List<Object>{ orderNumber });
            try {
                Account account = [SELECT ExternalId__c FROM Account WHERE ExternalId__c = :externalId LIMIT 1];
                exists = true;
            } catch (Exception e) {
                exists = false;
            }
        }
		return externalId;
    }
}