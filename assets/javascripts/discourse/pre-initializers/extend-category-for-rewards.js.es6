import Category from "discourse/models/category";
import { computed } from "@ember/object";

export default {
  name: "extend-category-for-rewards",
  before: "inject-discourse-objects",

  initialize() {
    Category.reopen({
      rewards_points_for_topic_create: computed(
        "custom_fields.rewards_points_for_topic_create",
        {
          get() {
            return this?.custom_fields?.rewards_points_for_topic_create;
          },
        }
      ),
    });
  },
};
