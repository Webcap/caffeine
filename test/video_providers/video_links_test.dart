import 'package:caffiene/models/provider_video_source.dart';
import 'package:caffiene/video_providers/regularVideoLinks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProviderLoaderResult', () {
    test('should create with default values', () {
      final result = ProviderLoaderResult();

      expect(result.success, isFalse);
      expect(result.videoLinks, isNull);
      expect(result.subtitleLinks, isNull);
      expect(result.errorMessage, isNull);
    });

    test('should create with success state', () {
      final videoLinks = [
        RegularVideoLinks(
          url: 'https://example.com/video.m3u8',
          quality: '1080p',
          isM3U8: true,
        ),
      ];
      final subtitles = [
        RegularSubtitleLinks(
          url: 'https://example.com/subtitles.vtt',
          language: 'English',
        ),
      ];

      final result = ProviderLoaderResult(
        success: true,
        videoLinks: videoLinks,
        subtitleLinks: subtitles,
      );

      expect(result.success, isTrue);
      expect(result.videoLinks, hasLength(1));
      expect(result.subtitleLinks, hasLength(1));
      expect(result.videoLinks!.first.url,
          equals('https://example.com/video.m3u8'));
      expect(result.videoLinks!.first.quality, equals('1080p'));
      expect(result.subtitleLinks!.first.language, equals('English'));
    });

    test('should create with error message', () {
      final result = ProviderLoaderResult(
        success: false,
        errorMessage: 'No video sources found',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, equals('No video sources found'));
    });
  });

  group('RegularVideoLinks', () {
    test('should create from JSON', () {
      final json = {
        'url': 'https://example.com/video.m3u8',
        'quality': '720p',
        'isM3U8': true,
      };

      final videoLink = RegularVideoLinks.fromJson(json);

      expect(videoLink.url, equals('https://example.com/video.m3u8'));
      expect(videoLink.quality, equals('720p'));
      expect(videoLink.isM3U8, isTrue);
    });

    test('should default quality to unknown when not provided', () {
      final json = {
        'url': 'https://example.com/video.mp4',
      };

      final videoLink = RegularVideoLinks.fromJson(json);

      expect(videoLink.quality, equals('unknown quality'));
    });

    test('should handle null values in JSON', () {
      final json = <String, dynamic>{};

      final videoLink = RegularVideoLinks.fromJson(json);

      expect(videoLink.url, isNull);
      expect(videoLink.quality, equals('unknown quality'));
      expect(videoLink.isM3U8, isNull);
    });
  });

  group('RegularSubtitleLinks', () {
    test('should create from JSON with url key', () {
      final json = {
        'file': 'https://example.com/subtitles.vtt',
        'lang': 'English',
      };

      final subtitle = RegularSubtitleLinks.fromJson(json);

      expect(subtitle.url, equals('https://example.com/subtitles.vtt'));
      expect(subtitle.language, equals('English'));
    });

    test('should create from JSON with label key', () {
      final json = {
        'url': 'https://example.com/subtitles.srt',
        'label': 'Spanish',
      };

      final subtitle = RegularSubtitleLinks.fromJson(json);

      expect(subtitle.url, equals('https://example.com/subtitles.srt'));
      expect(subtitle.language, equals('Spanish'));
    });

    test('should handle missing url field', () {
      final json = {
        'lang': 'French',
      };

      final subtitle = RegularSubtitleLinks.fromJson(json);

      expect(subtitle.url, isNull);
      expect(subtitle.language, equals('French'));
    });
  });
}
