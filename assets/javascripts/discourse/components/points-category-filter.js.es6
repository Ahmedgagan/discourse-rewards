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
        id: "badge",
        label: I18n.t("discourse_rewards.transaction.categories.badge"),
      },
      {
        id: "creation",
        label: I18n.t("discourse_rewards.transaction.categories.creation"),
      },
      {
        id: "daily_login",
        label: I18n.t("discourse_rewards.transaction.categories.daily_login"),
      },
      {
        id: "like",
        label: I18n.t("discourse_rewards.transaction.categories.like"),
      },
      {
        id: "redeem",
        label: I18n.t("discourse_rewards.transaction.categories.redeem"),
      },
      {
        id: "invite",
        label: I18n.t("discourse_rewards.transaction.categories.invite"),
      },
    ];
  }),

  selectKitOptions: {
    headerComponent: "points-category-filter-header",
  },
});
