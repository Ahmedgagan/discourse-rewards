import Controller from "@ember/controller";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import Reward from "../models/reward";
import I18n from "I18n";
import bootbox from "bootbox";
import { ajax } from "discourse/lib/ajax";

export default Controller.extend({
  routing: service("-routing"),
  page: 0,
  loading: false,

  init() {
    this._super(...arguments);

    this.messageBus.subscribe(`/u/rewards`, (data) => {
      this.replaceReward(data);
    });
  },

  replaceReward(data) {
    let index = this.model.rewards.indexOf(
      this.model.rewards.find(
        (searchReward) => searchReward.id === data.reward_id
      )
    );

    if (data.create) {
      if (index < 0) {
        this.model.rewards.unshiftObject(Reward.createFromJson(data));
      }

      return;
    }

    if (data.destroy) {
      if (index >= 0) {
        this.model.rewards.removeObject(this.model.rewards[index]);
      }

      return;
    }

    this.model.rewards.removeObject(this.model.rewards[index]);
    this.model.rewards.splice(index, 0, Reward.createFromJson(data));

    this.set("model.rewards", this.model.rewards);
  },

  findRewards() {
    if (this.page * 30 >= this.model.count) {
      return;
    }

    if (this.loading || !this.model) {
      return;
    }

    this.set("loading", true);
    this.set("page", this.page + 1);

    ajax("/rewards.json", {
      type: "GET",
      data: { page: this.page },
    })
      .then((result) => {
        this.model.rewards.pushObjects(Reward.createFromJson(result).rewards);
      })
      .finally(() => this.set("loading", false));
  },

  @action
  loadMore() {
    this.findRewards();
  },

  @action
  grant(reward) {
    if (!reward || !reward.id) {
      return;
    }

    return bootbox.confirm(
      I18n.t("admin.rewards.redeem_confirm"),
      I18n.t("no_value"),
      I18n.t("yes_value"),
      (result) => {
        if (result) {
          return Reward.grant(reward)
            .then(() => {
              // this.model.removeObject(reward);
              // this.send("closeModal");
            })
            .catch(() => {
              bootbox.alert(I18n.t("generic_error"));
            });
        }
      }
    );
  },
});
