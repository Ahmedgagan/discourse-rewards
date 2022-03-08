import { action, computed } from "@ember/object";
import Controller from "@ember/controller";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import I18n from "I18n";

const top_10 = [
  "it's great.",
  "the Internet of Things.",
  "please accept my knees.",
];
const top_100 = ["surpassing most users.", "very good.", "please keep it up."];
const above_100 = ["please keep on going."];

export default Controller.extend({
  routing: service("-routing"),
  page: 0,
  loading: false,
  queryParams: ["filter"],
  filter: "campaign",

  get rankString() {
    if (this.model.current_user_rank <= 10) {
      return I18n.t(
        `discourse_rewards.leaderboard.praise_user.top_10.praise_${
          Math.floor(Math.random() * 3) + 1
        }`
      );
    } else if (
      this.model.current_user_rank > 10 &&
      this.model.current_user_rank <= 100
    ) {
      return I18n.t(
        `discourse_rewards.leaderboard.praise_user.top_100.praise_${
          Math.floor(Math.random() * 3) + 1
        }`
      );
    }

    return I18n.t(
      `discourse_rewards.leaderboard.praise_user.above_100.praise_${
        Math.floor(Math.random() * 1) + 1
      }`
    );
  },

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
