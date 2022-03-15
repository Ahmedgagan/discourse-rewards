import Controller from "@ember/controller";
import discourseComputed from "discourse-common/utils/decorators";
import { isEmpty } from "@ember/utils";
import EmberObject, { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import bootbox from "bootbox";

export default Controller.extend({
  saving: false,
  savingStatus: "",
  forceValidationReason: false,

  // Check the points
  @discourseComputed("startDate", "forceValidationReason")
  startDateValidation(startDate, forceValidationReason) {
    const failedAttrs = {
      failed: true,
      ok: false,
      element: document.querySelector("#campaign-start-date"),
    };

    // If blank, fail without a reason
    if (isEmpty(startDate)) {
      return EmberObject.create(
        Object.assign(failedAttrs, {
          message: I18n.t("reward.points.validation.required"),
          reason: forceValidationReason
            ? I18n.t("reward.points.validation.required")
            : null,
        })
      );
    }

    if (this.endDate && startDate > this.endDate) {
      return EmberObject.create(
        Object.assign(failedAttrs, {
          message: I18n.t("reward.points.validation.required"),
          reason: forceValidationReason
            ? I18n.t("reward.points.validation.required")
            : null,
        })
      );
    }

    return EmberObject.create({
      ok: true,
      reason: I18n.t("reward.points.validation.ok"),
    });
  },

  // Check the points
  @discourseComputed("endDate", "forceValidationReason")
  endDateValidation(endDate, forceValidationReason) {
    const failedAttrs = {
      failed: true,
      ok: false,
      element: document.querySelector("#campaign-end-date"),
    };

    // If blank, fail without a reason
    if (isEmpty(endDate)) {
      return EmberObject.create(
        Object.assign(failedAttrs, {
          message: I18n.t("reward.points.validation.required"),
          reason: forceValidationReason
            ? I18n.t("reward.points.validation.required")
            : null,
        })
      );
    }

    if (this.startDate > endDate) {
      return EmberObject.create(failedAttrs, {
        message: I18n.t("reward.points.validation.required"),
        reason: forceValidationReason
          ? I18n.t("reward.points.validation.required")
          : null,
      });
    }

    return EmberObject.create({
      ok: true,
      reason: I18n.t("reward.points.validation.ok"),
    });
  },

  // Check the name
  @discourseComputed("campaignName", "forceValidationReason")
  campaignNameValidation(campaignName, forceValidationReason) {
    const failedAttrs = {
      failed: true,
      ok: false,
      element: document.querySelector("#campaign-name"),
    };

    // If blank, fail without a reason
    if (isEmpty(campaignName)) {
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

  @action
  saveCampaign() {
    this.set("forceValidationReason", true);
    const validation = [
      this.startDateValidation,
      this.endDateValidation,
      this.campaignNameValidation,
    ].find((v) => v.failed);

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

    if (this.model.campaign) {
      this.save(
        this.startDate,
        this.endDate,
        this.campaignName,
        this.campaignDescription,
        this.model.campaign.id
      );
    } else {
      this.save(
        this.startDate,
        this.endDate,
        this.campaignName,
        this.campaignDescription
      );
    }
  },

  save(startDate, endDate, campaignName, campaignDescription, id) {
    let url = "/rewards/campaign";
    let type = "POST";
    if (id) {
      url += `/${id}`;
      type = "PUT";
    }

    ajax(url, {
      type: type,
      data: {
        name: campaignName,
        start_date: startDate,
        end_date: endDate,
        description: campaignDescription,
      },
    }).then((result) => {
      this.set("update", false);
      this.set("campaignName", null);
      this.set("startDate", null);
      this.set("endDate", null);
      this.set("campaignDescription", null);
      this.set("disabled", true);
      this.set("model.campaign", result.campaign);
    });
  },

  @action
  startUpdate() {
    this.setProperties({
      disabled: false,
      campaignName: this.model.campaign.name,
      startDate: this.model.campaign.start_date,
      endDate: this.model.campaign.end_date,
      campaignDescription: this.model.campaign.description,
      update: true,
    });
  },

  @action
  destroyCampaign() {
    if (this.model.campaign && this.model.campaign.id) {
      return bootbox.confirm(
        I18n.t("admin.rewards.campaign.delete_campaign_confirm"),
        I18n.t("no_value"),
        I18n.t("yes_value"),
        (result) => {
          if (result) {
            return ajax(`/rewards/campaign/${this.model.campaign.id}`, {
              type: "DELETE",
            })
              .then((result) => {
                this.set("update", false);
                this.set("campaignName", null);
                this.set("startDate", null);
                this.set("endDate", null);
                this.set("campaignDescription", null);
                this.set("disabled", true);
                this.set("model.campaign", null);
              })
              .catch(() => {
                bootbox.alert(I18n.t("generic_error"));
              });
          }
        }
      );
    }
  },
});
