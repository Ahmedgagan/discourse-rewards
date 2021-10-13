export default function () {
  this.route(
    "pointsCenter",
    {
      path: "/points-center",
      resetNamespace: true,
    },
    function () {
      this.route("available-rewards");
      this.route("leaderboard");
    }
  );
}
