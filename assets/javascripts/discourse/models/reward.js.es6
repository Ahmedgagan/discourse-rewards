import EmberObject from "@ember/object";
import { Promise } from "rsvp";
import RestModel from "discourse/models/rest";
import { ajax } from "discourse/lib/ajax";
import discourseComputed from "discourse-common/utils/decorators";
import getURL from "discourse-common/lib/get-url";
import { alias, none } from "@ember/object/computed";

const Reward = RestModel.extend({});

Reward.reopenClass({
  // updateFromJson(json) {
  //   Object.keys(json.reward).forEach((key) => this.set(key, json.badge[key]));
  // },

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
        return this.createFromJson(rewardJson)
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

  findById(id) {
    return ajax(`/rewards/${id}`).then((rewardJson) =>
      this.createFromJson(rewardJson)
    );
  },

  createFromJson(json) {
    let rewards = [];
    if ("reward" in json) {
      rewards = [json.reward];
    } else if (json.rewards) {
      rewards = json.rewards;
    }

    rewards = rewards.map((rewardJson) => {
      const reward = Reward.create(rewardJson);

      return reward;
    });

    if ("reward" in json) {
      return rewards[0];
    } else {
      return rewards;
    }
  },
});

export default Reward;
