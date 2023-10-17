// ignore_for_file: unused_local_variable

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:caffiene/provider/settings_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class HeroPhotoView extends StatefulWidget {
  const HeroPhotoView(
      {required this.imageProvider,
      required this.currentIndex,
      required this.name,
      required this.heroId,
      Key? key})
      : super(key: key);
  final ImageProvider imageProvider;
  final String heroId;
  final int currentIndex;
  final String name;

  @override
  State<HeroPhotoView> createState() => _HeroPhotoViewState();
}

class _HeroPhotoViewState extends State<HeroPhotoView> {
  final ReceivePort _port = ReceivePort();

  Future<String> createFolder(
      String caffieneFolderName,
      String imageTypeFolderName,
      String posterFolder,
      String stillFolder,
      String personImageFolder) async {
    final cinefolderName = caffieneFolderName;
    final imagefolderName = imageTypeFolderName;
    final posterFolderName = posterFolder;
    final stillFolderName = stillFolder;
    final personImageFolderName = personImageFolder;
    final caffienePath = Directory("storage/emulated/0/$cinefolderName");
    final imageTypePath =
        Directory("storage/emulated/0/Caffiene/$imagefolderName");
    final posterPath =
        Directory("storage/emulated/0/Caffiene/$posterFolderName");
    final stillPath = Directory("storage/emulated/0/Caffiene/$stillFolderName");
    final personImagePath =
        Directory("storage/emulated/0/Caffiene/$personImageFolderName");
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
    if ((await caffienePath.exists())) {
      imageTypePath.create();
      posterPath.create();
      stillPath.create();
      personImagePath.create();
      return caffienePath.path;
    } else {
      caffienePath.create();
      posterPath.create();
      imageTypePath.create();
      stillPath.create();
      personImagePath.create();
      return caffienePath.path;
    }
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  void _download(String url, String currentIndex, bool isDark) async {
    final status = await Permission.storage.request();
    // final status2 = await Permission.accessMediaLocation.request();

    if (status.isGranted) {
      await createFolder(
          'Caffiene', 'Backdrops', 'Posters', 'Stills', 'Person Images');
      await FlutterDownloader.enqueue(
        url: url,
        fileName: '${widget.name}_$currentIndex.jpg',
        headers: {}, // optional: header send with url (auth token etc)
        savedDir: '/storage/emulated/0/Caffiene/Person Images/',
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          tr("no_file_premission"),
          style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontFamily: 'PoppinsSB'),
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.name.endsWith('s')
                ? tr("plular_person_image", namedArgs: {"name": widget.name})
                : tr("singular_person_image",
                    namedArgs: {"name": widget.name})),
          ),
          body: Column(
            children: [
              Expanded(
                flex: 10,
                child: PhotoView(
                  imageProvider: widget.imageProvider,
                  enableRotation: true,
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.heroId),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    _download(
                        widget.heroId, '${widget.currentIndex + 1}', isDark);
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                        const Size(double.infinity, 50)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.save),
                      ),
                      Text(tr("download")),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
