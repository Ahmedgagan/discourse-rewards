import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default DiscourseRoute.extend({
  model() {
    return ajax("/rewards/campaign.json", {
      type: "GET",
    }).then((result) => {
      return result;
    });
  },

  setupController(controller, model) {
    controller.setProperties({
      model,
      disabled: model.campaign ? true : false,
    });
  },
});
