import 'package:azure_text_to_speech/azure_text_to_speech.dart';
import 'package:azure_text_to_speech/src/azure_text_to_speech_local.dart';
import 'package:azure_text_to_speech/src/objects/voice.dart';
import 'key.dart';

void main() async {
  var db = AzureTextToSpeechLocal();
  await db.initLocal();
  db.getVoiceJobsFromDBStream.listen((event) {
    print('==============');
    print(event);
  });
  var jobs = [
    VoiceJob(content: 'abc'),
    VoiceJob(content: 'cde'),
  ];

  await db.addVoiceJob(jobs[0]);
  await Future.delayed(Duration(seconds: 1));
  await db.addVoiceJob(jobs[1]);
  await Future.delayed(Duration(seconds: 1));
  await db.removeVoiceJob(jobs[0]);
}
