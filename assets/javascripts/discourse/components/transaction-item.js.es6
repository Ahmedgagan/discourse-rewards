import Component from "@ember/component";
import { computed } from "@ember/object";
import { postUrl } from "discourse/lib/utilities";
import getURL from "discourse-common/lib/get-url";
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

      if (description.type === "topic") {
        return I18n.t("discourse_rewards.my_points_center.topic_create", {
          title: description.topic_title,
        });
      } else if (description.type === "like") {
        return I18n.t("discourse_rewards.my_points_center.like_received", {
          post_id: description.post_id,
        });
      } else if (description.type === "post") {
        return I18n.t("discourse_rewards.my_points_center.post_create", {
          title: description.topic_title,
        });
      } else if (description.type === "daily_login") {
        return I18n.t("discourse_rewards.my_points_center.daily_login", {
          date: description.date,
        });
      } else if (description.type === "invited_user_joined") {
        return I18n.t(
          "discourse_rewards.my_points_center.invited_user_joined",
          {
            name: description.invited_user_name
              ? description.invited_user_name
              : description.invited_user_id,
          }
        );
      } else {
        return I18n.t("discourse_rewards.my_points_center.badge", {
          title: description.name,
        });
      }
    }

    return I18n.t("discourse_rewards.my_points_center.earned_points");
  },

  get url() {
    if (
      !this.transaction ||
      !this.transaction.user_point ||
      !this.transaction.user_point.description
    )
      return;

    let data = JSON.parse(this.transaction.user_point.description);

    const badgeId = data.badge_id;
    if (badgeId) {
      let badgeSlug = data.badge_slug;

      if (!badgeSlug) {
        const badgeName = data.name;
        badgeSlug = badgeName.replace(/[^A-Za-z0-9_]+/g, "-").toLowerCase();
      }

      let username = this.currentUser.username;
      username = username ? "?username=" + username.toLowerCase() : "";
      return getURL("/badges/" + badgeId + "/" + badgeSlug + username);
    }

    const topicId = data.topic_id;

    if (topicId) {
      let topic_slug = data.topic_title
        .replace(/[^A-Za-z0-9_]+/g, "-")
        .toLowerCase();
      return postUrl(topic_slug, topicId, data.post_number);
    }
  },
});
