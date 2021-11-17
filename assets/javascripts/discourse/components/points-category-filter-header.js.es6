// import DropdownSelectBoxHeaderComponent from "select-kit/components/dropdown-select-box/dropdown-select-box-header";
import SingleSelectHeaderComponent from "select-kit/components/select-kit/single-select-header";
import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import { fmt } from "discourse/lib/computed";

export default SingleSelectHeaderComponent.extend({
  classNames: ["points-category-filter-header"],

  label: fmt("value", "discourse_rewards.transaction.categories.%@"),

  @discourseComputed("selectKit.isExpanded")
  caretIcon(isExpanded) {
    return isExpanded ? "caret-up" : "caret-down";
  },
});
