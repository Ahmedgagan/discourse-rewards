import Component from "@ember/component";
import { action } from "@ember/object";
import showModal from "discourse/lib/show-modal";

export default Component.extend({
  @action
  editReward(reward) {
    showModal("admin-reward-form", {
      model: {
        reward: reward,
        save: this.save,
        destroy: this.destroy
      }
    });
  }
});
