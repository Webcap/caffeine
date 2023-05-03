import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:login/models/tv.dart';
import 'package:http/http.dart' as http;
import 'package:login/models/update.dart';
import 'package:login/utils/config.dart';

Future<String> getVttFileAsString(String url) async {
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
