enum PreviewIntervalType {
  hourly(interval: "hourly"),
  daily(interval: "daily");

  final String interval;

  const PreviewIntervalType({required this.interval});
}
