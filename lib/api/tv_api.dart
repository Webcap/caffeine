import 'dart:async';
import 'dart:io';

import 'package:login/models/tv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login/models/tv_stream.dart';
import 'dart:convert';

import 'package:login/utils/config.dart';

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
    try {
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      tvVideoSources = TVVideoSources.fromJson(decodeRes);
    } finally {
      client.close();
    }
    return tvVideoSources;
  }

  Future<TVInfo> getTVStreamEpisodes(String api) async {
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
