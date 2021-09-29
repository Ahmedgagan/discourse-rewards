import Component from "@ember/component";
import showModal from "discourse/lib/show-modal";
import { action, computed } from "@ember/object";

export default Component.extend({
  click() {
    if (!this.site.mobileView) {
      return;
    }

    showModal("reward-view", {
      model: {
        reward: this.reward,
        grant: this.grant,
        redeem: this.redeem,
        user_reward: this.user_reward,
      },
    });
  },

  @computed("current_user.available_points", "reward.points")
  get disableRedeemButton() {
    return (
      this.reward.points >= this.currentUser.available_points ||
      this.reward.quantity < 1
    );
  },

  @action
  editReward(reward) {
    showModal("admin-reward-form", {
      model: {
        reward: reward,
        save: this.save,
        destroy: this.destroy,
      },
    });
  },

  @action
  grantReward(reward) {
    this.grant(reward);
  },

  @action
  grantUserReward(user_reward) {
    this.grant(user_reward);
  },
});
