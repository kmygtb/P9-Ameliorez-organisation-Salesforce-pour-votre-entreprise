import { LightningElement, api } from "lwc";
import getSumOrdersByAccount from "@salesforce/apex/OrdersController.getSumOrdersByAccount";

export default class AccountOrdersTotal extends LightningElement {
  sumOrdersOfCurrentAccount;
  hasPositiveAmount;
  @api recordId;

  connectedCallback() {
    this.fetchSumOrders();
  }

  fetchSumOrders() {
    getSumOrdersByAccount({ accountId: this.recordId })
      .then((result) => {
        this.sumOrdersOfCurrentAccount = result;
        this.hasPositiveAmount = result > 0;
      })
      .catch((error) => {
        this.hasPositiveAmount = false;
        console.log("une erreur est survenue", error);
      });
  }
}
