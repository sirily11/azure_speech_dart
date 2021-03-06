import 'dart:io';

import 'dart:math';

import 'package:azure_text_to_speech/src/objects/voice_styles.dart';
import 'package:dio/dio.dart';

/// Voice Job
/// Which contains transfer content, target file, source file and download percentage
class VoiceJob {
  final File sourceFile;
  final File targetFile;
  final CancelToken cancelToken;

  /// Voice used
  VoiceOption voice;

  /// Job's text content
  String content;

  /// Download percentage
  double percentage;

  /// Downloaded file size
  int downloaded;

  /// Job creation time
  DateTime dateTime;

  /// Whether the job is finished
  bool isDone;

  /// Whether the job has error
  bool isError;
  VoiceJob({
    num dateTime,
    this.sourceFile,
    this.targetFile,
    this.content,
    this.voice,
    this.cancelToken,
  }) {
    this.dateTime = dateTime != null
        ? DateTime.fromMillisecondsSinceEpoch(dateTime)
        : DateTime.now();
    isDone = false;
    isError = false;
    downloaded = 0;
    percentage = null;
  }

  String get downloadedSize {
    if (downloaded == 0) {
      return 'Empty';
    } else if (downloaded >= pow(1024, 1) && downloaded < pow(1024, 2)) {
      var sizeStr = (downloaded / pow(1024, 1)).toStringAsFixed(2);
      return '$sizeStr KB';
    } else if (downloaded >= pow(1024, 2) && downloaded < pow(1024, 3)) {
      var sizeStr = (downloaded / pow(1024, 2)).toStringAsFixed(2);
      return '$sizeStr MB';
    } else if (downloaded >= pow(1024, 3) && downloaded < pow(1024, 4)) {
      var sizeStr = (downloaded / pow(1024, 3)).toStringAsFixed(2);
      return '$sizeStr GB';
    } else if (downloaded >= pow(1024, 4) && downloaded < pow(1024, 5)) {
      var sizeStr = (downloaded / pow(1024, 4)).toStringAsFixed(2);
      return '$sizeStr TB';
    } else if (downloaded >= pow(1024, 5)) {
      var sizeStr = (downloaded / pow(1024, 5)).toStringAsFixed(2);
      return '$sizeStr PB';
    }
    return '${downloaded.toStringAsFixed(2)} bytes';
  }

  factory VoiceJob.fromJson(json) => VoiceJob(
        dateTime: json['time'],
        sourceFile:
            json['input_path'] != null ? File(json['input_path']) : null,
        targetFile:
            json['output_path'] != null ? File(json['output_path']) : null,
        voice:
            json['voice'] != null ? VoiceOption.fromJson(json['voice']) : null,
        content: json['content'],
      );

  Map<String, dynamic> toJson() => {
        'time': dateTime.millisecondsSinceEpoch,
        'output_path': targetFile?.path,
        'input_path': sourceFile?.path,
        'voice': voice?.toJson(),
        'content': content,
      };
}

class VoiceOption {
  final String name;
  final String lang;
  VoiceStyles voiceStyles;
  double speakingSpeed;
  double pitch;

  VoiceOption({
    this.name,
    this.lang,
    double pitch,
    double speakingSpeed,
    this.voiceStyles = VoiceStyles.General,
  }) {
    this.pitch = pitch ?? 1.0;
    this.speakingSpeed = speakingSpeed ?? 1.0;
  }

  factory VoiceOption.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    var styles = VoiceStyles.General;
    if (json['Style'] != null) {
      styles = VoiceStyles.values.firstWhere(
        (e) => e.toString() == 'VoiceStyles.' + json['Style'],
        orElse: () => null,
      );
    }
    try {
      return VoiceOption(
        name: json['Name'],
        lang: json['Locale'],
        pitch: json['Pitch'] ?? 0,
        speakingSpeed: json['SpeakingSpeed'] ?? 1,
        voiceStyles: styles,
      );
    } catch (err) {
      print(err);
    }
  }

  @override
  String toString() => '<VoiceOption: $lang - $name />';

  factory VoiceOption.copyWith({
    String name,
    String lang,
    double pitch,
    double speakingSpeed,
    VoiceStyles styles,
  }) {
    return VoiceOption(
      name: name,
      lang: lang,
      pitch: pitch,
      speakingSpeed: speakingSpeed,
      voiceStyles: styles,
    );
  }

  String get pitchPercentage {
    if (pitch > 2 || pitch < 0) {
      throw 'Pitch should within the range 0 and 2';
    }
    var diff = pitch - 1;
    return '${((diff / 1 / 2) * 100).toStringAsFixed(0)}%';
  }

  String get speakingSpeedPercentage {
    if (speakingSpeed > 3 || speakingSpeed < 0) {
      throw 'Speaking speed should within the range 0 and 3';
    }
    var diff = speakingSpeed - 1;
    return '${((diff / 1) * 100).toStringAsFixed(0)}%';
  }

  @override
  bool operator ==(o) => o is VoiceOption && o.lang == lang && o.name == name;

  int get hasCode => lang.hashCode ^ name.hashCode;

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Locale': lang,
        'SpeakingSpeed': speakingSpeed,
        'Pitch': pitch,
        'Style': voiceStyles.toString(),
      };
}
