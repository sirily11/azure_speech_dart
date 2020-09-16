import 'package:azure_text_to_speech/azure_text_to_speech.dart';
import 'package:azure_text_to_speech/src/objects/voice.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    AzureTextToSpeech azureTextToSpeech;
    setUp(() {
      azureTextToSpeech = AzureTextToSpeech(subscriptionKey: '');
    });

    test('Set speaking speed', () {
      azureTextToSpeech.option = VoiceOption(name: 'test', lang: 'CN');
      expect(azureTextToSpeech.option.name, 'test');
      expect(azureTextToSpeech.option.pitch, 1);
    });
  });
}
