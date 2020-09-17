import 'package:azure_text_to_speech/azure_text_to_speech.dart';
import 'key.dart';

void main() async {
  var azure = AzureTextToSpeech(subscriptionKey: kSubscriptionKey);
  azure.selectedAreaStream.listen((event) {
    print('print selected area: ${event.name}');
  });

  azure.selectedVoiceOptionStream.listen((event) {
    print(
        'print selected voice: ${event.name} - ${event.pitch} - ${event.speakingSpeed}');
  });

  await azure.init(Area.east_us);
  var options = await azure.getVoiceOptions();
  azure.option = options[0];
  azure.voiceSpeakingSpeed = 2.0;
}
