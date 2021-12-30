import { createWidgetFrom } from "discourse/widgets/widget";
import { DefaultNotificationItem } from "discourse/widgets/default-notification-item";
import { replaceIcon } from "discourse-common/lib/icon-library";
import { formatUsername, postUrl } from "discourse/lib/utilities";
import { userPath } from "discourse/lib/url";
import I18n from "I18n";
import { data } from "jquery";

replaceIcon("notification.rewards", "gift");

createWidgetFrom(DefaultNotificationItem, "rewards-notification-item", {
  notificationTitle() {
    return I18n.t("notifications.titles.reaction");
  },

  text(_notificationName, data) {
    if (this.attrs.data.type == "redeemed") {
      return I18n.t("notifications.rewards.new_user_reward", {
        username: formatUsername(data.display_username),
        description: I18n.t(`notifications.rewards.redeemed`, {
          reward_title: data.reward.title,
        }),
      });
    }

    return I18n.t("notifications.rewards.new", {
      reward_title: data.reward.title,
    });
  },

  url() {
    if (this.attrs.data.type == "redeemed") {
      return "/admin/rewards/grant";
    }

    return "/points-center/available-rewards";
  },
});
