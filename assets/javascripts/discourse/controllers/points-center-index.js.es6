import Controller from "@ember/controller";
import MessageBus from "message-bus-client";
import { computed } from "@ember/object";

export default Controller.extend({
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

  @computed("filter", "creationCategoryList")
  get canDisplayCreationCategoryList() {
    if (this.creationCategoryList.length <= 0) return false;
    if (this.filter === "all") return true;
    if (this.filter === "creation") return true;

    return false;
  },

  @computed("filter", "likeCategoryList")
  get canDisplayLikeCategoryList() {
    if (this.likeCategoryList.length <= 0) return false;
    if (this.filter === "all") return true;
    if (this.filter === "like") return true;

    return false;
  },

  @computed("filter", "badgeCategoryList")
  get canDisplayBadgeCategoryList() {
    if (this.badgeCategoryList.length <= 0) return false;
    if (this.filter === "all") return true;
    if (this.filter === "badge") return true;

    return false;
  },

  @computed("filter", "redeemCategoryList")
  get canDisplayRedeemCategoryList() {
    if (this.redeemCategoryList.length <= 0) return false;
    if (this.filter === "all") return true;
    if (this.filter === "redeem") return true;

    return false;
  },

  @computed("filter", "uncategorizedList")
  get canDisplayUncategorizedList() {
    if (this.uncategorizedList.length <= 0) return false;
    if (this.filter === "all") return true;
    if (this.filter === "uncategorized") return true;

    return false;
  },
});
