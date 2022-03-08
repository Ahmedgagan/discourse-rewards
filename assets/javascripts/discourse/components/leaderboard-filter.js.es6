import DropdownSelectBoxComponent from "select-kit/components/dropdown-select-box";
import I18n from "I18n";
import { computed } from "@ember/object";

export default DropdownSelectBoxComponent.extend({
  classNames: ["points-category-filter"],

  content: computed(function () {
    return [
      {
        id: "campaign",
        label: I18n.t("discourse_rewards.leaderboard.filters.campaign"),
      },
      {
        id: "all-time",
        label: I18n.t("discourse_rewards.leaderboard.filters.all-time"),
      },
    ];
  }),
});
