import Component from "@ember/component";
import EmberObject, { action, computed } from "@ember/object";
import showModal from "discourse/lib/show-modal";
import UserReward from "../models/user-reward";

export default Component.extend({
  click() {
    showModal("reward-view", {
      model: {
        reward: this.reward,
        grant: this.grant,
        redeem: this.redeem,
        user_reward: this.user_reward
      }
    });
  },

  @computed("current_user.available_points", "reward.points")
  get disableRedeemButton() {
    return this.reward.points >= this.currentUser.available_points
  },

  @action
  editReward(reward) {
    showModal("admin-reward-form", {
      model: {
        reward: reward,
        save: this.save,
        destroy: this.destroy
      }
    });
  },

  @action
  grantReward(reward) {
    this.grant(this.reward);
  },

  @action
  grantUserReward(UserReward) {
    this.grant(this.user_reward)
  }
});
