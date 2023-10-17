import 'dart:async';
import 'dart:io';

import 'package:caffiene/models/tv.dart';
import 'package:http/http.dart' as http;
import 'package:caffiene/models/tv_stream.dart';
import 'dart:convert';

import 'package:caffiene/utils/config.dart';

class tvApi {
  Future<List<TV>> fetchPersonTV(String api) async {
    PersonTVList personTVList;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    personTVList = PersonTVList.fromJson(decodeRes);
    return personTVList.tv ?? [];
  }

  Future<List<TV>> fetchTV(String api) async {
    TVList tvList;
    try {
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      tvList = TVList.fromJson(decodeRes);
    } finally {
      client.close();
    }
    return tvList.tvSeries ?? [];
  }

  Future<TVVideoSources> getTVStreamLinksAndSubs(String api) async {
    TVVideoSources tvVideoSources;
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
        if (decodeRes.containsKey('message')) {
          --tries;
        } else {
          break;
        }
      }

      tvVideoSources = TVVideoSources.fromJson(decodeRes);
    } finally {
      client.close();
    }
    return tvVideoSources;
  }

  Future<TVInfo> getTVStreamEpisodes(String api) async {
    print(api);
    TVInfo tvInfo;
    try {
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      tvInfo = TVInfo.fromJson(decodeRes);
    } finally {
      client.close();
    }

    return tvInfo;
  }

  Future<List<TVResults>> fetchTVForStream(String api) async {
    TVStream tvStream;
    print(api);
    try {
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      tvStream = TVStream.fromJson(decodeRes);
    } finally {
      client.close();
    }
    return tvStream.results ?? [];
  }

  Future<TVDetails> fetchTVDetails(String api) async {
    TVDetails tvDetails;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    tvDetails = TVDetails.fromJson(decodeRes);
    return tvDetails;
  }
}
