import 'dart:io';

import 'package:azure_text_to_speech/azure_text_to_speech.dart';
import 'key.dart';

void main() async {
  var azure = AzureTextToSpeech(subscriptionKey: kSubscriptionKey);
  await azure.init(azure.areaList[1]);
  var options = await azure.getVoiceOption();
  azure.option = options[133];
  var file = File('output.wav')..createSync();

  await azure.transformContent('test test', file);


}
