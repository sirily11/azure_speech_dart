import 'dart:io';

import 'package:azure_text_to_speech/azure_text_to_speech.dart';
import 'key.dart';

void main() async {
  var azure = AzureTextToSpeech(subscriptionKey: kSubscriptionKey);
  azure.jobStream.listen((e) {
    e.forEach((element) {
      print(
          '${element.targetFile.path} ${element.percentage * 100}% - ${element.downloadedSize}');
    });
  });

  await azure.init(Area.center_us);
  var options = await azure.getVoiceOptions();
  azure.option = options[133];
  var file = File('output.wav')..createSync();

  await azure.transformContent('test test', file);
}
