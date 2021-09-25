import Reward from "../models/reward";
import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";
import { action } from "@ember/object";

export default DiscourseRoute.extend({
  model() {
    return ajax("/rewards.json").then((json) => {
      this._json = json;
      return Reward.createFromJson(json);
    });
  },

  setupController(controller, model) {
    const json = this._json;

    controller.setProperties({
      model
    });
  },
});
