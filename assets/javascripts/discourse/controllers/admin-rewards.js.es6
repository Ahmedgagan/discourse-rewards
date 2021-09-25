import Controller from "@ember/controller";
import discourseComputed from "discourse-common/utils/decorators";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import showModal from "discourse/lib/show-modal";
import Reward from "../models/reward";
import I18n from "I18n";
import bootbox from "bootbox";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { set } from '@ember/object';

export default Controller.extend({
  routing: service("-routing"),

  @discourseComputed("routing.currentRouteName")
  selectedRoute() {
    const currentRoute = this.routing.currentRouteName;
    const showRoute = "adminRewards.show";
    if (currentRoute !== showRoute) {
      return "adminRewards.show";
    } else {
      return this.routing.currentRouteName;
    }
  },

  @action
  addReward() {
    showModal("admin-reward-form", {
      model: {
        reward: null,
        save: this.save,
        destroy: this.destroy
      }
    });
  },

  @action
  save(reward) {
    if (!this.saving) {
      let fields = [
        "id",
        "title",
        "points",
        "quantity",
        "title",
        "description",
        "image",
        "image_url",
      ];

      this.set("saving", true);
      this.set("savingStatus", I18n.t("saving"));

      const data = {};

      fields.forEach(function (field) {
        let d;

        d = reward.get(field);

        data[field] = d;
      });

      const newReward = !reward.id;

      return Reward
        .save(data)
        .then((result) => {
          if (newReward) {
            this.model.pushObject(reward);
          } else {
            this.model.splice(this.model.indexOf(reward), 1, result.reward);
            this.set("savingStatus", I18n.t("saved"));
            this.send("closeModal");
          }
        })
        .catch(popupAjaxError)
        .finally(() => {
          this.set("saving", false);
          this.set("savingStatus", "");
        });
    }
  },

  @action
  destroy(reward) {
    if (!reward || !reward.id) {
      return;
    }

    return bootbox.confirm(
      I18n.t("admin.badges.delete_confirm"),
      I18n.t("no_value"),
      I18n.t("yes_value"),
      (result) => {
        if (result) {
          return Reward
            .destroy(reward)
            .then(() => {
              this.model.removeObject(reward);
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
