import DiscourseRoute from "discourse/routes/discourse";

export default DiscourseRoute.extend({
  redirect(model, transition) {
    this.transitionTo(transition.targetName);
  },
});
