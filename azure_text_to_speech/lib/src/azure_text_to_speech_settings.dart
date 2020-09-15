import 'dart:async';

import 'package:azure_text_to_speech/src/objects/voice.dart';

/// Azure Text To Speech settings
class AzureTextToSpeechSettings {
  final StreamController _areaController = StreamController<Area>();
  final StreamController _optionController = StreamController<VoiceOption>();

  VoiceOption _option;
  Area _selectedArea;

  /// List of areas avaliable
  final List<Area> areaList = [
    Area(label: 'Central US', name: 'centralus'),
    Area(label: 'East US', name: 'eastus'),
    Area(label: 'East US2', name: 'eastus2'),
    Area(label: 'Japan East', name: 'japaneast'),
    Area(label: 'East Asia', name: 'eastasia')
  ];

  Future<List<VoiceOption>> getVoiceOption() async {
    //TODO: Add fetch
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

  /// Set selected option
  set options(VoiceOption option) {
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
    _option?.speakingSpeed = speed;
    _optionController.add(option);
  }

  /// Set voice pitch
  set voicePitch(double pitch) {
    _option?.pitch = pitch;
    _optionController.add(option);
  }

  /// Get selected voice option stream
  Stream<VoiceOption> get selectedVoiceOptionStream => _optionController.stream;

  /// Get selected area stream
  Stream<Area> get selectedAreaStream => _areaController.stream;
}
