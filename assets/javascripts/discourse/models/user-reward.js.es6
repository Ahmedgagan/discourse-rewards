import EmberObject from "@ember/object";
import { Promise } from "rsvp";
import RestModel from "discourse/models/rest";
import { ajax } from "discourse/lib/ajax";
import User from "discourse/models/user";
import Reward from "../models/reward";
import discourseComputed from "discourse-common/utils/decorators";
import getURL from "discourse-common/lib/get-url";
import { alias, none } from "@ember/object/computed";

const UserReward = RestModel.extend({});

UserReward.reopenClass({
  grant(user_reward) {
    if (!user_reward.id) {
      return Promise.resolve();
    }

    return ajax(`/user-rewards/${user_reward.id}`, {
      type: "post",
    });
  },

  createFromJson(json) {
    let userRewards = [];
    if ("user_reward" in json) {
      userRewards = [json.user_reward];
    } else {
      userRewards = json;
    }

    userRewards = userRewards.map((userRewardJson) => {
      userRewardJson.reward = Reward.create(userRewardJson.reward);
      userRewardJson.user = User.create(userRewardJson.user);

      return userRewardJson;
    });

    if ("user_reward" in json) {
      return userRewards[0];
    } else {
      return userRewards;
    }
  },
});

export default UserReward;
