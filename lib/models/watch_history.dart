class WatchHistoryEntry {
  int movieID;
  String movieTitle;
  DateTime dateTime;
  bool completed;

  WatchHistoryEntry({
    required this.movieID,
    required this.movieTitle,
    required this.dateTime,
    required this.completed,
  });

  Map<String, dynamic> toJson() {
    return {
      'movieID': movieID,
      'movieTitle': movieTitle,
      'dateTime': dateTime.toIso8601String(),
      'completed': completed,
    };
  }
}
