// ignore_for_file: must_be_immutable
import 'dart:io';
import 'dart:math' as math;
import 'package:reelriot/models/update.dart';
import 'package:reelriot/provider/app_dependency_provider.dart';
import 'package:reelriot/utils/globals.dart';
import 'package:reelriot/utils/config.dart';
import 'package:reelriot/utils/flavor_config.dart';
import 'package:reelriot/utils/version_utils.dart';
import 'package:reelriot/utils/config_api.dart';
import 'package:reelriot/services/file_opener_service.dart';
import 'package:reelriot/services/update_api_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reelriot/utils/version_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reelriot/translations/locale_keys.g.dart';

// ─────────────────────────────────────────────
//  Design Tokens
// ─────────────────────────────────────────────
abstract class _D {
  static const Color bg = Color(0xFF080B12);
  static const Color surface = Color(0xFF0E1219);
  static const Color surfaceAlt = Color(0xFF131822);
  static const Color red = Color(0xFFE02020);
  static const Color redGlow = Color(0x40E02020);
  static const Color redDim = Color(0x18E02020);
  static const Color white = Color(0xFFFFFFFF);
  static const Color white72 = Color(0xB8FFFFFF);
  static const Color white40 = Color(0x66FFFFFF);
  static const Color white12 = Color(0x1FFFFFFF);
  static const Color white06 = Color(0x0FFFFFFF);
  static const double radiusCard = 28.0;
  static const double radiusPill = 999.0;
  static const double radiusMd = 16.0;

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x60000000), blurRadius: 40, offset: Offset(0, 20)),
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
}

// ─────────────────────────────────────────────
//  Animated Glow Ring
// ─────────────────────────────────────────────
class _GlowRing extends StatefulWidget {
  final Widget child;
  const _GlowRing({required this.child});
  @override
  State<_GlowRing> createState() => _GlowRingState();
}

