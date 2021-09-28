import Controller, { inject as controller } from "@ember/controller";
import Component from "@ember/component";
import discourseComputed, { observes } from "discourse-common/utils/decorators";
import I18n from "I18n";
import bootbox from "bootbox";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { propertyNotEqual } from "discourse/lib/computed";
import { equal, reads } from "@ember/object/computed";
import { run } from "@ember/runloop";
import { action } from "@ember/object";
import Reward from "../models/reward";
import getURL from "discourse-common/lib/get-url";
import EmberObject from "@ember/object";

const IMAGE = "image";

export default Component.extend({
  saving: false,
  savingStatus: "",
  selectedGraphicType: null,
  showDisplayName: propertyNotEqual("name", "displayName"),

  init() {
    this._super(...arguments);

    if(!this.reward) {
      this.set("reward", EmberObject.create());
    }
  },

  @observes("model.id")
  _resetSaving: function () {
    this.set("saving", false);
    this.set("savingStatus", "");
  },

  showImageUploader() {
    this.set("selectedGraphicType", IMAGE);
  },

  @action
  setImage(upload) {
    this.reward.setProperties({
      image: upload.id,
      image_url: getURL(upload.url),
    });
  },

  @action
  removeImage() {
    this.reward.setProperties({
      image: null,
      image_url: null
    });
  },

  actions: {
    saveReward() {
      this.save(EmberObject.create(this.reward));
    },

    destroyReward() {
      this.destroy(this.reward);
    }
  }
});
