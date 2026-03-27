// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:caffiene/provider/app_dependency_provider.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/utils/config_api.dart';
import 'package:caffiene/video_providers/provider_names.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

/// Response from GET /status on caffeine-api.
class _StatusResponse {
  final String status; // "ok" | "degraded"
  final String? version;
  final _Uptime? uptime;
  final String? timestamp;

  const _StatusResponse({
    required this.status,
    this.version,
    this.uptime,
    this.timestamp,
  });

  static _StatusResponse? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    _Uptime? uptime;
    if (json['uptime'] is Map) {
      final u = json['uptime'] as Map;
      uptime = _Uptime(
        seconds: (u['seconds'] is int) ? u['seconds'] as int : null,
        human: u['human']?.toString(),
      );
    }
    return _StatusResponse(
      status: json['status']?.toString() ?? 'unknown',
      version: json['version']?.toString(),
      uptime: uptime,
      timestamp: json['timestamp']?.toString(),
    );
  }
}

class _Uptime {
  final int? seconds;
  final String? human;
  const _Uptime({this.seconds, this.human});
}

/// One scraper provider from GET /providers/status (includes active flag).
class _ScraperProvider {
  final String id;
  final String name;
  final bool active;
  const _ScraperProvider(
      {required this.id, required this.name, required this.active});
}

// ─── Design tokens (design.json) ─────────────────────────────────────────────
class _Design {
  static const primary = Color(0xFFDC2626);
  static const success = Color(0xFF22C55E);

  static const bgCanvasDark = Color(0xFF030712);
  static const bgCanvasLight = Color(0xFFF8FAFC);
  static const bgSurfaceDark = Color(0xFF0B0F14);
  static const bgSurfaceLight = Color(0xFFFFFFFF);
  static const borderDark = Color(0x14FFFFFF);
  static const borderLight = Color(0x140F172A);
  static const iconBgDark = Color(0x14FFFFFF);

  static const textPrimDark = Color(0xFFFFFFFF);
  static const textPrimLight = Color(0xFF0B0F14);
  static const textSecDark = Color(0xB8FFFFFF);
  static const textSecLight = Color(0xFF64748B);

  static const radiusMd = 16.0;
  static const screenPadH = 24.0;
  static const space2 = 8.0;
  static const space4 = 16.0;
  static const shadowCard = BoxShadow(
    color: Color(0x38000000),
    blurRadius: 30,
    offset: Offset(0, 10),
  );

  static const _checkTimeout = Duration(seconds: 10);
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textSec;

