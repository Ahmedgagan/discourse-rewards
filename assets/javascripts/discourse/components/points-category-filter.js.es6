import DropdownSelectBoxComponent from "select-kit/components/dropdown-select-box";
import I18n from "I18n";
import { computed } from "@ember/object";

export default DropdownSelectBoxComponent.extend({
  classNames: ["points-category-filter"],

  content: computed(function () {
    return [
      {
        id: "all",
        label: I18n.t("user.user_notifications.filters.all"),
      },
      {
        id: "creation",
        label: I18n.t("discourse_rewards.transaction.categories.creation"),
      },
      {
        id: "like",
        label: I18n.t("discourse_rewards.transaction.categories.like"),
      },
      {
        id: "badge",
        label: I18n.t("discourse_rewards.transaction.categories.badge"),
      },
      {
        id: "redeem",
        label: I18n.t("discourse_rewards.transaction.categories.redeem"),
      },
      {
        id: "uncategorized",
        label: I18n.t("discourse_rewards.transaction.categories.uncategorized"),
      },
    ];
  }),

  selectKitOptions: {
    headerComponent: "points-category-filter-header",
  },
});
