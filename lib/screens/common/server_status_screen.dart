// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/provider/settings_provider.dart';
import 'package:reelriot/video_providers/provider_names.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../utils/constant.dart';

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

// ─────────────────────────────────────────────
//  Design Tokens
// ─────────────────────────────────────────────
abstract class _D {
  static const Color bg = Color(0xFF080B12);
  static const Color surface = Color(0xFF0E1219);
  static const Color surfaceAlt = Color(0xFF131822);
  static const Color red = Color(0xFFE02020);
  static const Color redGlow = Color(0x40E02020);
  static const Color redDim = Color(0x1AE02020);
  static const Color green = Color(0xFF22C55E);
  static const Color greenGlow = Color(0x4022C55E);
  static const Color greenDim = Color(0x1A22C55E);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberDim = Color(0x1AF59E0B);
  
  static const Color white = Color(0xFFFFFFFF);
  static const Color white72 = Color(0xB8FFFFFF);
  static const Color white40 = Color(0x66FFFFFF);
  static const Color white12 = Color(0x1FFFFFFF);
  static const Color white06 = Color(0x0FFFFFFF);

  static const double radiusCard = 24.0;
  static const double radiusMd = 16.0;
  static const double radiusPill = 999.0;

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x60000000), blurRadius: 36, offset: Offset(0, 16)),
  ];
  static const List<BoxShadow> redShadow = [
    BoxShadow(color: Color(0x55E02020), blurRadius: 28, offset: Offset(0, 8)),
  ];

  static LinearGradient get cardGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF141923), Color(0xFF0A0E16)],
      );

  static LinearGradient get redGradient => const LinearGradient(
        colors: [Color(0xFFE02020), Color(0xFFC01010)],
      );

  static const _checkTimeout = Duration(seconds: 10);
}

enum _ApiStatus { idle, checking, available, unavailable }

class ServerStatusScreen extends StatefulWidget {
  const ServerStatusScreen({super.key});

  @override
  State<ServerStatusScreen> createState() => _ServerStatusScreenState();
}

