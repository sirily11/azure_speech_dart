import 'dart:io';

import 'dart:math';

/// Voice Job
/// Which contains transfer content, target file, source file and download percentage
class VoiceJob {
  final File sourceFile;
  final File targetFile;

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
  VoiceJob({this.sourceFile, this.targetFile, this.content, this.voice}) {
    dateTime = DateTime.now();
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

  Map<String, dynamic> toJson() => {
        'time': dateTime.millisecondsSinceEpoch,
        'output_path': targetFile.path,
        'input_path': sourceFile?.path,
        'voice': voice?.toJson(),
        'content': content,
      };
}

class VoiceOption {
  final String name;
  final String lang;
  double speakingSpeed;
  double pitch;
  VoiceOption({
    this.name,
    this.lang,
    this.pitch = 1.0,
    this.speakingSpeed = 1.0,
  });

  factory VoiceOption.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return VoiceOption(
      name: json['Name'],
      lang: json['Locale'],
      pitch: json['Pitch'] ?? 0,
      speakingSpeed: json['SpeakingSpeed'] ?? 1,
    );
  }

  @override
  String toString() => '<VoiceOption: $lang - $name />';

  factory VoiceOption.copyWith({
    String name,
    String lang,
    double pitch,
    double speakingSpeed,
  }) {
    return VoiceOption(
      name: name,
      lang: lang,
      pitch: pitch,
      speakingSpeed: speakingSpeed,
    );
  }

  String get pitchPercentage {
    var diff = pitch - 1;
    return '${((diff / 1 / 2) * 100).toStringAsFixed(0)}%';
  }

  String get speakingSpeedPercentage {
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
      };
}

class Area {
  final String label;
  final String name;

  Area({this.label, this.name});

  @override
  bool operator ==(o) => o is Area && o.label == label && o.name == name;

  int get hasCode => label.hashCode ^ name.hashCode;

  factory Area.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return Area(
      name: json['name'],
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'name': name};
}
