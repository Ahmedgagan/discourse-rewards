import Transaction from "../models/transaction";
import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default DiscourseRoute.extend({
  model() {
    return ajax("/transactions.json").then((json) => {
      return Transaction.createFromJson(json);
    });
  },

  setupController(controller, model) {
    controller.setProperties({
      model,
    });
  },
});
