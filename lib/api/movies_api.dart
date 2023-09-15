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
    try {
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      newGenreList = GenreList.fromJson(decodeRes);
    } finally {
      client.close();
    }
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
    print('mov ep');
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
    print('ftc mov');
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
    try {
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      images = Images.fromJson(decodeRes);
    } finally {
      client.close();
    }
    return images;
  }

  Future<Videos> fetchVideos(String api) async {
    Videos videos;
    try {
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      videos = Videos.fromJson(decodeRes);
    } finally {
      client.close();
    }
    return videos;
  }

  Future fetchCollectionDetails(String api) async {
    CollectionDetails collectionDetails;
    try {
      var res = await retryOptions.retry(
        () => http.get(Uri.parse(api)).timeout(timeOut),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      collectionDetails = CollectionDetails.fromJson(decodeRes);
    } finally {
      client.close();
    }
    return collectionDetails;
  }

  Future<List<Movie>> fetchCollectionMovies(String api) async {
    CollectionMovieList collectionMovieList;
    try {
      var res = await retryOptions.retry(
        () => http.get(Uri.parse(api)).timeout(timeOut),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      collectionMovieList = CollectionMovieList.fromJson(decodeRes);
    } finally {
      client.close();
    }
    return collectionMovieList.movies ?? [];
  }

  Future fetchSocialLinks(String api) async {
    ExternalLinks externalLinks;
    try {
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      externalLinks = ExternalLinks.fromJson(decodeRes);
    } finally {
      client.close();
    }
    return externalLinks;
  }

  Future fetchBelongsToCollection(String api) async {
    BelongsToCollection belongsToCollection;
    try {
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      belongsToCollection = BelongsToCollection.fromJson(decodeRes);
    } finally {
      client.close();
    }
    return belongsToCollection;
  }

  Future<Credits> fetchCredits(String api) async {
    Credits credits;
    try {
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      credits = Credits.fromJson(decodeRes);
    } finally {
      client.close();
    }
    return credits;
  }

  Future<List<Movie>> fetchPersonMovies(String api) async {
    PersonMoviesList personMoviesList;
    try {
      var res = await retryOptions.retry(
        () => http.get(Uri.parse(api)).timeout(timeOut),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      personMoviesList = PersonMoviesList.fromJson(decodeRes);
    } finally {
      client.close();
    }
    return personMoviesList.movies ?? [];
  }

  Future<PersonImages> fetchPersonImages(String api) async {
    PersonImages personImages;
    try {
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      personImages = PersonImages.fromJson(decodeRes);
    } finally {
      client.close();
    }
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
    try {
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      movieDetails = Moviedetail.fromJson(decodeRes);
    } finally {
      client.close();
    }
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
    try {
      var res = await retryOptions.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOut)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      personDetails = PersonDetails.fromJson(decodeRes);
    } finally {
      client.close();
    }
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
}
