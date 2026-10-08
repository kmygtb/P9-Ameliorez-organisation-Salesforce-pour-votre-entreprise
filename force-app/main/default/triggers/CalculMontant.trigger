trigger CalculMontant on Order(before update) {
  for (Order newOrder : Trigger.new) {
    newOrder.NetAmount__c = newOrder.TotalAmount - newOrder.ShipmentCost__c;
  }
}
