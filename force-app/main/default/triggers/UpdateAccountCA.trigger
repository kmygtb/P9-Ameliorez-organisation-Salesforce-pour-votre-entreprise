trigger UpdateAccountCA on Order (after update) {
    List<Order> activatedOrders = new List<Order>();
    for (Order ord : Trigger.new) {
        Order previousOrd = Trigger.oldMap.get(ord.Id);
        Boolean justActivated = ord.Status == 'Activated' && previousOrd.Status != 'Activated';
        if (justActivated) {
            activatedOrders.add(ord);
        }
    }
    if (!activatedOrders.isEmpty()) {
        AccountService.updateChiffreAffaire(activatedOrders);
    }
}