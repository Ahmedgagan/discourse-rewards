import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default DiscourseRoute.extend({
  model() {
    return ajax("/rewards-leaderboard.json").then((data) => {
      return data;
    });
  },

  setupController(controller, model) {
    controller.setProperties({
      model,
    });
  },
});