  const _StatusRow({
    required this.label,
    required this.value,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(color: textSec, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: textSec, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

enum _ApiStatus { idle, checking, available, unavailable }

class ServerStatusScreen extends StatefulWidget {
  const ServerStatusScreen({super.key});

  @override
  State<ServerStatusScreen> createState() => _ServerStatusScreenState();
}

class _ServerStatusScreenState extends State<ServerStatusScreen> {
  _ApiStatus _status = _ApiStatus.idle;
  int? _responseMs;
  String? _errorMessage;
  _StatusResponse? _statusResponse;
  List<_ScraperProvider> _scraperProviders = [];
  bool _refreshInProgress = false;

  String get _apiBaseUrl {
    final url = Provider.of<AppDependencyProvider>(context, listen: false)
        .caffeineAPIURL;
    if (url.isEmpty) return '';
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Future<void> _checkCaffeineApi() async {
    final baseUrl = _apiBaseUrl;
    debugPrint('[ServerStatus] Checking Caffeine API...');
    if (baseUrl.isEmpty) {
      debugPrint('[ServerStatus] API URL not set — skipping check');
      if (mounted) {
        setState(() {
          _status = _ApiStatus.unavailable;
          _errorMessage = 'API URL not set';
        });
      }
      return;
    }
    final checkUrl = '$baseUrl/status';
    debugPrint('[ServerStatus] URL: $checkUrl');

    if (mounted)
      setState(() {
        _status = _ApiStatus.checking;
        _responseMs = null;
        _errorMessage = null;
        _statusResponse = null;
      });

    final stopwatch = Stopwatch()..start();
    try {
      final uri = Uri.parse(checkUrl);
      final response = await http.get(uri).timeout(
            _Design._checkTimeout,
            onTimeout: () => throw Exception('Timeout'),
          );
      stopwatch.stop();
      final ms = stopwatch.elapsedMilliseconds;

      _StatusResponse? statusResponse;
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>?;
          statusResponse = _StatusResponse.fromJson(json);
          debugPrint(
              '[ServerStatus] Caffeine API /status OK — ${statusResponse?.status} — ${ms}ms');
        } catch (_) {
          debugPrint(
              '[ServerStatus] Caffeine API OK but invalid JSON — ${ms}ms');
        }
      } else {
        debugPrint(
            '[ServerStatus] Caffeine API failed HTTP ${response.statusCode} — ${ms}ms');
      }

      if (mounted) {
        setState(() {
          _status = response.statusCode == 200
              ? _ApiStatus.available
              : _ApiStatus.unavailable;
          _responseMs = ms;
          _errorMessage =
              response.statusCode == 200 ? null : 'HTTP ${response.statusCode}';
          _statusResponse = statusResponse;
          _scraperProviders = [];
        });
        if (response.statusCode == 200 && baseUrl.isNotEmpty) {
          _fetchScraperProviders(baseUrl);
        }
      }
    } catch (e) {
      stopwatch.stop();
      final ms = stopwatch.elapsedMilliseconds;
      debugPrint('[ServerStatus] Caffeine API error: $e — ${ms}ms');
      if (mounted) {
        setState(() {
          _status = _ApiStatus.unavailable;
          _responseMs = ms;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _statusResponse = null;
          _scraperProviders = [];
        });
      }
    }
  }

  Future<void> _fetchScraperProviders(String baseUrl) async {
    final uri = Uri.parse('$baseUrl/providers/status');
    try {
      final response = await http.get(uri).timeout(
            const Duration(seconds: 25),
            onTimeout: () => throw Exception('Timeout'),
          );
      if (!mounted || response.statusCode != 200) return;
      final json = jsonDecode(response.body);
      if (json is! Map || json['providers'] is! List) return;
      final list = <_ScraperProvider>[];
      final checkable = ProviderNames.checkableCodeNames;
      for (final e in json['providers'] as List) {
        if (e is Map) {
          final id = e['id']?.toString();
          final name = e['name']?.toString() ?? id ?? '';
          final active = e['active'] == true;
          if (id != null && id.isNotEmpty && checkable.contains(id)) {
            list.add(_ScraperProvider(id: id, name: name, active: active));
          }
        }
      }
      list.sort((a, b) => a.name.compareTo(b.name));
      if (mounted) setState(() => _scraperProviders = list);
    } catch (_) {
      if (mounted) setState(() => _scraperProviders = []);
    }
  }

  Future<void> _refreshConfigAndCheck() async {
    final appDep = Provider.of<AppDependencyProvider>(context, listen: false);
    debugPrint('[ServerStatus] Refreshing config...');
    if (!mounted) return;
    setState(() => _refreshInProgress = true);
    try {
      await refreshConfig(appDep);
      debugPrint('[ServerStatus] Config refreshed, re-checking API');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('config_refreshed'))),
        );
        await _checkCaffeineApi();
      }
    } catch (e) {
      debugPrint('[ServerStatus] Refresh config error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tr("error_occured")}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _refreshInProgress = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkCaffeineApi());
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';
    final bg = isDark ? _Design.bgCanvasDark : _Design.bgCanvasLight;
    final surface = isDark ? _Design.bgSurfaceDark : _Design.bgSurfaceLight;
    final textPrim = isDark ? _Design.textPrimDark : _Design.textPrimLight;
    final textSec = isDark ? _Design.textSecDark : _Design.textSecLight;
    final border = isDark ? _Design.borderDark : _Design.borderLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface,
        leading: Padding(
          padding: const EdgeInsets.only(left: _Design.space2),
          child: Material(
            color: isDark ? _Design.iconBgDark : border,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child:
                    Icon(Icons.arrow_back_rounded, size: 22, color: textPrim),
              ),
            ),
          ),
        ),
        iconTheme: IconThemeData(color: textPrim),
        title: Text(
          tr('check_server'),
          style: TextStyle(
            color: textPrim,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(_Design.screenPadH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            // Status card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(_Design.radiusMd),
                border: Border.all(color: border),
                boxShadow: const [_Design.shadowCard],
              ),
              padding: const EdgeInsets.all(_Design.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark ? _Design.iconBgDark : border,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _status == _ApiStatus.checking
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                _status == _ApiStatus.available
                                    ? Icons.check_circle_rounded
                                    : Icons.error_rounded,
                                size: 28,
                                color: _status == _ApiStatus.available
                                    ? _Design.success
                                    : _Design.primary,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Caffeine API',
                              style: TextStyle(
                                color: textPrim,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _status == _ApiStatus.checking
                                  ? tr('checking_server')
                                  : _status == _ApiStatus.available
                                      ? (_statusResponse?.status == 'degraded'
                                          ? '${tr('server_working')} (degraded)'
                                          : tr('server_working'))
                                      : _status == _ApiStatus.unavailable
                                          ? (_errorMessage ?? tr('server_down'))
                                          : tr('checking_server'),
                              style: TextStyle(
                                color: textSec,
                                fontSize: 14,
                              ),
                            ),
                            if (_responseMs != null &&
                                _status != _ApiStatus.checking) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${_responseMs}ms',
                                style: TextStyle(
                                  color: textSec,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_statusResponse != null &&
                      _status != _ApiStatus.checking &&
                      (_statusResponse!.version != null ||
                          _statusResponse!.uptime != null)) ...[
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    if (_statusResponse!.version != null)
                      _StatusRow(
                        label: 'Version',
                        value: _statusResponse!.version!,
                        textSec: textSec,
                      ),
                    if (_statusResponse!.uptime?.human != null) ...[
                      const SizedBox(height: 6),
                      _StatusRow(
                        label: 'Uptime',
                        value: _statusResponse!.uptime!.human!,
                        textSec: textSec,
                      ),
                    ],
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Scraper providers (from API /providers)
            if (_status == _ApiStatus.available &&
                _scraperProviders.isNotEmpty) ...[
              Text(
                'Scraper providers',
                style: TextStyle(
                  color: textSec,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(_Design.radiusMd),
                  border: Border.all(color: border),
                  boxShadow: const [_Design.shadowCard],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: _Design.space4,
                  vertical: _Design.space2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _scraperProviders
                      .map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: p.active
                                        ? _Design.success
                                        : _Design.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    p.name,
                                    style: TextStyle(
                                      color: textPrim,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  p.active
                                      ? tr('server_working')
                                      : tr('server_down'),
                                  style: TextStyle(
                                    color: textSec,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Check again
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed:
                    _status == _ApiStatus.checking ? null : _checkCaffeineApi,
                icon: _status == _ApiStatus.checking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, size: 22),
                label: Text(tr('check')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _Design.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_Design.radiusMd),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Refresh config
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _refreshInProgress ? null : _refreshConfigAndCheck,
                icon: _refreshInProgress
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync_rounded, size: 22),
                label: Text(tr('refresh_config')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textPrim,
                  side: BorderSide(color: border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_Design.radiusMd),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
