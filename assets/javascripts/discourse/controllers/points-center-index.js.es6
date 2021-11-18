import Controller from "@ember/controller";
import MessageBus from "message-bus-client";
import discourseComputed from "discourse-common/utils/decorators";

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

  @discourseComputed("filter", "creationCategoryList")
  canDisplayCreationCategoryList(filter, creationCategoryList) {
    if (this.creationCategoryList.length <= 0) return false;
    if (this.filter === "all") return true;
    if (this.filter === "creation") return true;

    return false;
  },

  @discourseComputed("filter", "likeCategoryList")
  canDisplayLikeCategoryList(filter, likeCategoryList) {
    if (this.likeCategoryList.length <= 0) return false;
    if (this.filter === "all") return true;
    if (this.filter === "like") return true;

    return false;
  },

  @discourseComputed("filter", "badgeCategoryList")
  canDisplayBadgeCategoryList(filter, badgeCategoryList) {
    if (this.badgeCategoryList.length <= 0) return false;
    if (this.filter === "all") return true;
    if (this.filter === "badge") return true;

    return false;
  },

  @discourseComputed("filter", "redeemCategoryList")
  canDisplayRedeemCategoryList(filter, redeemCategoryList) {
    if (this.redeemCategoryList.length <= 0) return false;
    if (this.filter === "all") return true;
    if (this.filter === "redeem") return true;

    return false;
  },

  @discourseComputed("filter", "uncategorizedList")
  canDisplayUncategorizedList(filter, uncategorizedList) {
    if (this.uncategorizedList.length <= 0) return false;
    if (this.filter === "all") return true;
    if (this.filter === "uncategorized") return true;

    return false;
  },
});
