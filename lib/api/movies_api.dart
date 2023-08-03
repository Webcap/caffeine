import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:caffiene/models/watch_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:caffiene/models/credits.dart';
import 'package:caffiene/models/genres.dart';
import 'package:caffiene/models/images.dart';
import 'package:caffiene/models/movie_models.dart';
import 'package:caffiene/models/movie_stream.dart';
import 'package:caffiene/models/person.dart';
import 'package:caffiene/models/videos.dart';
import 'package:caffiene/models/watch_providers.dart';
import 'package:caffiene/utils/config.dart';

class moviesApi {
  final Dio _dio = Dio();

  final String baseUrl = 'https://api.themoviedb.org/3';
  final String apiKey = 'api_key=b9c827ddc7e3741ed414d8731814ecc9';

  Future<List<Genres>> fetchGenre(String api) async {
    GenreList newGenreList;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    newGenreList = GenreList.fromJson(decodeRes);
    return newGenreList.genre ?? [];
  }

  Future<MovieVideoSources> getMovieStreamLinksAndSubs(String api) async {
    MovieVideoSources movieVideoSources;
    try {
      print(api);
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      movieVideoSources = MovieVideoSources.fromJson(decodeRes);
    } finally {
      client.close();
    }
    return movieVideoSources;
  }

  Future<List<MovieEpisodes>> getMovieStreamEpisodes(String api) async {
    MovieInfo movieInfo;
    try {
      print(api);
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      movieInfo = MovieInfo.fromJson(decodeRes);
    } finally {
      client.close();
    }

    return movieInfo.episodes ?? [];
  }

  Future<List<MovieResults>> fetchMoviesForStream(String api) async {
    MovieStream movieStream;
    try {
      print(api);
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      movieStream = MovieStream.fromJson(decodeRes);
    } finally {
      client.close();
    }
    return movieStream.results ?? [];
  }

  Future<WatchProviders> fetchWatchProviders(String api, String country) async {
    WatchProviders watchProviders;
    try {
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      watchProviders = WatchProviders.fromJson(decodeRes, country);
    } finally {
      client.close();
    }
    return watchProviders;
  }

  Future<Images> fetchImages(String api) async {
    Images images;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    images = Images.fromJson(decodeRes);
    return images;
  }

  Future<Videos> fetchVideos(String api) async {
    Videos videos;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    videos = Videos.fromJson(decodeRes);
    return videos;
  }

  Future fetchCollectionDetails(String api) async {
    CollectionDetails collectionDetails;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    collectionDetails = CollectionDetails.fromJson(decodeRes);
    return collectionDetails;
  }

  Future<List<Movie>> fetchCollectionMovies(String api) async {
    CollectionMovieList collectionMovieList;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    collectionMovieList = CollectionMovieList.fromJson(decodeRes);
    return collectionMovieList.movies ?? [];
  }

  Future fetchSocialLinks(String api) async {
    ExternalLinks externalLinks;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    externalLinks = ExternalLinks.fromJson(decodeRes);
    return externalLinks;
  }

  Future fetchBelongsToCollection(String api) async {
    BelongsToCollection belongsToCollection;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    belongsToCollection = BelongsToCollection.fromJson(decodeRes);
    return belongsToCollection;
  }

  // Future<HTTPResponse<List<Mixed>>> getTrendingAll() async {
  //   final url = '$baseUrl/trending/all/week?$apiKey';
  //   final uri = Uri.parse(url);
  //   try {
  //     var response = await http.get(uri);
  //     if (response.statusCode == 200) {
  //       var body = json.decode(response.body);
  //       List<Mixed> mixedList = [];
  //       body.forEach((e) {
  //         Mixed mixed = Mixed.fromJson(e);
  //         mixedList.add(mixed);
  //       });
  //       return HTTPResponse(
  //         true,
  //         mixedList,
  //         statusCode: response.statusCode
  //       );
  //     } else {
  //       return HTTPResponse(
  //         false,
  //         null,
  //         message: 'invaild response from server',
  //         statusCode: response.statusCode);
  //     }
  //   } on SocketException {

  //   }
  // }

  Future<Credits> fetchCredits(String api) async {
    Credits credits;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    credits = Credits.fromJson(decodeRes);
    return credits;
  }

  Future<List<Movie>> fetchPersonMovies(String api) async {
    PersonMoviesList personMoviesList;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    personMoviesList = PersonMoviesList.fromJson(decodeRes);
    return personMoviesList.movies ?? [];
  }

  Future<PersonImages> fetchPersonImages(String api) async {
    PersonImages personImages;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    personImages = PersonImages.fromJson(decodeRes);
    return personImages;
  }

  Future<List<Mixed>> getTrendingAll() async {
    print("about to get all data");
    try {
      final url = '$baseUrl/trending/all/week?$apiKey';
      final response = await _dio.get(url);
      var mixed = response.data['results'] as List;
      List<Mixed> mixedList = mixed.map((m) => Mixed.fromJson(m)).toList();
      print(mixed);
      return mixedList;
    } catch (error, stacktrace) {
      throw Exception(
          'Exception accoured: $error with stacktrace: $stacktrace');
    }
  }

  Future<List<Movie>> getTrendingMovie() async {
    try {
      final url = '$baseUrl/trending/movie/week?$apiKey';
      final response = await _dio.get(url);
      var movies = response.data['results'] as List;
      List<Movie> movieList = movies.map((m) => Movie.fromJson(m)).toList();
      return movieList;
    } catch (error, stacktrace) {
      throw Exception(
          'Exception accoured: $error with stacktrace: $stacktrace');
    }
  }

  Future<Moviedetail> fetchMovieDetails(String api) async {
    Moviedetail movieDetails;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    movieDetails = Moviedetail.fromJson(decodeRes);
    return movieDetails;
  }

  Future<List<Movie>> fetchMovies(String api) async {
    MovieList movieList;

    try {
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      movieList = MovieList.fromJson(decodeRes);
    } finally {
      client.close();
    }

    return movieList.movies ?? [];
  }

  Future<PersonDetails> fetchPersonDetails(String api) async {
    PersonDetails personDetails;
    var res = await http
        .get(Uri.parse(api))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      return http.Response('Error', 408);
    }).onError((error, stackTrace) => http.Response('Error', 408));
    var decodeRes = jsonDecode(res.body);
    personDetails = PersonDetails.fromJson(decodeRes);
    return personDetails;
  }

  Future<Moviedetail> getMovieDetail(String id) async {
    try {
      final url = '$baseUrl/movie/$id?$apiKey';
      final response = await _dio.get(url);
      var movies = response.data;
      Moviedetail movie = Moviedetail.fromJson(response.data);
      return movie;
    } catch (error, stacktrace) {
      throw Exception(
          'Exception accoured: $error with stacktrace: $stacktrace');
    }
  }

  void addWatchHistory(
      int movieID, String movieTitle, DateTime watchedAt, bool completed) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user!.uid;

    FirebaseFirestore firebaseInstance = FirebaseFirestore.instance;

    // Creates a new Watch history event
    WatchHistoryEntry watchHistoryEntry = WatchHistoryEntry(
      movieID: movieID,
      movieTitle: movieTitle,
      dateTime: watchedAt,
      completed: completed,
    );

    // Save the watch history entry to Firebase.
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('watchHistory')
        .add(watchHistoryEntry.toJson());

    print('Well we made it this far');
  }
}
