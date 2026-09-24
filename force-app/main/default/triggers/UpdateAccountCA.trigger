trigger UpdateAccountCA on Order (after update) {
AccountService.updateChiffreAffaire(trigger.new);
}