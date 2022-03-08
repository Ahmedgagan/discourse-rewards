import Controller from "@ember/controller";
import MessageBus from "message-bus-client";
import discourseComputed from "discourse-common/utils/decorators";

export default Controller.extend({
  queryParams: ["filter"],
  filter: "all",

  init() {
    this._super(...arguments);

    MessageBus.subscribe(`/u/${this.currentUser.id}/rewards`, (data) => {
      if (data.available_points) {
        this.currentUser.set("available_points", data.available_points);
        this.send("refreshModel");
      }
    });
  },

  @discourseComputed("filter")
  filteredTransactions(filter) {
    if (filter === "creation")
      return this.model.transactions.filter(
        (transaction) =>
          transaction.user_points_category &&
          transaction.user_points_category.id === 2
      );
    if (filter === "like")
      return this.model.transactions.filter(
        (transaction) =>
          transaction.user_points_category &&
          transaction.user_points_category.id === 4
      );
    if (filter === "daily_login")
      return this.model.transactions.filter(
        (transaction) =>
          transaction.user_points_category &&
          transaction.user_points_category.id === 3
      );
    if (filter === "badge")
      return this.model.transactions.filter(
        (transaction) =>
          transaction.user_points_category &&
          transaction.user_points_category.id === 1
      );
    if (filter === "redeem")
      return this.model.transactions.filter(
        (transaction) =>
          transaction.user_points_category &&
          transaction.user_points_category.id === null
      );

    if (filter === "invite")
      return this.model.transactions.filter(
        (transaction) =>
          transaction.user_points_category &&
          transaction.user_points_category.id === 6
      );
    return this.model.transactions;
  },
});
