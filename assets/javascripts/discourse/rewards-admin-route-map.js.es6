export default {
  resource: "admin",
  map() {
    this.route(
      "adminRewards",
      { path: "/rewards", resetNamespace: true },
      function () {
        this.route("grant");
        this.route("campaign");
      }
    );
  },
};
