import { action } from "@ember/object";

export default {
  @action
  onChangeSetting() {
    this.set(
      "category.custom_fields.rewards_points_for_topic_create",
      this.category.rewards_points_for_topic_create
    );
  },
};
