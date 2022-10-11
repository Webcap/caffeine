import 'package:login/utils/config.dart';

class Endpoints {
  static String movieDetailsUrl(int movieId) {
    return '$TMDB_API_BASE_URL/movie/$movieId?api_key=$TMDB_API_KEY';
  }
}
