import { Promise } from "rsvp";
import RestModel from "discourse/models/rest";
import { ajax } from "discourse/lib/ajax";
import User from "discourse/models/user";
import UserReward from "../models/user-reward";
const Reward = RestModel.extend({});

Reward.reopenClass({
  save(data) {
    let url = "/rewards",
      type = "POST";

    if (data.id) {
      // We are updating an existing reward.
      url += `/${data.id}`;
      type = "PUT";
    }

    return ajax(url, { type, data })
      .then((rewardJson) => {
        return this.createFromJson(rewardJson);
      })
      .catch((error) => {
        throw new Error(error);
      });
  },

  destroy(reward) {
    if (!reward.id) {
      return Promise.resolve();
    }

    return ajax(`/rewards/${reward.id}`, {
      type: "DELETE",
    });
  },

  grant(reward) {
    if (!reward.id) {
      return Promise.resolve();
    }

    return ajax(`/rewards/${reward.id}/grant`, {
      type: "post",
    });
  },

  findById(id) {
    return ajax(`/rewards/${id}`).then((rewardJson) =>
      this.createFromJson(rewardJson)
    );
  },

  createFromJson(json) {
    let rewards = [];
    if ("reward" in json) {
      rewards = [json.reward];
    } else {
      rewards = json;
    }

    rewards = rewards.map((rewardJson) => {
      rewardJson.created_by = User.create(rewardJson.created_by);
      rewardJson.user_rewards = UserReward.create(rewardJson.user_rewards);

      return rewardJson;
    });

    if ("reward" in json) {
      return rewards[0];
    } else {
      return rewards;
    }
  },
});

export default Reward;
