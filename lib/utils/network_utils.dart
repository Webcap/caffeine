import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';

/// Global HTTP client for connection pooling
final http.Client client = http.Client();

/// Standard retry configuration for network requests
const RetryOptions retryOptions = RetryOptions(
  maxAttempts: 3,
  delayFactor: Duration(milliseconds: 500),
);

/// Global timeout for network requests
const Duration timeOut = Duration(seconds: 15);

/// Modern browser-like User-Agent to bypass provider/TMDB filtering
const String browserUserAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36';
