import Controller from "@ember/controller";
import UserReward from "../models/user-reward";
import { action } from "@ember/object";
import bootbox from "bootbox";
import { ajax } from "discourse/lib/ajax";

export default Controller.extend({
  page: 0,
  loading: false,

  findRewards() {
    if (this.loading || !this.model) {
      return;
    }

    this.set("loading", true);
    this.set("page", this.page + 1);

    ajax('/user-rewards.json', {
      type: "GET",
      data: { page: this.page },
    }).then((result) => {
      this.model.pushObjects(UserReward.createFromJson(result));
    }).finally(() => this.set("loading", false));
  },

  @action
  loadMore() {
    this.findRewards();
  },

  @action
  grant(user_reward) {
    if (!user_reward || !user_reward.id) {
      return;
    }

    return bootbox.confirm(
      I18n.t("admin.rewards.grant_confirm"),
      I18n.t("no_value"),
      I18n.t("yes_value"),
      (result) => {
        if (result) {
          return UserReward
            .grant(user_reward)
            .then(() => {
              this.model.removeObject(user_reward);
              this.send("closeModal");
            })
            .catch(() => {
              bootbox.alert(I18n.t("generic_error"));
            });
        }
      }
    );
  },
});