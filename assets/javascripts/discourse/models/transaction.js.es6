import RestModel from "discourse/models/rest";
import { ajax } from "discourse/lib/ajax";
import User from "discourse/models/user";
import UserReward from "../models/user-reward";

const Transaction = RestModel.extend({});

Transaction.reopenClass({
  createFromJson(json) {
    let transactions = [];
    if ("transaction" in json) {
      transactions = [json.transaction];
    } else if ("transactions" in json) {
      transactions = json["transactions"];
    }

    transactions = transactions.map((transactionJson) => {
      transactionJson.created_by = User.create(transactionJson.user);

      if (transactionJson.user_reward) {
        transactionJson.user_reward = UserReward.createFromJson(
          transactionJson.user_reward
        );
      }

      return transactionJson;
    });

    if ("transaction" in json) {
      return transactions[0];
    } else {
      return { transactions, count: json["count"] };
    }
  },
});

export default Transaction;
