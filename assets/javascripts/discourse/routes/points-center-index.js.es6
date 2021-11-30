import Transaction from "../models/transaction";
import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default DiscourseRoute.extend({
  queryParams: {
    filter: null,
  },

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

  actions: {
    refreshModel() {
      this.refresh();
    },
  },
});
