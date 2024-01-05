import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:caffiene/models/custom_exceptions.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:caffiene/video_providers/flixhq.dart';
import 'package:caffiene/video_providers/provider_names.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:path_provider/path_provider.dart';
import 'package:caffiene/models/external_subtitles.dart';
import 'package:caffiene/models/live_tv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:caffiene/models/update.dart';
import 'package:caffiene/utils/config.dart';
import 'package:permission_handler/permission_handler.dart';


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
  String charactersToRemove = "|^_/,.?\"'&#^*%@!-[]()\$";
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

int totalStreamingDuration = 0; // Keep track of the total streaming duration

// Function to update and log the aggregate streaming duration
void updateAndLogTotalStreamingDuration(int durationInSeconds) {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  totalStreamingDuration += durationInSeconds;

  // Log the new total duration as a custom event for tracking purposes
  analytics.logEvent(
    name: 'total_streaming_duration',
    parameters: <String, dynamic>{
      'duration_seconds': totalStreamingDuration,
    },
  );
}

String generateCacheKey() {
  Random random = Random();

  List<String> characters = [];
  String generatedChars = "";

  for (var i = 0; i < 26; i++) {
    characters.add(String.fromCharCode(97 + i)); // Lowercase letters a-z
  }

  for (var i = 0; i < 26; i++) {
    characters.add(String.fromCharCode(65 + i)); // Uppercase letters A-Z
  }

  for (var i = 0; i < 10; i++) {
    characters.add(i.toString()); // Numbers 0-9
  }

  characters.add('-');

  int min = 0;
  int max = characters.length - 1;
  int randomInt;

  for (int i = 0; i < 50; i++) {
    randomInt = min + random.nextInt(max - min + 1);
    generatedChars += characters[randomInt];
  }

  return generatedChars;
}

String processVttFileTimestamps(String vttFile) {
  final lines = vttFile.split('\n');
  final processedLines = <String>[];

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.contains('-->') && line.trim().length == 23) {
      String endTimeModifiedString =
          '${line.trim().substring(0, line.trim().length - 9)}00:${line.trim().substring(line.trim().length - 9)}';
      String finalStr = '00:$endTimeModifiedString';
      processedLines.add(finalStr);
    } else {
      processedLines.add(line);
    }
  }

  return processedLines.join('\n');
}

List<VideoProvider?> parseProviderPrecedenceString(String raw) {
  List<VideoProvider?> videoProviders = raw.split(' ').map((providerString) {
    List<String> parts = providerString.split('-');
    if (parts.length == 2) {
      return VideoProvider(fullName: parts[1], codeName: parts[0]);
    } else {}
  }).toList();

  return videoProviders;
}
