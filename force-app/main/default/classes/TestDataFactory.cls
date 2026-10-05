@isTest
public class TestDataFactory {

    public static Account buildAccount(String name) {
        return new Account(Name = name, Chiffre_d_affaire__c = 0);
    }

    public static Order buildDraftOrder(Id accountId) {
        return new Order(
            AccountId = accountId,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = Test.getStandardPricebookId(),
            ShipmentCost__c = 0
        );
    }

    public static OrderItem buildOrderItem(Id orderId, Id pricebookEntryId, Integer quantity, Decimal unitPrice) {
        return new OrderItem(
            OrderId = orderId,
            PricebookEntryId = pricebookEntryId,
            Quantity = quantity,
            UnitPrice = unitPrice
        );
    }

    public static PricebookEntry createPricebookEntry(Decimal unitPrice) {
        Product2 product = new Product2(Name = 'Produit Test', IsActive = true);
        insert product;

        PricebookEntry entry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = unitPrice,
            IsActive = true
        );
        insert entry;
        return entry;
    }
}