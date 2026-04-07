import 'dart:io';
import 'package:caffiene/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/io_client.dart'; 

part 'app_version.g.dart';

CacheManager cacheProp() {
  return CacheManager(
    Config(
      'cacheProp',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
      repo: JsonCacheInfoRepository(databaseName: 'cacheProp'),
      fileService: HttpFileService(
        httpClient: IOClient(
          HttpClient()..userAgent = BROWSER_USER_AGENT,
        ),
      ),
    ),
  );
}

// ── Shared Text Styles ───────────────────────────────────────────────────────
const kTextHeaderStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  fontFamily: 'PoppinsSB',
  letterSpacing: 0.2,
);

const kTextSmallHeaderStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  fontFamily: 'PoppinsSB',
);

const kTextBodyStyle = TextStyle(
  fontSize: 14,
  fontFamily: 'Poppins',
  height: 1.5,
);
