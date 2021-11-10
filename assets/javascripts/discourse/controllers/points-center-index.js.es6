import Controller from "@ember/controller";
import MessageBus from "message-bus-client";

export default Controller.extend({
  init() {
    this._super(...arguments);

    MessageBus.subscribe(`/u/${this.currentUser.id}/rewards`, (data) => {
      if (data.available_points) {
        this.currentUser.set("available_points", data.available_points);
        this.send("refreshModel");
      }
    });
  },

  get creationCategoryList() {
    return this.model.transactions.filter((transaction) => {
      if (!transaction.user_point) return false;

      const description = JSON.parse(transaction.user_point.description);

      return (
        description &&
        (description.type === "post" || description.type === "topic")
      );
    });
  },

  get likeCategoryList() {
    return this.model.transactions.filter((transaction) => {
      if (!transaction.user_point) return false;

      const description = JSON.parse(transaction.user_point.description);

      return description && description.type === "like";
    });
  },

  get badgeCategoryList() {
    return this.model.transactions.filter((transaction) => {
      if (!transaction.user_point) return false;

      const description = JSON.parse(transaction.user_point.description);

      return description && description.name;
    });
  },

  get redeemCategoryList() {
    return this.model.transactions.filter(
      (transaction) => transaction.user_reward
    );
  },

  get uncategorizedList() {
    return this.model.transactions.filter(
      (transaction) =>
        transaction.user_point && !transaction.user_point.description
    );
  },
});
