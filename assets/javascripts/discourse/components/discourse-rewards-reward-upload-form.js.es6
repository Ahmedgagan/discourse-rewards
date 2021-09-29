import Component from "@ember/component";
import discourseComputed, { observes } from "discourse-common/utils/decorators";
import I18n from "I18n";
import { propertyNotEqual } from "discourse/lib/computed";
import getURL from "discourse-common/lib/get-url";
import EmberObject, { action } from "@ember/object";
import { isEmpty } from "@ember/utils";

const IMAGE = "image";

export default Component.extend({
  saving: false,
  savingStatus: "",
  selectedGraphicType: null,
  forceValidationReason: false,
  userFields: null,
  showDisplayName: propertyNotEqual("name", "displayName"),

  init() {
    this._super(...arguments);

    if (!this.reward) {
      this.set("reward", EmberObject.create());
    }
  },

  // Check the points
  @discourseComputed("reward.points", "forceValidationReason")
  pointsValidation(points, forceValidationReason) {
    const failedAttrs = {
      failed: true,
      ok: false,
      element: document.querySelector("#reward-points"),
    };

    // If blank, fail without a reason
    if (isEmpty(points)) {
      return EmberObject.create(
        Object.assign(failedAttrs, {
          message: I18n.t("reward.points.validation.required"),
          reason: forceValidationReason
            ? I18n.t("reward.points.validation.required")
            : null,
        })
      );
    }

    if (!(parseInt(points, 10) > 0)) {
      return EmberObject.create(
        Object.assign(failedAttrs, {
          message: I18n.t("reward.points.validation.less_than_1"),
          reason: forceValidationReason
            ? I18n.t("reward.points.validation.less_than_1")
            : null,
        })
      );
    }

    return EmberObject.create({
      ok: true,
      reason: I18n.t("reward.points.validation.ok"),
    });
  },

  // Check the quantity
  @discourseComputed("reward.quantity", "forceValidationReason")
  quantityValidation(quantity, forceValidationReason) {
    const failedAttrs = {
      failed: true,
      ok: false,
      element: document.querySelector("#reward-quantity"),
    };

    // If blank, fail without a reason
    if (isEmpty(quantity)) {
      return EmberObject.create(
        Object.assign(failedAttrs, {
          message: I18n.t("reward.quantity.validation.required"),
          reason: forceValidationReason
            ? I18n.t("reward.quantity.validation.required")
            : null,
        })
      );
    }

    if (!(parseInt(quantity, 10) > 0)) {
      return EmberObject.create(
        Object.assign(failedAttrs, {
          message: I18n.t("reward.quantity.validation.less_than_1"),
          reason: forceValidationReason
            ? I18n.t("reward.quantity.validation.less_than_1")
            : null,
        })
      );
    }

    return EmberObject.create({
      ok: true,
      reason: I18n.t("reward.quantity.validation.ok"),
    });
  },

  // Check the title
  @discourseComputed("reward.title", "forceValidationReason")
  titleValidation(title, forceValidationReason) {
    const failedAttrs = {
      failed: true,
      ok: false,
      element: document.querySelector("#reward-quantity"),
    };

    // If blank, fail without a reason
    if (isEmpty(title)) {
      return EmberObject.create(
        Object.assign(failedAttrs, {
          message: I18n.t("reward.title.validation.required"),
          reason: forceValidationReason
            ? I18n.t("reward.title.validation.required")
            : null,
        })
      );
    }

    return EmberObject.create({
      ok: true,
      reason: I18n.t("reward.title.validation.ok"),
    });
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
    this.set("reward.upload_id", upload.id);
    this.set("reward.upload_url", getURL(upload.url));
  },

  @action
  removeImage() {
    this.reward.setProperties({
      upload_id: null,
      upload_url: null,
    });
  },

  actions: {
    saveReward() {
      this.set("forceValidationReason", true);
      const validation = [this.pointsValidation, this.quantityValidation].find(
        (v) => v.failed
      );

      if (validation) {
        const element = validation.element;
        if (element) {
          if (element.tagName === "DIV") {
            if (element.scrollIntoView) {
              element.scrollIntoView();
            }
            element.click();
          } else {
            element.focus();
          }
        }

        return;
      }

      this.set("forceValidationReason", false);
      this.save(EmberObject.create(this.reward));
    },

    destroyReward() {
      this.destroy(this.reward);
    },
  },
});
