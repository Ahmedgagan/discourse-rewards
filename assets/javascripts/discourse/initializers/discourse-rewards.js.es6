import { withPluginApi } from "discourse/lib/plugin-api";
import { h } from "virtual-dom";
import { iconNode } from "discourse-common/lib/icon-library";
import DiscourseURL from "discourse/lib/url";

function initializeDiscourseRewards(api) {
  const currentUser = api.getCurrentUser();

  if (currentUser) {
    api.createWidget("discourse-rewards-available-points", {
      tagName: "li.discourse-rewards-available-points.icon",

      buildKey: () => `discourse-rewards-total-points`,

      buildId: () => `discourse-rewards-total-points`,

      click() {
        return DiscourseURL.routeTo("/available-rewards");
      },

      html() {
        let result = [
          h("div.available-points-container", {}, [
            h(
              "p.available-points-count",
              { title: currentUser.available_points },
              `${currentUser.available_points}`
            ),
            iconNode("trophy"),
          ]),
        ];

        return result;
      },
    });

    api.addToHeaderIcons("discourse-rewards-available-points");
  }
}

export default {
  name: "discourse-rewards",

  initialize(container) {
    const siteSettings = container.lookup("site-settings:main");
    if (siteSettings.discourse_rewards_enabled) {
      withPluginApi("0.10.1", initializeDiscourseRewards);
    }
  },
};
