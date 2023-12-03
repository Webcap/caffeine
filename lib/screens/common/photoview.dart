import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:caffiene/models/images.dart';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:caffiene/utils/constant.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

class HeroPhotoView extends StatefulWidget {
  const HeroPhotoView(
      {required this.imageType,
      this.name,
      this.stills,
      this.posters,
      this.backdrops,
      Key? key})
      : super(key: key);
  final List<Backdrops>? backdrops;
  final List<Posters>? posters;
  final List<Stills>? stills;
  final String? name;
  final String imageType;

  @override
  State<HeroPhotoView> createState() => _HeroPhotoViewState();
}

class _HeroPhotoViewState extends State<HeroPhotoView> {
  int currentIndex = 0;

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Future<String> createFolder(
      String flixquestFolderName,
      String imageTypeFolderName,
      String posterFolder,
      String stillFolder) async {
    final cinefolderName = flixquestFolderName;
    final imagefolderName = imageTypeFolderName;
    final posterFolderName = posterFolder;
    final stillFolderName = stillFolder;
    final flixquestPath = Directory("storage/emulated/0/$cinefolderName");
    final imageTypePath =
        Directory("storage/emulated/0/caffeine/$imagefolderName");
    final posterPath =
        Directory("storage/emulated/0/caffeine/$posterFolderName");
    final stillPath =
        Directory("storage/emulated/0/caffeine/$stillFolderName");
    var storageStatus = await Permission.storage.status;
    var externalStatus = await Permission.manageExternalStorage.status;
    var mediaStatus = await Permission.accessMediaLocation.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }
    if (!externalStatus.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    if (!mediaStatus.isGranted) {
      await Permission.accessMediaLocation.request();
    }
    if ((await flixquestPath.exists())) {
      imageTypePath.create();
      posterPath.create();
      stillPath.create();
      return flixquestPath.path;
    } else {
      flixquestPath.create();
      posterPath.create();
      imageTypePath.create();
      stillPath.create();
      return flixquestPath.path;
    }
  }

  void _download(String url, String currentIndex, String themeMode) async {
    final status = await Permission.storage.request();
    // final status2 = await Permission.accessMediaLocation.request();

    if (status.isGranted) {
      await createFolder('FlixQuest', 'Backdrops', 'Posters', 'Stills');
      await FlutterDownloader.enqueue(
        url: url,
        fileName: '${widget.name}_${widget.imageType}_$currentIndex.jpg',
        headers: {}, // optional: header send with url (auth token etc)
        savedDir: widget.imageType == 'backdrop'
            ? '/storage/emulated/0/FlixQuest/Backdrops/'
            : widget.imageType == 'poster'
                ? '/storage/emulated/0/FlixQuest/Posters/'
                : '/storage/emulated/0/FlixQuest/Stills/',
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'File permission isn\'t given to FlixQuest, therefore image couldn\'t be downloaded.',
          style: TextStyle(
              color: themeMode == "dark" || themeMode == "amoled"
                  ? Colors.white
                  : Colors.black,
              fontFamily: 'PoppinsSB'),
        )),
      );
    }
  }

  final ReceivePort _port = ReceivePort();

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  void initState() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.imageType == 'backdrop'
              ? '${currentIndex + 1} / ${widget.backdrops!.length}'
              : widget.imageType == 'still'
                  ? '${currentIndex + 1} / ${widget.stills!.length}'
                  : '${currentIndex + 1} / ${widget.posters!.length}'),
          actions: [
            IconButton(
              onPressed: () async {
                _download(
                    widget.imageType == 'backdrop'
                        ? TMDB_BASE_IMAGE_URL +
                            imageQuality +
                            widget.backdrops![currentIndex].filePath!
                        : widget.imageType == 'poster'
                            ? TMDB_BASE_IMAGE_URL +
                                imageQuality +
                                widget.posters![currentIndex].posterPath!
                            : TMDB_BASE_IMAGE_URL +
                                imageQuality +
                                widget.stills![currentIndex].stillPath!,
                    '${currentIndex + 1}',
                    themeMode);
              },
              icon: const Icon(FontAwesomeIcons.download),
            )
          ]),
      body: Container(
          child: Stack(alignment: Alignment.bottomRight, children: [
        PhotoViewGallery.builder(
          allowImplicitScrolling: true,
          gaplessPlayback: true,
          wantKeepAlive: true,
          enableRotation: true,
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(
                widget.imageType == 'backdrop'
                    ? TMDB_BASE_IMAGE_URL +
                        imageQuality +
                        widget.backdrops![currentIndex].filePath!
                    : widget.imageType == 'poster'
                        ? TMDB_BASE_IMAGE_URL +
                            imageQuality +
                            widget.posters![currentIndex].posterPath!
                        : TMDB_BASE_IMAGE_URL +
                            imageQuality +
                            widget.stills![currentIndex].stillPath!,
              ),
              initialScale: PhotoViewComputedScale.contained * 0.95,
            );
          },
          itemCount: widget.imageType == 'backdrop'
              ? widget.backdrops!.length
              : widget.imageType == 'poster'
                  ? widget.posters!.length
                  : widget.stills!.length,
          onPageChanged: onPageChanged,
          loadingBuilder: (context, event) => Container(
            child: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            tr("image_index",
                namedArgs: {"index": (currentIndex + 1).toString()}),
            style: TextStyle(
              color: themeMode == "dark" || themeMode == "amoled"
                  ? Colors.white
                  : Colors.black,
              fontSize: 17.0,
              decoration: null,
            ),
          ),
        )
      ])),
    );
  }
}
