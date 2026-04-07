// ignore_for_file: unused_import

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:caffiene/video_providers/provider_names.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:caffiene/models/live_tv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:caffiene/utils/config.dart';
import 'package:caffiene/utils/globals.dart';
import 'package:permission_handler/permission_handler.dart';

String episodeSeasonFormatter(int episodeNumber, int seasonNumber) {
  String formattedSeason =
      seasonNumber <= 9 ? 'S0$seasonNumber' : 'S$seasonNumber';
  String formattedEpisode =
      episodeNumber <= 9 ? 'E0$episodeNumber' : 'E$episodeNumber';
  return "$formattedSeason : $formattedEpisode";
}

Future<void> requestNotificationPermissions() async {
  final PermissionStatus status = await Permission.notification.status;
  if (!status.isGranted && !status.isPermanentlyDenied) {
    Permission.notification.request();
  }
}

/// Checks if the device can reach the internet. Uses timeout and fallback
/// hosts so it works on 5G/mobile where some carriers block or delay DNS.
Future<bool> checkConnection() async {
  const timeout = Duration(seconds: 6);
  const hosts = ['google.com', 'cloudflare.com'];
  for (final host in hosts) {
    try {
      final response = await InternetAddress.lookup(host).timeout(timeout);
      if (response.isNotEmpty) return true;
    } on SocketException catch (e) {
      debugPrint('checkConnection($host): $e');
    } on TimeoutException {
      debugPrint('checkConnection($host): timeout');
    } catch (e) {
      debugPrint('checkConnection($host): $e');
    }
  }
  return false;
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

/// Automatically deletes any .apk files in the temporary directory.
/// Useful for cleaning up update installers after app restart.
Future<void> cleanupUpdateFiles() async {
  try {
    final tempDir = await getTemporaryDirectory();
    if (tempDir.existsSync()) {
      final files = tempDir.listSync();
      for (final file in files) {
        if (file is File && file.path.toLowerCase().endsWith('.apk')) {
          debugPrint('[Cleanup] Deleting update file: ${file.path}');
          await file.delete();
        }
      }
    }
  } catch (e) {
    debugPrint('[Cleanup] Error: $e');
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

Future<void> fileDelete() async {
  final directory = await getApplicationSupportDirectory();
  for (var name in appNames.values) {
    File file = File("${directory.path}/$name");
    if (file.existsSync()) {
      await file.delete();
    }
  }
}

int totalStreamingDuration = 0;

void updateAndLogTotalStreamingDuration(int durationInSeconds) {
  totalStreamingDuration += durationInSeconds;
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


List<VideoProvider?> parseProviderPrecedenceString(String raw) {
  List<VideoProvider?> videoProviders = raw.split(' ').map((providerString) {
    List<String> parts = providerString.split('-');
    if (parts.length == 2) {
      return VideoProvider(fullName: parts[1], codeName: parts[0]);
    } else {}
  }).toList();

  return videoProviders;
}

int createUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(100000);
}

bool isReleased(String target) {
  // Synchronize with TV app: Consider it released if air_date is before tomorrow.
  // This handles time zone differences and episodes airing today.
  DateTime now = DateTime.now();
  DateTime mediaDate = DateFormat('yyyy-MM-dd').parse(target);
  return mediaDate.isBefore(now.add(const Duration(days: 1)));
}

String normalizeTitle(String title) {
  return title
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[":\']'), '')
      .replaceAll(RegExp('[^a-zA-Z0-9]+'), '_');
}

String buildImageUrl(String baseImage, String proxyUrl, bool isProxyEnabled,
    BuildContext context) {
  String concatenated = baseImage;
  if (isProxyEnabled && proxyUrl.isNotEmpty) {
    concatenated = "$proxyUrl?destination=$baseImage";
  }

  return concatenated;
}
