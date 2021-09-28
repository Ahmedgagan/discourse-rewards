import Reward from "../models/reward";
import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";
import { action } from "@ember/object";

export default DiscourseRoute.extend({
  redirect() {
    this.transitionTo('adminRewards.index');
  },
});