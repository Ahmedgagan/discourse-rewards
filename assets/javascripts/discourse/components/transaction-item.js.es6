import Component from "@ember/component";
import { computed } from "@ember/object";
import I18n from "I18n";

export default Component.extend({
  tagName: "tr",
  classNames: ["transaction-item"],

  @computed("transaction.reward", "transaction.user_point")
  get details() {
    if (this.transaction.user_reward) {
      return I18n.t("discourse_rewards.my_points_center.redeemed", {
        title: this.transaction.user_reward.reward.title,
      });
    } else if (this.transaction.user_point.description) {
      const description = JSON.parse(this.transaction.user_point.description);

      if (description.topic_id) {
        return I18n.t("discourse_rewards.my_points_center.topic_create", {
          title: description.topic_title,
        });
      } else if (description.type) {
        return I18n.t("discourse_rewards.my_points_center.like_received", {
          post_id: description.post_id,
        });
      } else if (description.post_id) {
        return I18n.t("discourse_rewards.my_points_center.post_create", {
          title: description.topic_title,
        });
      } else {
        return I18n.t("discourse_rewards.my_points_center.badge", {
          title: description.name,
        });
      }
    }

    return I18n.t("discourse_rewards.my_points_center.earned_points");
  },
});
