import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:caffiene/models/external_subtitles.dart';
import 'package:caffiene/models/live_tv.dart';
import 'package:caffiene/models/movie_stream.dart';
import 'package:caffiene/models/tv_stream.dart';
import 'package:flutter/material.dart';
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
  final PermissionStatus status = await Permission.notification.status;
  if (!status.isGranted && !status.isPermanentlyDenied) {
    Permission.notification.request();
  }
}


/// Stream TMDB route
Future<MovieInfoTMDBRoute> getMovieStreamEpisodesTMDB(String api) async {
  MovieInfoTMDBRoute movieInfo;
  int tries = 5;
  dynamic decodeRes;
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      decodeRes = jsonDecode(res.body);

      if (decodeRes.containsKey('error')) {
        --tries;
      } else {
        break;
      }
    }
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

Future<List<SubtitleData>> getExternalSubtitle(String api, String key) async {
  ExternalSubtitle subData;

  try {
    var res = await retryOptions.retry(
      () =>
          http.get(Uri.parse(api), headers: {"Api-Key": key}).timeout(timeOut),
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
    String api, int fileId, String key) async {
  SubtitleDownload sub;
  final Map<String, String> headers = {
    'User-Agent': 'Caffeine v1.3.1',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Api-Key': key
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

Future<bool> checkConnection() async {
  bool isInternetWorking;
  try {
    final response = await InternetAddress.lookup('google.com');

    isInternetWorking = response.isNotEmpty;
  } on SocketException catch (e) {
    debugPrint(e.toString());
    isInternetWorking = false;
  }

  return isInternetWorking;
}

String removeCharacters(String input) {
  String charactersToRemove = ",.?\"'";
  String pattern = '[$charactersToRemove]';
  String result = input.replaceAll(RegExp(pattern), '');
  return result;
}

Future<bool> clearTempCache() async {
  try {
    Directory tempDir = await getTemporaryDirectory();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
      return true;
    } else {
      return false;
    }
  } catch (e) {
    throw Exception("Failed to clear temp files");
  }
}

Future<bool> clearCache() async {
  try {
    Directory cacheDir = await getApplicationCacheDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
      return true;
    } else {
      return false;
    }
  } catch (e) {
    throw Exception("Failed to clear cache");
  }
}

void fileDelete() async {
  for (int i = 0; i < appNames.length; i++) {
    File file =
        File("${(await getApplicationSupportDirectory()).path}${appNames[i]}");
    if (file.existsSync()) {
      file.delete();
    }
  }
}

Future<TMA> fetchTMA(String uri) async {
  TMA tma;
  try {
    var response = await retryOptions.retry(
      () => http.get(Uri.parse(uri)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(response.body);
    tma = TMA.fromJson(decodeRes);
  } finally {
    client.close();
  }

  return tma;
}

