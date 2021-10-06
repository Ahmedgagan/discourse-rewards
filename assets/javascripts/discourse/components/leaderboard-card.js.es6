import Component from "@ember/component";
import { computed } from "@ember/object";
import { userPath } from "discourse/lib/url";

export default Component.extend({
  @computed("user.username")
  get path() {
    return userPath(this.user.username);
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