class _GlowRingState extends State<_GlowRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Stack(
        alignment: Alignment.center,
        children: [
          // outer glow ring
          Transform.scale(
            scale: _scale.value,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _D.red.withValues(alpha: _opacity.value),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _D.red.withValues(alpha: _opacity.value * 0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          child!,
        ],
      ),
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────
//  Update Screen
// ─────────────────────────────────────────────
class UpdateScreen extends StatefulWidget {
  static UpdateApiService? testApiService;
  static FileOpener? testFileOpener;
  static DownloadManager? testDownloadManager;

  const UpdateScreen({
    super.key,
    required this.isForced,
    this.updateApiService,
    this.fileOpener,
    this.downloadManager,
  });

  final bool isForced;
  final UpdateApiService? updateApiService;
  final FileOpener? fileOpener;
  final DownloadManager? downloadManager;

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen>
    with SingleTickerProviderStateMixin {
  AppUpdateInfo? _updateInfo;
  String? _errorMessage;
  var savedDir = '';

  late final DownloadManager downloadManager;
  late final UpdateApiService _apiService;
  late final FileOpener _fileOpener;
  late final AnimationController _entryCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _apiService = widget.updateApiService ??
        UpdateScreen.testApiService ??
        UpdateApiService();
    _fileOpener =
        widget.fileOpener ?? UpdateScreen.testFileOpener ?? FileOpener();
    downloadManager = widget.downloadManager ??
        UpdateScreen.testDownloadManager ??
        DownloadManager();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    for (var task in downloadManager.getAllDownloads()) {
      task.status.addListener(_updateWakelock);
    }
    _updateWakelock();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUpdate());
  }

  void _updateWakelock() {
    if (!mounted) return;
    final active = downloadManager.getAllDownloads().any((t) =>
        t.status.value == DownloadStatus.downloading ||
        t.status.value == DownloadStatus.queued);
    WakelockPlus.toggle(enable: active);
  }

  @override
  void dispose() {
    for (var task in downloadManager.getAllDownloads()) {
      task.status.removeListener(_updateWakelock);
    }
    _entryCtrl.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _checkUpdate() async {
    if (!mounted) return;
    setState(() {
      _errorMessage = null;
      _updateInfo = null;
    });
    try {
      final provider =
          Provider.of<AppDependencyProvider>(context, listen: false);
      final info = await _apiService.fetchUpdateInfo(provider);

      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      }
      dir ??= await getApplicationSupportDirectory();

      if (info.forcedUpdate || widget.isForced) {
        sendUpdateTelemetry(provider, eventType: 'forced_prompt_shown', isForced: true);
      }

      if (!mounted) return;
      setState(() {
        _updateInfo = info;
        savedDir = dir!.path;
      });
      _entryCtrl.forward(from: 0);
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            e.toString().replaceFirst(RegExp(r'^Exception:?\s*'), '');
        if (_errorMessage!.trim().isEmpty) {
          _errorMessage = tr("internet_problem");
        }
      });
      _entryCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isForced,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (widget.isForced) {
          final exit = await _showForcedExitDialog();
          if (!context.mounted) return;
          if (exit == true) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            SystemNavigator.pop();
          }
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: _D.bg,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: _D.white72),
          title: Text(
            tr("check_for_update"),
            style: const TextStyle(
              color: _D.white72,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideIn,
                  child: _buildBody(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Body states ──────────────────────────────
  Widget _buildBody() {
    if (_errorMessage != null) return _buildErrorState();
    if (_updateInfo == null) return _buildLoadingState();

    final info = _updateInfo!;
    final available = isUpdateAvailable(currentAppVersion, info.latestVersion);
    if (!available) return _buildUpToDateState();
    return _buildUpdateAvailableState(info);
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _D.red,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return _Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeroIcon(
            icon: Icons.wifi_off_rounded,
            iconColor: _D.white40,
            bgColor: _D.white06,
            glowColor: Colors.transparent,
            animate: false,
          ),
          const SizedBox(height: 24),
          Text(
            tr("internet_problem"),
            style: const TextStyle(
              color: _D.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          if (_errorMessage!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: _D.white40, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ],
          const SizedBox(height: 28),
          _PrimaryButton(label: tr("retry"), onPressed: _checkUpdate),
        ],
      ),
    );
  }

  Widget _buildUpToDateState() {
    return _Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeroIcon(
            icon: Icons.verified_rounded,
            iconColor: const Color(0xFF34D399),
            bgColor: const Color(0x1834D399),
            glowColor: const Color(0x3034D399),
            animate: false,
          ),
          const SizedBox(height: 24),
          Text(
            tr("no_update"),
            style: const TextStyle(
              color: _D.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "You're running the latest version.",
            style: TextStyle(color: _D.white40, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateAvailableState(AppUpdateInfo info) {
    return _Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero icon with animated glow ring
          Center(
            child: _GlowRing(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _D.redGradient,
                  boxShadow: [
                    BoxShadow(
                      color: _D.red.withValues(alpha: 0.45),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  color: _D.white,
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            "Update Available",
            style: TextStyle(
              color: _D.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Version badge
          Center(
            child: VersionDisplay(
              version: info.latestVersion,
              style: const TextStyle(
                color: _D.white72,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Divider
          Container(height: 1, color: _D.white06),
          const SizedBox(height: 24),

          // Changelog button
          if (info.updateChangelog != null &&
              info.updateChangelog!.isNotEmpty) ...[
            _ChangelogButton(
              onPressed: () => _showChangelog(info.updateChangelog!),
            ),
            const SizedBox(height: 12),
          ],

          // Store update button
          if (info.updateStoreUrl != null &&
              info.updateStoreUrl!.isNotEmpty) ...[
            _PrimaryButton(
              label: tr("update"),
              onPressed: () => _openStore(info.updateStoreUrl!),
            ),
            if (info.updateDownloadUrl != null &&
                info.updateDownloadUrl!.isNotEmpty)
              const SizedBox(height: 12),
          ],

          // APK download card
          if (info.updateDownloadUrl != null &&
              info.updateDownloadUrl!.isNotEmpty)
            _DownloadCard(
              appVersion: info.latestVersion,
              url: info.updateDownloadUrl!,
              downloadTask:
                  downloadManager.getDownload(info.updateDownloadUrl!),
              onDownloadPlayPausedPressed: _onDownloadAction,
              onOpen: _onOpenFile,
              onDelete: _onDeleteFile,
            ),
        ],
      ),
    );
  }

  // ── Hero icon helper ─────────────────────────
  Widget _buildHeroIcon({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color glowColor,
    required bool animate,
  }) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        boxShadow: glowColor == Colors.transparent
            ? null
            : [
                BoxShadow(
                    color: glowColor, blurRadius: 24, spreadRadius: 4),
              ],
      ),
      child: Icon(icon, color: iconColor, size: 38),
    );
  }

  // ── Dialogs ──────────────────────────────────
  Future<bool?> _showForcedExitDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: _Card(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: _D.red, size: 40),
              const SizedBox(height: 16),
              Text(
                tr("must_update"),
                style: const TextStyle(
                    color: _D.white, fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _PrimaryButton(
                label: tr("update"),
                onPressed: () => Navigator.pop(ctx, false),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(tr("exit"),
                    style: const TextStyle(
                        color: _D.white40, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangelog(String changelog) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ChangelogSheet(changelog: changelog),
    );
  }

  // ── Actions ──────────────────────────────────
  Future<void> _openStore(String url) async {
    try {
      final provider = Provider.of<AppDependencyProvider>(context, listen: false);
      sendUpdateTelemetry(provider, eventType: 'update_download_clicked', isForced: widget.isForced);
    } catch (_) {}
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _getSafeApkFileName(String url) {
    String name = downloadManager.getFileNameFromUrl(url);
    if (name.contains('?')) name = name.split('?').first;
    if (!name.toLowerCase().endsWith('.apk')) name += '.apk';
    return name;
  }

  void _onDownloadAction(String url) async {
    try {
      final provider = Provider.of<AppDependencyProvider>(context, listen: false);
      sendUpdateTelemetry(provider, eventType: 'update_download_clicked', isForced: widget.isForced);
    } catch (_) {}
    final targetPath = "$savedDir/${_getSafeApkFileName(url)}";
    final task = downloadManager.getDownload(url);

    if (task != null && !task.status.value.isCompleted) {
      setState(() {
        switch (task.status.value) {
          case DownloadStatus.downloading:
            downloadManager.pauseDownload(url);
            break;
          case DownloadStatus.paused:
            downloadManager.resumeDownload(url);
            break;
          default:
            break;
        }
      });
    } else {
      final file = File(targetPath);
      if (await file.exists()) await file.delete();
      setState(() {
        downloadManager.addDownload(url, targetPath).then((newTask) {
          if (newTask != null) {
            newTask.status.addListener(_updateWakelock);
            _updateWakelock();
          }
        });
      });
    }
  }

  Future<void> _onOpenFile(String url) async {
    final path = "$savedDir/${_getSafeApkFileName(url)}";
    final file = File(path);
    debugPrint('[Update] Attempting to open file: $path');

    if (!file.existsSync()) {
      debugPrint('[Update] File NOT found at $path');
      return;
    }

    if (Platform.isAndroid) {
      var status = await Permission.requestInstallPackages.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        if (!mounted) return;
        final bool? openSettings = await showDialog<bool>(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            child: _Card(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_open_rounded,
                      color: _D.red, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    tr(LocaleKeys.install_permission_title),
                    style: const TextStyle(
                      color: _D.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr(LocaleKeys.install_permission_msg),
                    style: const TextStyle(
                        color: _D.white40, fontSize: 14, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _PrimaryButton(
                    label: tr(LocaleKeys.settings),
                    onPressed: () => Navigator.pop(ctx, true),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(tr(LocaleKeys.cancel),
                        style: const TextStyle(
                            color: _D.white40, fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        );
        if (openSettings == true) {
          await Permission.requestInstallPackages.request();
        }
        return;
      }
    }

    try {
      final result = await _fileOpener.open(file.path,
          type: 'application/vnd.android.package-archive');
      debugPrint('[Update] OpenFile result: $result');
    } catch (e) {
      debugPrint('[Update] Error opening file: $e');
    }
  }

  void _onDeleteFile(String url) {
    setState(() {
      final path = "$savedDir/${_getSafeApkFileName(url)}";
      final file = File(path);
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } catch (e) {
          debugPrint('[Update] Error deleting file: $e');
        }
      }
      downloadManager.removeDownload(url);
    });
  }
}

// ─────────────────────────────────────────────
//  Shared Card container
// ─────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: padding ?? const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: _D.cardGradient,
        borderRadius: BorderRadius.circular(_D.radiusCard),
        border: Border.all(color: _D.white12),
        boxShadow: _D.cardShadow,
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────
//  Primary Button
// ─────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
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
          onTap: onPressed,
          borderRadius: BorderRadius.circular(_D.radiusPill),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: _D.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Changelog Button
// ─────────────────────────────────────────────
class _ChangelogButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ChangelogButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.article_outlined, size: 16),
        label: Text(tr("see_changelogs")),
        style: OutlinedButton.styleFrom(
          foregroundColor: _D.white72,
          side: const BorderSide(color: _D.white12, width: 1),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_D.radiusMd)),
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.2),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Changelog Bottom Sheet
// ─────────────────────────────────────────────
class _ChangelogSheet extends StatelessWidget {
  final String changelog;
  const _ChangelogSheet({required this.changelog});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: const BoxDecoration(
        color: Color(0xFF0E1219),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: _D.white12),
          left: BorderSide(color: _D.white12),
          right: BorderSide(color: _D.white12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _D.white40,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Text(
                  tr("changelogs"),
                  style: const TextStyle(
                    color: _D.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      color: _D.white40, size: 22),
                ),
              ],
            ),
          ),
          Container(height: 1, color: _D.white06),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Text(
                changelog,
                style: const TextStyle(
                  color: _D.white72,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _PrimaryButton(
                label: tr("ok"),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Download Card (replaces ListItem)
// ─────────────────────────────────────────────
class _DownloadCard extends StatefulWidget {
  final String url;
  final String appVersion;
  final DownloadTask? downloadTask;
  final Function(String) onDownloadPlayPausedPressed;
  final Function(String) onOpen;
  final Function(String) onDelete;

  const _DownloadCard({
    required this.url,
    required this.appVersion,
    required this.onDownloadPlayPausedPressed,
    required this.onOpen,
    required this.onDelete,
    this.downloadTask,
  });

  @override
  State<_DownloadCard> createState() => _DownloadCardState();
}

class _DownloadCardState extends State<_DownloadCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _D.surfaceAlt,
        borderRadius: BorderRadius.circular(_D.radiusMd),
        border: Border.all(color: _D.white06),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _D.redDim,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.android_rounded,
                    color: _D.red, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ReelRiot",
                      style: TextStyle(
                        color: _D.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    VersionDisplay(
                      version: widget.appVersion,
                      style: const TextStyle(
                          color: _D.white40, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Status chip
              if (widget.downloadTask != null)
                ValueListenableBuilder(
                  valueListenable: widget.downloadTask!.status,
                  builder: (context, value, _) => _StatusChip(status: value),
                ),
            ],
          ),

          // Progress section
          if (widget.downloadTask != null) ...[
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: widget.downloadTask!.status,
              builder: (context, status, _) {
                final isActive = status == DownloadStatus.downloading ||
                    status == DownloadStatus.queued ||
                    status == DownloadStatus.paused;
                if (!isActive) return const SizedBox.shrink();
                return ValueListenableBuilder<double>(
                  valueListenable: widget.downloadTask!.progress,
                  builder: (context, progress, _) {
                    final pct = (progress * 100).toInt();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              status == DownloadStatus.paused
                                  ? tr("downloading_paused")
                                  : tr("downloading_file"),
                              style: const TextStyle(
                                  color: _D.white40,
                                  fontSize: 12),
                            ),
                            Text(
                              "$pct%",
                              style: const TextStyle(
                                color: _D.white72,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 5,
                            backgroundColor: _D.white06,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              status == DownloadStatus.paused
                                  ? _D.white40
                                  : _D.red,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],

          const SizedBox(height: 16),

          // Actions
          widget.downloadTask != null
              ? ValueListenableBuilder<DownloadStatus>(
                  valueListenable: widget.downloadTask!.status,
                  builder: (context, status, _) =>
                      _buildActions(status),
                )
              : _PrimaryButton(
                  label: tr("download"),
                  onPressed: () =>
                      widget.onDownloadPlayPausedPressed(widget.url),
                ),
        ],
      ),
    );
  }

  Widget _buildActions(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.downloading:
        return _OutlineBtn(
          label: tr("pause"),
          icon: Icons.pause_rounded,
          onPressed: () => widget.onDownloadPlayPausedPressed(widget.url),
        );
      case DownloadStatus.paused:
        return _OutlineBtn(
          label: tr("resume"),
          icon: Icons.play_arrow_rounded,
          onPressed: () => widget.onDownloadPlayPausedPressed(widget.url),
        );
      case DownloadStatus.completed:
        return Row(
          children: [
            Expanded(
              child: _PrimaryButton(
                label: tr("install"),
                onPressed: () => widget.onOpen(widget.url),
              ),
            ),
            const SizedBox(width: 10),
            _IconBtn(
              icon: Icons.delete_outline_rounded,
              color: _D.white40,
              onPressed: () => widget.onDelete(widget.url),
              tooltip: tr("delete"),
            ),
          ],
        );
      case DownloadStatus.failed:
      case DownloadStatus.canceled:
        return Column(
          children: [
            _OutlineBtn(
              label: tr("download"),
              icon: Icons.download_rounded,
              onPressed: () =>
                  widget.onDownloadPlayPausedPressed(widget.url),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.open_in_browser_rounded,
                  size: 15, color: _D.white40),
              label: Text(
                "Download in browser",
                style: const TextStyle(color: _D.white40, fontSize: 13),
              ),
              onPressed: () async {
                final uri = Uri.tryParse(widget.url);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri,
                      mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        );
      case DownloadStatus.queued:
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: _D.red),
          ),
        );
    }
  }
}

// ─────────────────────────────────────────────
//  Status Chip
// ─────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final DownloadStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    Color fg;

    switch (status) {
      case DownloadStatus.completed:
        label = "Ready";
        bg = const Color(0x2034D399);
        fg = const Color(0xFF34D399);
        break;
      case DownloadStatus.downloading:
        label = "Downloading";
        bg = _D.redDim;
        fg = _D.red;
        break;
      case DownloadStatus.paused:
        label = "Paused";
        bg = const Color(0x20F59E0B);
        fg = const Color(0xFFF59E0B);
        break;
      case DownloadStatus.failed:
        label = "Failed";
        bg = _D.redDim;
        fg = _D.red;
        break;
      case DownloadStatus.canceled:
        label = "Cancelled";
        bg = _D.white06;
        fg = _D.white40;
        break;
      case DownloadStatus.queued:
        label = "Queued";
        bg = _D.white06;
        fg = _D.white40;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Outline Button
// ─────────────────────────────────────────────
class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const _OutlineBtn(
      {required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 17),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: _D.white72,
          side: const BorderSide(color: _D.white12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_D.radiusPill)),
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Icon Button
// ─────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;
  const _IconBtn(
      {required this.icon,
      required this.color,
      required this.onPressed,
      required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 48,
        height: 52,
        child: Material(
          color: _D.white06,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Update Bottom Banner
// ─────────────────────────────────────────────
class UpdateBottom extends StatefulWidget {
  const UpdateBottom({super.key});

  @override
  State<UpdateBottom> createState() => _UpdateBottomState();
}

class _UpdateBottomState extends State<UpdateBottom>
    with SingleTickerProviderStateMixin {
  static const bool _updateBannerEnabled = true;
  String? ignoreVersion;
  late final AnimationController _shimCtrl;

  @override
  void initState() {
    super.initState();
    ignoreVersion = sharedPrefsSingleton.getString("ignore_version") ?? "";
    _shimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimCtrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss(String version) async {
    setState(() => ignoreVersion = version);
    sharedPrefsSingleton.setString("ignore_version", version);
  }

  @override
  Widget build(BuildContext context) {
    if (!_updateBannerEnabled) return const SizedBox.shrink();

    return Consumer<AppDependencyProvider>(
      builder: (context, dep, _) {
        final version = dep.latestVersion;
        final isSimulated =
            FlavorConfig.isDev && dep.getFlag<bool>('simulate_update', false);
        final visible = version.isNotEmpty &&
            (isSimulated || isUpdateAvailable(currentAppVersion, version)) &&
            ignoreVersion != version;

        if (kDebugMode) {
          debugPrint(
              '[UpdateBottom] current: $currentAppVersion, latest: $version, visible: $visible');
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
                parent: animation, curve: Curves.easeOutCubic));
            return SlideTransition(
                position: slide,
                child: FadeTransition(opacity: animation, child: child));
          },
          child: !visible
              ? const SizedBox.shrink(key: ValueKey('hide'))
              : Padding(
                  key: const ValueKey('show'),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _BannerCard(
                    version: version,
                    shimCtrl: _shimCtrl,
                    onDismiss: () => _dismiss(version),
                    onUpdate: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const UpdateScreen(isForced: false)),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Banner Card
// ─────────────────────────────────────────────
class _BannerCard extends StatelessWidget {
  final String version;
  final AnimationController shimCtrl;
  final VoidCallback onDismiss;
  final VoidCallback onUpdate;

  const _BannerCard({
    required this.version,
    required this.shimCtrl,
    required this.onDismiss,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1C0A0A), Color(0xFF100E14)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _D.red.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: _D.red.withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Subtle shimmer line at top
                AnimatedBuilder(
                  animation: shimCtrl,
                  builder: (_, __) {
                    return Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              _D.red.withValues(
                                  alpha: math.sin(shimCtrl.value * math.pi)
                                          .clamp(0, 1) *
                                      0.7),
                              Colors.transparent,
                            ],
                            stops: [
                              (shimCtrl.value - 0.3).clamp(0.0, 1.0),
                              shimCtrl.value.clamp(0.0, 1.0),
                              (shimCtrl.value + 0.3).clamp(0.0, 1.0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Content
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 20, 52, 20),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: _D.redGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _D.red.withValues(alpha: 0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.system_update_rounded,
                          color: _D.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tr("update_available"),
                              style: const TextStyle(
                                color: _D.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            VersionDisplay(
                              version: version,
                              style: const TextStyle(
                                color: _D.white40,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 38,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: _D.red,
                                  foregroundColor: _D.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  elevation: 0,
                                ),
                                onPressed: onUpdate,
                                child: Text(
                                  tr("goto_update"),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Dismiss button
        Positioned(
          top: 10,
          right: 10,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Material(
              color: _D.white06,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onDismiss,
                customBorder: const CircleBorder(),
                child: const Icon(Icons.close_rounded,
                    color: _D.white40, size: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  ListItem alias (backward compatibility)
// ─────────────────────────────────────────────
// ignore: unused_element
class ListItem extends StatefulWidget {
  final Function(String) onDownloadPlayPausedPressed;
  final Function(String) onOpen;
  final Function(String) onDelete;
  DownloadTask? downloadTask;
  String url = "";
  String appVersion;

  ListItem({
    super.key,
    required this.url,
    required this.onDownloadPlayPausedPressed,
    required this.onOpen,
    required this.appVersion,
    required this.onDelete,
    this.downloadTask,
  });

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  @override
  Widget build(BuildContext context) {
    return _DownloadCard(
      url: widget.url,
      appVersion: widget.appVersion,
      downloadTask: widget.downloadTask,
      onDownloadPlayPausedPressed: widget.onDownloadPlayPausedPressed,
      onOpen: widget.onOpen,
      onDelete: widget.onDelete,
    );
  }
}
