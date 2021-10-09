import { action } from "@ember/object";
import Controller from "@ember/controller";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";

export default Controller.extend({
  routing: service("-routing"),
  page: 0,
  loading: false,

  findUsers() {
    if (this.page * 30 >= this.model.count) {
      return;
    }

    if (this.loading || !this.model) {
      return;
    }

    this.set("loading", true);
    this.set("page", this.page + 1);

    ajax("/rewards-leaderboard.json", {
      type: "GET",
      data: { page: this.page },
    })
      .then((result) => {
        this.model.users.pushObjects(result.users);
        this.model.count = result.count;
      })
      .finally(() => this.set("loading", false));
  },

  @action
  loadMore() {
    this.findUsers();
  },
});
