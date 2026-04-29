// ignore_for_file: must_be_immutable
import 'dart:io';
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

// Design tokens from design.json (cinematic, dark-first, primary red CTA)
abstract class _UpdateDesign {
  static const Color bgCanvasDark = Color(0xFF030712); // gray-950
  static const Color bgSurfaceDark = Color(0xFF0B0F14); // gray-900
  static const Color primaryCta = Color(0xFFDC2626); // primary-600
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary =
      Color(0xB8FFFFFF); // rgba(255,255,255,0.72)
  static const Color textTertiary = Color(0x80FFFFFF);
  static const Color borderSubtle = Color(0x14FFFFFF);
  static const double radiusCard = 20.0; // radius-lg
  static const double radiusPill = 9999.0;
  static const double ctaHeight = 52.0;
  static const double spacingSection = 20.0;
  static const double spacingGap = 12.0;
  static const List<BoxShadow> shadowCard = [
    BoxShadow(color: Color(0x38000000), blurRadius: 30, offset: Offset(0, 10)),
  ];
  static const List<BoxShadow> shadowPrimary = [
    BoxShadow(color: Color(0x52DC2626), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

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

class _UpdateScreenState extends State<UpdateScreen> {
  AppUpdateInfo? _updateInfo;
  String? _errorMessage;
  var savedDir = '';

  late final DownloadManager downloadManager;
  late final UpdateApiService _apiService;
  late final FileOpener _fileOpener;

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
    // Add status listeners for wakelock
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
    debugPrint('[Update] Wakelock active: $active');
  }

  @override
  void dispose() {
    for (var task in downloadManager.getAllDownloads()) {
      task.status.removeListener(_updateWakelock);
    }
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
      
      if (!mounted) return;
      setState(() {
        _updateInfo = info;
        savedDir = dir!.path;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            e.toString().replaceFirst(RegExp(r'^Exception:?\s*'), '');
        if (_errorMessage!.trim().isEmpty) {
          _errorMessage = tr("internet_problem");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: !widget.isForced,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (widget.isForced) {
          final exit = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: _UpdateDesign.bgSurfaceDark,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(_UpdateDesign.radiusCard)),
              content: Text(
                tr("must_update"),
                style: const TextStyle(
                    color: _UpdateDesign.textPrimary, fontSize: 15),
              ),
              actions: [
                SizedBox(
                  height: _UpdateDesign.ctaHeight,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _UpdateDesign.primaryCta,
                      foregroundColor: _UpdateDesign.textPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(_UpdateDesign.radiusPill)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(tr("update"),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(tr("exit"),
                      style: const TextStyle(color: _UpdateDesign.primaryCta)),
                ),
              ],
            ),
          );
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
        backgroundColor: isDark ? _UpdateDesign.bgCanvasDark : null,
        appBar: AppBar(
          title: Text(tr("check_for_update"),
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
          backgroundColor: isDark ? _UpdateDesign.bgCanvasDark : null,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme:
              IconThemeData(color: isDark ? _UpdateDesign.textPrimary : null),
          titleTextStyle: TextStyle(
              color: isDark ? _UpdateDesign.textPrimary : null,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: _buildBody(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_errorMessage != null) {
      return _buildCard(
        isDark: isDark,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
                Icons.signal_cellular_connected_no_internet_0_bar_rounded,
                size: 56,
                color: _UpdateDesign.textTertiary),
            const SizedBox(height: _UpdateDesign.spacingSection),
            Text(
              tr("internet_problem"),
              style: const TextStyle(
                  color: _UpdateDesign.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(
                    color: _UpdateDesign.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
            ],
            const SizedBox(height: 24),
            _primaryButton(label: tr("retry"), onPressed: _checkUpdate),
          ],
        ),
      );
    }
    if (_updateInfo == null) {
      return const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: _UpdateDesign.primaryCta),
        ),
      );
    }
    final info = _updateInfo!;
    final available = isUpdateAvailable(currentAppVersion, info.latestVersion);
    if (!available) {
      return _buildCard(
        isDark: isDark,
        child: Text(
          tr("no_update"),
          style: const TextStyle(
              color: _UpdateDesign.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      );
    }
    return _buildCard(
      isDark: isDark,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tr("update_available"),
            style: const TextStyle(
                color: _UpdateDesign.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            tr("new_version", namedArgs: {"v": info.latestVersion}),
            style: const TextStyle(
                color: _UpdateDesign.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          if (info.updateChangelog != null &&
              info.updateChangelog!.isNotEmpty) ...[
            const SizedBox(height: _UpdateDesign.spacingGap),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _UpdateDesign.textPrimary,
                side: const BorderSide(color: _UpdateDesign.borderSubtle),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(_UpdateDesign.radiusCard)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => _showChangelog(info.updateChangelog!),
              child: Text(tr("see_changelogs"),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ],
          const SizedBox(height: _UpdateDesign.spacingSection),
          if (info.updateStoreUrl != null && info.updateStoreUrl!.isNotEmpty)
            _primaryButton(
              label: tr("update"),
              onPressed: () => _openStore(info.updateStoreUrl!),
            ),
          if (info.updateStoreUrl != null &&
              info.updateStoreUrl!.isNotEmpty &&
              info.updateDownloadUrl != null &&
              info.updateDownloadUrl!.isNotEmpty)
            const SizedBox(height: _UpdateDesign.spacingGap),
          if (info.updateDownloadUrl != null &&
              info.updateDownloadUrl!.isNotEmpty)
            ListItem(
              appVersion: info.latestVersion,
              url: info.updateDownloadUrl!,
              downloadTask:
                  downloadManager.getDownload(info.updateDownloadUrl!),
              onDownloadPlayPausedPressed: (url) => _onDownloadAction(url),
              onOpen: _onOpenFile,
              onDelete: _onDeleteFile,
            ),
        ],
      ),
    );
  }

  Widget _primaryButton(
      {required String label, required VoidCallback onPressed}) {
    return Container(
      height: _UpdateDesign.ctaHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_UpdateDesign.radiusPill),
        boxShadow: _UpdateDesign.shadowPrimary,
      ),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: _UpdateDesign.primaryCta,
          foregroundColor: _UpdateDesign.textPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_UpdateDesign.radiusPill)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ),
    );
  }

  Widget _buildCard({required bool isDark, required Widget child}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(_UpdateDesign.spacingSection),
      decoration: BoxDecoration(
        color: isDark
            ? _UpdateDesign.bgSurfaceDark
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_UpdateDesign.radiusCard),
        border: Border.all(
            color: isDark
                ? _UpdateDesign.borderSubtle
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: isDark ? _UpdateDesign.shadowCard : null,
      ),
      child: child,
    );
  }

  void _showChangelog(String changelog) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _UpdateDesign.bgSurfaceDark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_UpdateDesign.radiusCard)),
        title: Text(tr("changelogs"),
            style: const TextStyle(
                color: _UpdateDesign.textPrimary, fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Text(changelog,
              style: const TextStyle(
                  color: _UpdateDesign.textSecondary,
                  fontSize: 14,
                  height: 1.4)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr("ok"),
                style: const TextStyle(
                    color: _UpdateDesign.primaryCta,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _openStore(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _getSafeApkFileName(String url) {
    String name = downloadManager.getFileNameFromUrl(url);
    if (name.contains('?')) {
      name = name.split('?').first;
    }
    if (!name.toLowerCase().endsWith('.apk')) {
      name += '.apk';
    }
    return name;
  }

  void _onDownloadAction(String url) async {
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
      // Ensure we delete any stale or corrupted file before downloading again
      final file = File(targetPath);
      if (await file.exists()) {
        await file.delete();
      }
      
      setState(() {
        downloadManager
            .addDownload(url, targetPath)
            .then((newTask) {
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
      debugPrint('[Update] RequestInstallPackages status: $status');
      if (status.isDenied || status.isPermanentlyDenied) {
        if (!mounted) return;
        final bool? openSettings = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: _UpdateDesign.bgSurfaceDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_UpdateDesign.radiusCard),
            ),
            title: Text(
              tr(LocaleKeys.install_permission_title),
              style: const TextStyle(
                color: _UpdateDesign.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              tr(LocaleKeys.install_permission_msg),
              style: const TextStyle(
                color: _UpdateDesign.textSecondary,
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  tr(LocaleKeys.cancel),
                  style: const TextStyle(color: _UpdateDesign.textTertiary),
                ),
              ),
              SizedBox(
                height: 44,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _UpdateDesign.primaryCta,
                    foregroundColor: _UpdateDesign.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(_UpdateDesign.radiusPill)),
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    tr(LocaleKeys.settings),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );

        if (openSettings == true) {
          await Permission.requestInstallPackages.request();
        }
        return;
      }
    }

    debugPrint('[Update] Proceeding with file open');
    _fileOpener.open(file.path, type: 'application/vnd.android.package-archive').then((result) {
      debugPrint('[Update] OpenFile result: ${result.type} - ${result.message}');
    });
  }

  void _onDeleteFile(String url) {
    setState(() {
      final path = "$savedDir/${_getSafeApkFileName(url)}";
      final file = File(path);
      if (file.existsSync()) {
        try {
          file.deleteSync();
          debugPrint('[Update] Deleted file: $path');
        } catch (e) {
          debugPrint('[Update] Error deleting file: $e');
        }
      }
      downloadManager.removeDownload(url);
    });
  }
}

class ListItem extends StatefulWidget {
  final Function(String) onDownloadPlayPausedPressed;
  final Function(String) onOpen;
  final Function(String) onDelete;
  DownloadTask? downloadTask;
  String url = "";
  String appVersion;

  ListItem(
      {super.key,
      required this.url,
      required this.onDownloadPlayPausedPressed,
      required this.onOpen,
      required this.appVersion,
      required this.onDelete,
      this.downloadTask});

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        decoration: BoxDecoration(
          color: _UpdateDesign.bgSurfaceDark.withValues(alpha: 0.6),
          border: Border.all(color: _UpdateDesign.borderSubtle),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _UpdateDesign.shadowCard,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Reelriot',
                            style: TextStyle(
                              color: _UpdateDesign.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          VersionDisplay(
                            version: widget.appVersion,
                            style: const TextStyle(
                              color: _UpdateDesign.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (widget.downloadTask != null)
                        ValueListenableBuilder(
                          valueListenable: widget.downloadTask!.status,
                          builder: (context, value, child) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                value == DownloadStatus.downloading
                                    ? tr("downloading_file")
                                    : value == DownloadStatus.completed
                                        ? tr("file_downloaded")
                                        : value == DownloadStatus.failed
                                            ? tr("downloading_failed")
                                            : value == DownloadStatus.paused
                                                ? tr("downloading_paused")
                                                : value ==
                                                        DownloadStatus.canceled
                                                    ? tr("download_cancelled")
                                                    : value.toString(),
                                style: const TextStyle(
                                    color: _UpdateDesign.textSecondary,
                                    fontSize: 14),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.downloadTask != null &&
                !widget.downloadTask!.status.value.isCompleted)
              ValueListenableBuilder(
                valueListenable: widget.downloadTask!.progress,
                builder: (context, value, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    height: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: widget.downloadTask!.progress.value,
                        backgroundColor: _UpdateDesign.borderSubtle,
                        color: widget.downloadTask!.status.value ==
                                DownloadStatus.paused
                            ? _UpdateDesign.textTertiary
                            : _UpdateDesign.primaryCta,
                      ),
                    ),
                  );
                },
              ),
            widget.downloadTask != null
                ? ValueListenableBuilder(
                    valueListenable: widget.downloadTask!.status,
                    builder: (context, value, child) {
                      switch (widget.downloadTask!.status.value) {
                        case DownloadStatus.downloading:
                          return _secondaryButton(
                              label: tr("pause"),
                              onPressed: () => widget
                                  .onDownloadPlayPausedPressed(widget.url));
                        case DownloadStatus.paused:
                          return _secondaryButton(
                              label: tr("resume"),
                              onPressed: () => widget
                                  .onDownloadPlayPausedPressed(widget.url));
                        case DownloadStatus.completed:
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _secondaryButton(
                                  label: tr("install"),
                                  onPressed: () => widget.onOpen(widget.url)),
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: () => widget.onDelete(widget.url),
                                child: Text(tr("delete"),
                                    style: const TextStyle(
                                        color: _UpdateDesign.textSecondary)),
                              ),
                            ],
                          );
                        case DownloadStatus.failed:
                        case DownloadStatus.canceled:
                          return _secondaryButton(
                              label: tr("download"),
                              onPressed: () => widget
                                  .onDownloadPlayPausedPressed(widget.url));
                        case DownloadStatus.queued:
                          break;
                      }
                      return const SizedBox.shrink();
                    },
                  )
                : _primaryButton(
                    label: tr("download"),
                    onPressed: () =>
                        widget.onDownloadPlayPausedPressed(widget.url),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton(
      {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      height: _UpdateDesign.ctaHeight,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: _UpdateDesign.primaryCta,
          foregroundColor: _UpdateDesign.textPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_UpdateDesign.radiusPill)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ),
    );
  }

  Widget _secondaryButton(
      {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: _UpdateDesign.textPrimary,
          side: const BorderSide(color: _UpdateDesign.borderSubtle),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_UpdateDesign.radiusPill)),
        ),
        onPressed: onPressed,
        child: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class UpdateBottom extends StatefulWidget {
  const UpdateBottom({
    super.key,
  });

  @override
  State<UpdateBottom> createState() => _UpdateBottomState();
}

class _UpdateBottomState extends State<UpdateBottom> {
  static const bool _updateBannerEnabled = true;

  String? ignoreVersion;

  Future<void> checkAction(bool value, String? appVersion) async {
    if (value && appVersion != null) {
      sharedPrefsSingleton.setString("ignore_version", appVersion);
    } else {
      sharedPrefsSingleton.setString("ignore_version", "");
    }
  }

  @override
  void initState() {
    super.initState();
    // Read cached ignore_version preference once
    ignoreVersion = sharedPrefsSingleton.getString("ignore_version") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    if (!_updateBannerEnabled) return const SizedBox.shrink();

    // Listen to AppDependencyProvider so we react when latestVersion arrives
    // from the remote config API (which loads asynchronously after initState).
    return Consumer<AppDependencyProvider>(
      builder: (context, dep, _) {
        final version = dep.latestVersion;
        final isSimulated = FlavorConfig.isDev && dep.getFlag<bool>('simulate_update', false);
        
        final visible = version.isNotEmpty &&
            (isSimulated || isUpdateAvailable(currentAppVersion, version)) &&
            ignoreVersion != version;

        if (kDebugMode) {
          debugPrint('[UpdateBottom] Hash: ${identityHashCode(dep)}, current: $currentAppVersion, latest: $version, sim: $isSimulated, visible: $visible');
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart,
            ));
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: offsetAnimation,
                child: child,
              ),
            );
          },
          child: !visible 
            ? const SizedBox.shrink(key: ValueKey('hide'))
            : Padding(
                key: const ValueKey('show'),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1A1A24),
                        Color(0xFF101016),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                          onPressed: () {
                            setState(() {
                              ignoreVersion = version;
                            });
                            checkAction(true, version);
                          },
                          splashRadius: 20,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _UpdateDesign.primaryCta.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.system_update_rounded,
                                color: _UpdateDesign.primaryCta,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: Text(
                                      tr("update_available"),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  VersionDisplay(
                                    version: version,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6), 
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 44,
                                    width: double.infinity,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: _UpdateDesign.primaryCta,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const UpdateScreen(isForced: false),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        tr("goto_update"),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold, 
                                          fontSize: 14,
                                          letterSpacing: 0.3,
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
        );
      },
    );
  }
}
