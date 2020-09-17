import 'azure_text_to_speech_network.dart';
import 'package:dio/dio.dart';
import '../azure_text_to_speech.dart';

class AzureTextToSpeechAuth extends AzureTextToSpeechNetwork {
  final String authEndPoint = 'api.cognitive.microsoft.com/sts/v1.0/issueToken';
  final String voiceEndPoint = 'tts.speech.microsoft.com/cognitiveservices/v1';
  final String avaliableVoiceEndPoint =
      'tts.speech.microsoft.com/cognitiveservices/voices/list';
  String accessToken;

  AzureTextToSpeechAuth({Dio network}) {
    this.network = network ?? Dio();
  }

  /// Auth and get access token
  Future<void> auth(String subscribeToken, Area area) async {
    try {
      if (area == null) {
        throw 'No Area selected';
      }
      var url = 'https://${area.name}.$authEndPoint';
      var response = await network.post(
        url,
        options:
            Options(headers: {'Ocp-Apim-Subscription-Key': subscribeToken}),
      );
      accessToken = response.data;
    } catch (err) {
      print(err);
      rethrow;
    }
  }

  bool get hasLogined => accessToken != null;
}
