import Component from "@ember/component";
import { computed } from "@ember/object";

export default Component.extend({
  tagName: "tr",
  classNames: ["transaction-item"],

  @computed("transaction.reward", "transaction.user_point")
  get details() {
    if (this.transaction.user_reward) {
      return `Redeemed a reward: ${this.transaction.user_reward.reward.title}`;
    } else if (this.transaction.user_point.description) {
      const description = JSON.parse(this.transaction.user_point.description);

      if (description.topic_id) {
        return `Created a topic: ${description.topic_title}`;
      } else if (description.type) {
        return `Received a like on post id: ${description.post_id}`;
      } else if (description.post_id) {
        return `Created a post on ${description.topic_title} topic`;
      } else {
        return `Earned a reward badge: ${description.name}`;
      }
    }

    return "Earned reward points";
  },
});
