import Component from "@ember/component";
import { computed } from "@ember/object";
import { userPath } from "discourse/lib/url";

export default Component.extend({
  @computed("user.username")
  get path() {
    return userPath(this.user.username);
  },

  @computed("user.username")
  get isCurrentUser() {
    return this.user.username === this.currentUser.username;
  },

  @computed("filter")
  get isCampaign() {
    return this.campaign && this.filter === "campaign";
  },

  @computed("index")
  get appendString() {
    if (this.rank === 1) {
      return "st";
    } else if (this.rank === 2) {
      return "nd";
    } else if (this.rank === 3) {
      return "rd";
    }

    return "";
  },

  @computed("index")
  get rank() {
    return this.index + 1;
  },
});
