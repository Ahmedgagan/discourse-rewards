import Controller from "@ember/controller";
import MessageBus from "message-bus-client";

export default Controller.extend({
  init() {
    this._super(...arguments);

    MessageBus.subscribe(`/u/${this.currentUser.id}/rewards`, (data) => {
      if (data.available_points) {
        this.currentUser.set("available_points", data.available_points);
        this.send("refreshModel");
      }
    });
  },
});
