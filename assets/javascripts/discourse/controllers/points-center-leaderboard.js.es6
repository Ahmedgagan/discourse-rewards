import { action, computed } from "@ember/object";
import Controller from "@ember/controller";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";

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

  @computed("model.users")
  get myRank() {
    return (
      this.model.users.findIndex(
        (user) => user.username === this.currentUser.username
      ) + 1
    );
  },

  get rankString() {
    if (this.myRank <= 10) {
      return top_10[Math.floor(Math.random() * top_10.length)];
    } else if (this.myRank > 10 && this.myRank <= 100) {
      return top_100[Math.floor(Math.random() * top_100.length)];
    }

    return above_100[Math.floor(Math.random() * above_100.length)];
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
