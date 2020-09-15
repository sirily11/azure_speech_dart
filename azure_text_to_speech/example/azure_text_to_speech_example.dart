import 'package:azure_text_to_speech/azure_text_to_speech.dart';

void main() async {
  var azure =
      AzureTextToSpeech(subscriptionKey: '99014f01fa8d4a67ade10de3564fe72f');
  await azure.init(azure.areaList[1]);
  var options = await azure.getVoiceOption();
  print(options);
}
