import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:caffiene/functions/functions.dart';
import 'package:caffiene/models/update.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/utils/config.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({Key? key}) : super(key: key);

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  UpdateChecker? updateChecker;
  var downloadManager = DownloadManager();
  var savedDir = "";

  @override
  void initState() {
    checkForUpdate(CAFFEINE_UPDATE_URL).then((value) {
      if (mounted) {
        setState(() {
          updateChecker = value;
        });
      }
    });
    getApplicationSupportDirectory().then((value) {
      if (mounted) {
        setState(() {
          savedDir = value.path;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("check_for_update")),
      ),
      body: Container(
          child: updateChecker == null
              ? const Center(child: CircularProgressIndicator())
              : updateChecker!.versionNumber != currentAppVersion
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            tr("update_available"),
                            style: kTextHeaderStyle,
                          ),
                          Text(
                            tr("new_version", namedArgs: {
                              "v": updateChecker!.versionNumber!
                            }),
                            style: kTextSmallBodyStyle,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (_) {
                                      return SimpleDialog(
                                          title: Text(tr("changelogs")),
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  updateChecker!.changeLog!),
                                            )
                                          ]);
                                    });
                              },
                              child: Text(tr("see_changelogs"))),
                          ListItem(
                              appVersion: updateChecker!.versionNumber!,
                              onDownloadPlayPausedPressed: (url) async {
                                setState(() {
                                  var task = downloadManager.getDownload(url);

                                  if (task != null &&
                                      !task.status.value.isCompleted) {
                                    switch (task.status.value) {
                                      case DownloadStatus.downloading:
                                        downloadManager.pauseDownload(url);
                                        break;
                                      case DownloadStatus.paused:
                                        downloadManager.resumeDownload(url);
                                        break;
                                      case DownloadStatus.queued:
                                        break;
                                      case DownloadStatus.completed:
                                        break;
                                      case DownloadStatus.failed:
                                        break;
                                      case DownloadStatus.canceled:
                                        break;
                                    }
                                  } else {
                                    downloadManager.addDownload(url,
                                        "$savedDir/${downloadManager.getFileNameFromUrl(url)}");
                                  }
                                });
                              },
                              onOpen: (url) async {
                                // OpenFile.open(
                                //     "$savedDir/${downloadManager.getFileNameFromUrl(url)}");
                                var fileName =
                                    "$savedDir/${downloadManager.getFileNameFromUrl(url)}";
                                var file = File(fileName);
                                OpenFile.open(file.path);
                              },
                              onDelete: (url) async {
                                var fileName =
                                    "$savedDir/${downloadManager.getFileNameFromUrl(url)}";
                                var file = File(fileName);
                                file.delete();
                              },
                              url: updateChecker!.downloadLink!,
                              downloadTask: downloadManager
                                  .getDownload(updateChecker!.downloadLink!)),
                        ],
                      ),
                    )
                  : Center(
                      child: Text(
                        tr("no_update"),
                        textAlign: TextAlign.center,
                        style: kTextHeaderStyle,
                      ),
                    )),
    );
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
      {Key? key,
      required this.url,
      required this.onDownloadPlayPausedPressed,
      required this.onOpen,
      required this.appVersion,
      required this.onDelete,
      this.downloadTask})
      : super(key: key);

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  @override
  Widget build(BuildContext context) {
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        padding: const EdgeInsets.all(8.0),
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
                    Text(
                      'Caffiene v${widget.appVersion}',
                      overflow: TextOverflow.ellipsis,
                      style: kTextSmallBodyStyle,
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
                                                          DownloadStatus
                                                              .canceled
                                                      ? tr("download_cancelled")
                                                      : value.toString(),
                                  style: const TextStyle(fontSize: 16)),
                            );
                          }),
                  ],
                )),
              ],
            ), // if (widget.item.isDownloadingOrPaused)
            if (widget.downloadTask != null &&
                !widget.downloadTask!.status.value.isCompleted)
              ValueListenableBuilder(
                  valueListenable: widget.downloadTask!.progress,
                  builder: (context, value, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: LinearProgressIndicator(
                        value: widget.downloadTask!.progress.value,
                        color: widget.downloadTask!.status.value ==
                                DownloadStatus.paused
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }),
            widget.downloadTask != null
                ? ValueListenableBuilder(
                    valueListenable: widget.downloadTask!.status,
                    builder: (context, value, child) {
                      switch (widget.downloadTask!.status.value) {
                        case DownloadStatus.downloading:
                          return ElevatedButton(
                              onPressed: () {
                                widget.onDownloadPlayPausedPressed(widget.url);
                              },
                              child: Text(tr("pause")));

                        case DownloadStatus.paused:
                          return ElevatedButton(
                              onPressed: () {
                                widget.onDownloadPlayPausedPressed(widget.url);
                              },
                              child: Text(tr("resume")));

                        case DownloadStatus.completed:
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ElevatedButton(
                                    onPressed: () {
                                      widget.onOpen(widget.url);
                                    },
                                    child: Text(tr("install"))),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    widget.onDelete(widget.url);
                                  },
                                  child: Text(tr("delete"))),
                            ],
                          );
                        case DownloadStatus.failed:
                        case DownloadStatus.canceled:
                          return ElevatedButton(
                              onPressed: () {
                                mixpanel.track('Download event', properties: {
                                  'App version': widget.appVersion
                                });
                                widget.onDownloadPlayPausedPressed(widget.url);
                              },
                              child: Text(tr("download")));
                        case DownloadStatus.queued:
                          break;
                      }
                      return Text("$value",
                          style: const TextStyle(fontSize: 16));
                    })
                : ElevatedButton(
                    onPressed: () {
                      mixpanel.track('Download event',
                          properties: {'App version': widget.appVersion});
                      widget.onDownloadPlayPausedPressed(widget.url);
                    },
                    child: Text(tr("download")))
          ],
        ),
      ),
    );
  }
}
