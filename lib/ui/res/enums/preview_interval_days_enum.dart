enum PreviewIntervalDays {
  day(interval: "1"),
  week(interval: "7"),
  month(interval: "30"),
  year(interval: "365");

  final String interval;
  const PreviewIntervalDays({required this.interval});
}
