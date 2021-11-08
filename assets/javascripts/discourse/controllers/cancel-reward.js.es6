import Controller from "@ember/controller";
import EmberObject, { action } from "@ember/object";
import discourseComputed from "discourse-common/utils/decorators";
import { isEmpty } from "@ember/utils";

export default Controller.extend({
  cancel_reason: "",
  forceValidationReason: false,

  @action
  cancelReward() {
    if (this.cancel_reason) {
      this.model.cancelReward(this.model.user_reward, this.cancel_reason);
      this.send("closeModal");
    }
  },

  // Check the points
  @discourseComputed("cancel_reason", "forceValidationReason")
  reasonValidation(reason, forceValidationReason) {
    const failedAttrs = {
      failed: true,
      ok: false,
      element: document.querySelector("#reason"),
    };

    if (isEmpty(reason)) {
      return EmberObject.create(
        Object.assign(failedAttrs, {
          message: I18n.t(
            "discourse_rewards.user_rewards.cancel_reward.reason_validation.required"
          ),
          reason: I18n.t(
            "discourse_rewards.user_rewards.cancel_reward.reason_validation.required"
          ),
        })
      );
    }

    return EmberObject.create({
      ok: true,
      reason: I18n.t("reward.points.validation.ok"),
    });
  },
});
