import 'dart:async';

import 'package:azure_text_to_speech/src/azure_text_to_speech_auth.dart';
import 'package:azure_text_to_speech/src/objects/voice.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../azure_text_to_speech.dart';

/// Azure Text To Speech settings
class AzureTextToSpeechSettings extends AzureTextToSpeechAuth {
  final StreamController _areaController = StreamController<Area>();
  final StreamController _optionController = StreamController<VoiceOption>();
  String subscriptionKey;

  AzureTextToSpeechSettings(
      {@required this.subscriptionKey, @required Dio network})
      : super(network: network);

  VoiceOption _option;
  Area _selectedArea;

  /// Get List of voices
  Future<List<VoiceOption>> getVoiceOptions() async {
    try {
      if (accessToken == null) {
        throw 'No access Token. Try to call auth() before using this method';
      }
      var response = await network.get(
        'https://${_selectedArea.name}.$avaliableVoiceEndPoint',
        options: Options(headers: {
          'Authorization': 'Bearer ' + accessToken,
        }),
      );
      var opt =
          (response.data as List).map((o) => VoiceOption.fromJson(o)).toList();

      return opt;
    } catch (err) {
      print(err);
      rethrow;
    }
  }

  /// Get Selected area
  Area get area => _selectedArea;

  /// Set selected area
  set area(Area area) {
    _selectedArea = area;
    _areaController.add(area);
  }

  /// Get selected option
  VoiceOption get option => _option;

  /// Set selected voice option
  set option(VoiceOption option) {
    _option = VoiceOption.copyWith(
      name: option.name,
      lang: option.lang,
      speakingSpeed: _option?.speakingSpeed,
      pitch: _option?.pitch,
    );

    _optionController.add(option);
  }

  /// Set voice speaking speed
  set voiceSpeakingSpeed(double speed) {
    if (speed < 0 || speed > 3) {
      throw 'Speaking speed should within the range 0 and 3';
    }
    _option?.speakingSpeed = speed;
    _optionController.add(option);
  }

  /// Set voice pitch
  set voicePitch(double pitch) {
    if (pitch < 0 || pitch > 2) {
      throw 'Speaking pitch should within the range 0 and 2';
    }
    _option?.pitch = pitch;
    _optionController.add(option);
  }

  /// Get selected voice option stream
  Stream<VoiceOption> get selectedVoiceOptionStream => _optionController.stream;

  /// Get selected area stream
  Stream<Area> get selectedAreaStream => _areaController.stream;
}
