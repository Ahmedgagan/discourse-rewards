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
    let index = this.model.indexOf(
      this.model.find((searchReward) => searchReward.id === data.reward_id)
    );

    if (data.create) {
      if (index < 0) {
        this.model.unshiftObject(Reward.createFromJson(data));
      }

      return;
    }

    if (data.destroy) {
      if (index >= 0) {
        this.model.removeObject(this.model[index]);
      }

      return;
    }

    this.model.removeObject(this.model[index]);
    this.model.splice(index, 0, Reward.createFromJson(data));

    this.set("model", this.model);
  },

  findRewards() {
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
        this.model.pushObjects(Reward.createFromJson(result));
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
