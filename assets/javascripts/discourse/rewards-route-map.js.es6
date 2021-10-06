export default function () {
  this.route("available-rewards", {
    path: "/available-rewards",
    resetNamespace: true,
  });

  this.route("leaderboard", {
    path: "/leaderboard",
    resetNamespace: true,
  });
}
