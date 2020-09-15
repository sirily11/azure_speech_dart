import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:azure_text_to_speech/src/azure_text_to_speech_settings.dart';
import 'package:meta/meta.dart';
import 'package:xml/xml.dart' as xml;
import 'package:azure_text_to_speech/src/azure_text_to_speech_auth.dart';
import 'package:azure_text_to_speech/src/azure_text_to_speech_local.dart';
import 'package:azure_text_to_speech/src/objects/voice.dart';
import 'package:dio/dio.dart';

class AzureTextToSpeech extends AzureTextToSpeechSettings
    with AzureTextToSpeechLocal {
  bool _isWorking;
  bool _isDone;
  final StreamController _controller = StreamController<List<VoiceJob>>();

  Stream<List<VoiceJob>> get jobs => _controller.stream;

  AzureTextToSpeech({Dio network, @required String subscriptionKey})
      : super(network: network, subscriptionKey: subscriptionKey) {
    _isWorking = false;
    _isDone = false;
    subscriptionKey = subscriptionKey;
  }

  Future<void> init(Area area) async {
    await initLocal();
    this.area = area;
    await auth(subscriptionKey, area);
  }

  Future<void> transformFile(File sourceFile, File targetFile) async {
    var job = VoiceJob(
      sourceFile: sourceFile,
      targetFile: targetFile,
      voice: VoiceOption.fromJson(option.toJson()),
    );
    await _transformSingle(job);
  }

  Future<void> transformContent(String content, File targetFile) async {
    var job = VoiceJob(
      targetFile: targetFile,
      content: content,
      voice: VoiceOption.fromJson(option.toJson()),
    );
    await _transformSingle(job);
  }

  Future<void> _transformSingle(VoiceJob job) async {
    if (job.isDone == false) {
      try {
        String textContent;
        job.percentage = 0.3;
        //TODO: update percentage
        if (job.sourceFile != null) {
          var bytes = await job.sourceFile.readAsBytes();
          var decode = Utf8Decoder();
          textContent = decode.convert(bytes);
        } else {
          textContent = job.content;
        }

        var builder = xml.XmlBuilder();
        builder.element('speak', nest: () {
          builder.attribute('version', '1.0');
          builder.attribute('xml:lang', job.voice.lang);
          builder.element('voice', nest: () {
            builder.attribute('xml:lang', job.voice.lang);
            builder.attribute('name', job.voice.name);
            builder.element('prosody', nest: () {
              builder.attribute('rate', job.voice.speakingSpeedPercentage);
              builder.attribute('pitch', job.voice.pitchPercentage);
              builder.text(textContent);
            });
          });
        });

        job.percentage = 0.6;
        //TODO: Update percentage
        await job.targetFile.create();
        var body = builder.build().toXmlString();
        await network.download(
          'https://${area.name}.$voiceEndPoint',
          job.targetFile.path,
          data: body,
          onReceiveProgress: (count, total) {
            job.downloaded = count;
          },
          options: Options(
            method: 'POST',
            contentType: "text/plain",
            headers: {
              'Authorization': 'Bearer ' + accessToken,
              'Content-Type': 'application/ssml+xml',
              'X-Microsoft-OutputFormat': 'riff-24khz-16bit-mono-pcm',
              'User-Agent': 'YOUR_RESOURCE_NAME'
            },
          ),
        );
        job.isDone = true;
        job.percentage = 1;
      } on DioError catch (err) {
        job.isError = true;
        //TODO: update

      }
    }
  }

  // Future<void> transformMultiple(
  //     {@required subscriptionKey, @required List<VoiceJob> jobs}) async {
  //   _isWorking = true;
  //   if (option == null) {
  //     throw 'No Voice option selected';
  //   }
  //   await auth(subscriptionKey);
  //   for (var i = 0; i < jobs.length; i++) {
  //     var currentJob = jobs[i];
  //     if (!_isWorking) {
  //       await Future.doWhile(() async {
  //         await Future.delayed(Duration(milliseconds: 100));
  //         return _isWorking;
  //       });
  //     }
  //     if (_isWorking) {
  //       await transformSingle(currentJob);
  //     }
  //   }
  //   _isWorking = false;
  // }
}
