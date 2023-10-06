import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:caffiene/main.dart';
import 'package:caffiene/models/external_subtitles.dart';
import 'package:caffiene/models/live_tv.dart';
import 'package:caffiene/models/movie_stream.dart';
import 'package:caffiene/models/tv_stream.dart';
import 'package:http/http.dart' as http;
import 'package:caffiene/models/update.dart';
import 'package:caffiene/utils/config.dart';
import 'package:permission_handler/permission_handler.dart';


Future<String> getVttFileAsString(String url) async {
  print(url);
  try {
    var response = await retryOptions.retry(
      () => http.get(Uri.parse(url)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final decoded = utf8.decode(bytes);
      return decoded;
    } else {
      throw Exception('Failed to load VTT file');
    }
  } finally {
    client.close();
  }
}

Future checkForUpdate(String api) async {
  UpdateChecker updateChecker;
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    updateChecker = UpdateChecker.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return updateChecker;
}

Future<List<Channel>> fetchChannels(String api) async {
  ChannelsList channelsList;
  print(api);
  try {
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    channelsList = ChannelsList.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return channelsList.channels ?? [];
}

String episodeSeasonFormatter(int episodeNumber, int seasonNumber) {
  String formattedSeason =
      seasonNumber <= 9 ? 'S0$seasonNumber' : 'S$seasonNumber';
  String formattedEpisode =
      episodeNumber <= 9 ? 'E0$episodeNumber' : 'E$episodeNumber';
  return "$formattedSeason | $formattedEpisode";
}

Future<void> requestNotificationPermissions() async {
  final PermissionStatus status = await Permission.notification.request();
  if (!status.isGranted && !status.isPermanentlyDenied) {
    Permission.notification.request();
  }
}

/// Stream TMDB route
Future<MovieInfoTMDBRoute> getMovieStreamEpisodesTMDB(String api) async {
  MovieInfoTMDBRoute movieInfo;
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    movieInfo = MovieInfoTMDBRoute.fromJson(decodeRes);
  } finally {
    client.close();
  }

  return movieInfo;
}

Future<TVTMDBRoute> getTVStreamEpisodesTMDB(String api) async {
  TVTMDBRoute tvInfo;
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    tvInfo = TVTMDBRoute.fromJson(decodeRes);
  } finally {
    client.close();
  }

  return tvInfo;
}

Future<List<SubtitleData>> getExternalSubtitle(String api) async {
  ExternalSubtitle subData;

  try {
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api), headers: {
        "Api-Key": appDependencyProvider.opensubtitlesKey
      }).timeout(timeOut),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );

    var decodeRes = jsonDecode(res.body);
    subData = ExternalSubtitle.fromJson(decodeRes);
  } finally {
    client.close();
  }

  return subData.data ?? [];
}

Future<SubtitleDownload> downloadExternalSubtitle(
    String api, int fileId) async {
  SubtitleDownload sub;
  final Map<String, String> headers = {
    'User-Agent': 'Cinemax v2.4.0',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Api-Key': appDependencyProvider.opensubtitlesKey
  };
  var body = '{"file_id":$fileId}';
  try {
    var response = await retryOptions.retry(
      () => http.post(Uri.parse(api), headers: headers, body: body),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(response.body);
    sub = SubtitleDownload.fromJson(decodeRes);
  } finally {
    client.close();
  }

  return sub;
}

