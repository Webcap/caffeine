import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:caffiene/models/custom_exceptions.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:caffiene/video_providers/dcva.dart';
import 'package:caffiene/video_providers/dramacool.dart';
import 'package:caffiene/video_providers/flixhq.dart';
import 'package:caffiene/video_providers/flixhq_flixquest.dart';
import 'package:caffiene/video_providers/superstream.dart';
import 'package:caffiene/video_providers/zoro.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:caffiene/models/credits.dart';
import 'package:caffiene/models/genres.dart';
import 'package:caffiene/models/images.dart';
import 'package:caffiene/models/movie_models.dart';
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

  Future<FlixHQStreamSources> getMovieStreamLinksAndSubsFlixHQ(
      String api) async {
    FlixHQStreamSources movieVideoSources;
    int tries = 3;
    dynamic decodeRes;
    try {
      dynamic res;
      while (tries > 0) {
        res = await retryOptionsStream.retry(
          (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
          retryIf: (e) => e is SocketException || e is TimeoutException,
        );
        decodeRes = jsonDecode(res.body);
        if (decodeRes.containsKey('message')) {
          --tries;
        } else {
          break;
        }
      }
      if (decodeRes.containsKey('message') || res.statusCode != 200) {
        throw ServerDownException();
      }
      movieVideoSources = FlixHQStreamSources.fromJson(decodeRes);

      if (movieVideoSources.videoLinks == null ||
          movieVideoSources.videoLinks!.isEmpty) {
        throw NotFoundException();
      }
    } catch (e) {
      rethrow;
    }

    return movieVideoSources;
  }

  Future<List<FlixHQMovieInfoEntries>> getMovieStreamEpisodesFlixHQ(
      String api) async {
    FlixHQMovieInfo movieInfo;
    try {
      var res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message') || res.statusCode != 200) {
        throw ServerDownException();
      }
      movieInfo = FlixHQMovieInfo.fromJson(decodeRes);

      if (movieInfo.episodes == null || movieInfo.episodes!.isEmpty) {
        throw NotFoundException();
      }
    } catch (e) {
      rethrow;
    }

    return movieInfo.episodes ?? [];
  }

  Future<List<FlixHQMovieSearchEntry>> fetchMoviesForStreamFlixHQ(
      String api) async {
    FlixHQMovieSearch movieStream;
    try {
      var res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message') || res.statusCode != 200) {
        throw ServerDownException();
      }
      movieStream = FlixHQMovieSearch.fromJson(decodeRes);

      if (movieStream.results == null || movieStream.results!.isEmpty) {
        throw NotFoundException();
      }
    } catch (e) {
      rethrow;
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
    print(api);
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
      Moviedetail movie = Moviedetail.fromJson(response.data);
      return movie;
    } catch (error, stacktrace) {
      throw Exception(
          'Exception accoured: $error with stacktrace: $stacktrace');
    }
  }

  /// Superstream function(s)
  Future<SuperstreamStreamSources> getSuperstreamStreamingLinks(
      String api) async {
    SuperstreamStreamSources superstreamSources;
    int tries = 3;
    dynamic decodeRes;
    try {
      dynamic res;
      while (tries > 0) {
        res = await retryOptionsStream.retry(
          (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
          retryIf: (e) => e is SocketException || e is TimeoutException,
        );
        decodeRes = jsonDecode(res.body);
        if (decodeRes.containsKey('message')) {
          --tries;
        } else {
          break;
        }
      }

      if (decodeRes.containsKey('message') || res.statusCode != 200) {
        throw ServerDownException();
      }

      superstreamSources = SuperstreamStreamSources.fromJson(decodeRes);

      if (superstreamSources.videoLinks == null ||
          superstreamSources.videoLinks!.isEmpty) {
        throw NotFoundException();
      }
    } catch (e) {
      rethrow;
    }
    return superstreamSources;
  }

  Future<List<DCVAInfoEntries>> getMovieTVStreamEpisodesDCVA(String api) async {
    DCVAInfo dcvaInfo;
    try {
      var res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message') || res.statusCode != 200) {
        throw ServerDownException();
      }
      dcvaInfo = DCVAInfo.fromJson(decodeRes);

      if (dcvaInfo.episodes == null || dcvaInfo.episodes!.isEmpty) {
        throw NotFoundException();
      }
    } catch (e) {
      rethrow;
    }

    return dcvaInfo.episodes ?? [];
  }

  Future<DCVAStreamSources> getMovieTVStreamLinksAndSubsDCVA(String api) async {
    DCVAStreamSources dcvaVideoSources;
    int tries = 3;
    dynamic decodeRes;
    try {
      dynamic res;
      while (tries > 0) {
        res = await retryOptionsStream.retry(
          (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
          retryIf: (e) => e is SocketException || e is TimeoutException,
        );
        decodeRes = jsonDecode(res.body);
        if (decodeRes.containsKey('message')) {
          --tries;
        } else {
          break;
        }
      }
      if (decodeRes.containsKey('message') || res.statusCode != 200) {
        throw ServerDownException();
      }
      dcvaVideoSources = DramacoolStreamSources.fromJson(decodeRes);

      if (dcvaVideoSources.videoLinks == null ||
          dcvaVideoSources.videoLinks!.isEmpty) {
        throw NotFoundException();
      }
    } catch (e) {
      rethrow;
    }
    return dcvaVideoSources;
  }

  // ZORO MOVIE FUNCTIONS

  Future<List<ZoroSearchEntry>> fetchMovieTVForStreamZoro(String api) async {
    ZoroSearch zoroStream;
    try {
      var res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);

      if (decodeRes.containsKey('message') || res.statusCode != 200) {
        throw ServerDownException();
      }

      zoroStream = ZoroSearch.fromJson(decodeRes);
      if (zoroStream.results == null || zoroStream.results!.isEmpty) {
        throw NotFoundException();
      }
    } catch (e) {
      rethrow;
    }
    return zoroStream.results ?? [];
  }

  Future<List<ZoroInfoEntries>> getMovieTVStreamEpisodesZoro(String api) async {
    ZoroInfo zoroInfo;
    try {
      var res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      var decodeRes = jsonDecode(res.body);

      if (decodeRes.containsKey('message') || res.statusCode != 200) {
        throw ServerDownException();
      }
      zoroInfo = ZoroInfo.fromJson(decodeRes);

      if (zoroInfo.episodes == null || zoroInfo.episodes!.isEmpty) {
        throw NotFoundException();
      }
    } catch (e) {
      rethrow;
    }

    return zoroInfo.episodes ?? [];
  }

  Future<ZoroStreamSources> getMovieTVStreamLinksAndSubsZoro(String api) async {
    ZoroStreamSources zoroVideoSources;
    int tries = 3;
    dynamic decodeRes;
    try {
      dynamic res;
      while (tries > 0) {
        res = await retryOptionsStream.retry(
          (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
          retryIf: (e) => e is SocketException || e is TimeoutException,
        );
        decodeRes = jsonDecode(res.body);
        if (decodeRes.containsKey('message')) {
          --tries;
        } else {
          break;
        }
      }
      if (decodeRes.containsKey('message') || res.statusCode != 200) {
        throw ServerDownException();
      }
      zoroVideoSources = ZoroStreamSources.fromJson(decodeRes);

      if (zoroVideoSources.videoLinks == null ||
          zoroVideoSources.videoLinks!.isEmpty) {
        throw NotFoundException();
      }
    } catch (e) {
      rethrow;
    }
    return zoroVideoSources;
  }

  Future<FlixHQFlixQuestSources> getFlixHQCaffeineLinks(String api) async {
    FlixHQFlixQuestSources fqstreamSources;
    int tries = 3;
    dynamic decodeRes;
    try {
      dynamic res;
      while (tries > 0) {
        res = await retryOptionsStream.retry(
          (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
          retryIf: (e) => e is SocketException || e is TimeoutException,
        );
        decodeRes = jsonDecode(res.body);
        if (decodeRes.containsKey('message')) {
          --tries;
        } else {
          break;
        }
      }
      if (decodeRes.containsKey('message') || res.statusCode != 200) {
        throw ServerDownException();
      }
      fqstreamSources = FlixHQFlixQuestSources.fromJson(decodeRes);

      if (fqstreamSources.videoLinks == null ||
          fqstreamSources.videoLinks!.isEmpty) {
        throw NotFoundException();
      }
    } catch (e) {
      rethrow;
    }
    return fqstreamSources;
  }
}