class _ServerStatusScreenState extends State<ServerStatusScreen>
    with SingleTickerProviderStateMixin {
  _ApiStatus _status = _ApiStatus.idle;
  int? _responseMs;
  String? _errorMessage;
  _StatusResponse? _statusResponse;
  List<_ScraperProvider> _scraperProviders = [];
  late final AnimationController _pulseCtrl;

  String get _apiBaseUrl {
    final url = Provider.of<AppDependencyProvider>(context, listen: false)
        .caffeineAPIURL;
    if (url.isEmpty) return '';
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkCaffeineApi());
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkCaffeineApi() async {
    final baseUrl = _apiBaseUrl;
    debugPrint('[ServerStatus] Checking Reelriot API...');
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

    if (mounted) {
      setState(() {
        _status = _ApiStatus.checking;
        _responseMs = null;
        _errorMessage = null;
        _statusResponse = null;
      });
    }

    final stopwatch = Stopwatch()..start();
    try {
      final uri = Uri.parse(checkUrl);
      final response = await http.get(uri, headers: caffeineApiHeaders).timeout(
            _D._checkTimeout,
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
              '[ServerStatus] Reelriot API /status OK — ${statusResponse?.status} — ${ms}ms');
        } catch (_) {
          debugPrint(
              '[ServerStatus] Reelriot API OK but invalid JSON — ${ms}ms');
        }
      } else {
        debugPrint(
            '[ServerStatus] Reelriot API failed HTTP ${response.statusCode} — ${ms}ms');
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
      debugPrint('[ServerStatus] Reelriot API error: $e — ${ms}ms');
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
      final response = await http.get(uri, headers: caffeineApiHeaders).timeout(
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

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isDark = themeMode == 'dark' || themeMode == 'amoled';

    return Scaffold(
      backgroundColor: isDark ? _D.bg : Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Material(
            color: isDark ? _D.white06 : Colors.black12,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              customBorder: const CircleBorder(),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: isDark ? _D.white72 : Colors.black87,
              ),
            ),
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? _D.white72 : Colors.black87),
        title: Text(
          tr('check_server'),
          style: TextStyle(
            color: isDark ? _D.white72 : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // Hero Server Card
                  _buildServerHeroCard(isDark),

                  const SizedBox(height: 24),

                  // Scraper providers section
                  if (_status == _ApiStatus.available &&
                      _scraperProviders.isNotEmpty) ...[
                    _buildScraperProvidersCard(isDark),
                    const SizedBox(height: 24),
                  ],

                  // Check button
                  _buildCheckButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServerHeroCard(bool isDark) {
    final isChecking = _status == _ApiStatus.checking;
    final isOnline = _status == _ApiStatus.available;
    final isDegraded = _statusResponse?.status == 'degraded';

    Color statusColor;
    Color statusDim;
    String statusTitle;
    IconData statusIcon;

    if (isChecking) {
      statusColor = _D.amber;
      statusDim = _D.amberDim;
      statusTitle = tr('checking_server');
      statusIcon = Icons.sync_rounded;
    } else if (isOnline) {
      if (isDegraded) {
        statusColor = _D.amber;
        statusDim = _D.amberDim;
        statusTitle = '${tr('server_working')} (Degraded)';
        statusIcon = Icons.warning_amber_rounded;
      } else {
        statusColor = _D.green;
        statusDim = _D.greenDim;
        statusTitle = tr('server_working');
        statusIcon = Icons.check_circle_rounded;
      }
    } else {
      statusColor = _D.red;
      statusDim = _D.redDim;
      statusTitle = _errorMessage ?? tr('server_down');
      statusIcon = Icons.cancel_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? _D.cardGradient : null,
        color: isDark ? null : Colors.white,
        borderRadius: BorderRadius.circular(_D.radiusCard),
        border: Border.all(color: isDark ? _D.white12 : Colors.black12),
        boxShadow: isDark ? _D.cardShadow : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Glowing Status Icon Box
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, child) {
                  final glowOpacity = isChecking
                      ? (_pulseCtrl.value * 0.4 + 0.1)
                      : (isOnline ? 0.35 : 0.25);
                  return Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: statusDim,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: glowOpacity),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: isChecking
                        ? const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: _D.amber,
                              ),
                            ),
                          )
                        : Icon(statusIcon, color: statusColor, size: 28),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reelriot API',
                      style: TextStyle(
                        color: isDark ? _D.white : Colors.black87,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusTitle,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (_responseMs != null && !isChecking)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (_responseMs! < 500
                            ? _D.green
                            : (_responseMs! < 1000 ? _D.amber : _D.red))
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: (_responseMs! < 500
                              ? _D.green
                              : (_responseMs! < 1000 ? _D.amber : _D.red))
                          .withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 13,
                        color: _responseMs! < 500
                            ? _D.green
                            : (_responseMs! < 1000 ? _D.amber : _D.red),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${_responseMs}ms',
                        style: TextStyle(
                          color: _responseMs! < 500
                              ? _D.green
                              : (_responseMs! < 1000 ? _D.amber : _D.red),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Metadata Chips (Version, Uptime)
          if (_statusResponse != null &&
              !isChecking &&
              (_statusResponse!.version != null ||
                  _statusResponse!.uptime?.human != null)) ...[
            const SizedBox(height: 20),
            Container(
              height: 1,
              color: isDark ? _D.white06 : Colors.black.withValues(alpha: 0.06),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_statusResponse!.version != null)
                  Expanded(
                    child: _buildMetaTile(
                      label: 'Version',
                      value: _statusResponse!.version!,
                      icon: Icons.tag_rounded,
                      isDark: isDark,
                    ),
                  ),
                if (_statusResponse!.version != null &&
                    _statusResponse!.uptime?.human != null)
                  const SizedBox(width: 12),
                if (_statusResponse!.uptime?.human != null)
                  Expanded(
                    child: _buildMetaTile(
                      label: 'Uptime',
                      value: _statusResponse!.uptime!.human!,
                      icon: Icons.access_time_rounded,
                      isDark: isDark,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaTile({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? _D.surfaceAlt : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? _D.white06 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? _D.white40 : Colors.black45,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? _D.white40 : Colors.black45,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? _D.white72 : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScraperProvidersCard(bool isDark) {
    final activeCount = _scraperProviders.where((p) => p.active).length;
    final totalCount = _scraperProviders.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Scraper providers',
                style: TextStyle(
                  color: isDark ? _D.white72 : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (activeCount > 0 ? _D.green : _D.red)
                      .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$activeCount / $totalCount Online',
                  style: TextStyle(
                    color: activeCount > 0 ? _D.green : _D.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: isDark ? _D.cardGradient : null,
            color: isDark ? null : Colors.white,
            borderRadius: BorderRadius.circular(_D.radiusCard),
            border: Border.all(color: isDark ? _D.white12 : Colors.black12),
            boxShadow: isDark ? _D.cardShadow : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _scraperProviders.length,
            separatorBuilder: (_, __) => Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: isDark ? _D.white06 : Colors.black.withValues(alpha: 0.04),
            ),
            itemBuilder: (context, index) {
              final p = _scraperProviders[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.active ? _D.green : _D.red,
                        boxShadow: [
                          BoxShadow(
                            color: (p.active ? _D.green : _D.red)
                                .withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        p.name,
                        style: TextStyle(
                          color: isDark ? _D.white : Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (p.active ? _D.green : _D.red)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        p.active ? tr('server_working') : tr('server_down'),
                        style: TextStyle(
                          color: p.active ? _D.green : _D.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCheckButton() {
    final isChecking = _status == _ApiStatus.checking;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_D.radiusPill),
        gradient: _D.redGradient,
        boxShadow: _D.redShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isChecking ? null : _checkCaffeineApi,
          borderRadius: BorderRadius.circular(_D.radiusPill),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isChecking)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _D.white,
                    ),
                  )
                else
                  const Icon(Icons.refresh_rounded, color: _D.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  tr('check'),
                  style: const TextStyle(
                    color: _D.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
