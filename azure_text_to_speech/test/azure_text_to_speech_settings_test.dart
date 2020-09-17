import 'package:azure_text_to_speech/azure_text_to_speech.dart';
import 'package:azure_text_to_speech/src/azure_text_to_speech_settings.dart';
import 'package:azure_text_to_speech/src/objects/voice.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('Azure Settings Tests', () {
    AzureTextToSpeechSettings azureTextToSpeech;
    Dio network;

    setUp(() {
      network = MockDio();
      when(network.get(any, options: anyNamed('options'))).thenAnswer(
        (realInvocation) async => Response(data: [
          {'name': 'test1', 'lang': 'cn'},
          {'name': 'test2', 'lang': 'us'},
        ]),
      );

      azureTextToSpeech = AzureTextToSpeechSettings(
        subscriptionKey: '',
        network: network,
      );
    });

    test('Set speaking speed', () {
      azureTextToSpeech.option = VoiceOption(name: 'test', lang: 'CN');
      expect(azureTextToSpeech.option.name, 'test');
      expect(azureTextToSpeech.option.speakingSpeed, 1);
      azureTextToSpeech.voiceSpeakingSpeed = 2;
      expect(azureTextToSpeech.option.speakingSpeed, 2);
    });

    test('Set speaking pitch', () {
      azureTextToSpeech.option = VoiceOption(name: 'test', lang: 'CN');
      expect(azureTextToSpeech.option.name, 'test');
      expect(azureTextToSpeech.option.pitch, 1);
      azureTextToSpeech.voicePitch = 2;
      expect(azureTextToSpeech.option.pitch, 2);
    });

    test('Fetch voice options', () async {
      azureTextToSpeech.accessToken = 'abcd';
      azureTextToSpeech.area = Area.center_us;
      var options = await azureTextToSpeech.getVoiceOptions();
      expect(options.length, 2);
    });
  });
}
