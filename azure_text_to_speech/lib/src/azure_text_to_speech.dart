import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:azure_text_to_speech/src/azure_text_to_speech_settings.dart';
import 'package:meta/meta.dart';
import 'package:xml/xml.dart' as xml;
import 'package:azure_text_to_speech/src/azure_text_to_speech_local.dart';
import 'package:azure_text_to_speech/src/objects/voice.dart';
import 'package:dio/dio.dart';

/// This is a azure text to speech converter based on the azure api.
/// In order to use this library, you need to provide a subsription key.
/// Then call init method to initialize the library.
///
/// After initialization finished, you can either call [transformContent] or
/// [transformFile] method. To stop current [job], please call [cancel] method
class AzureTextToSpeech extends AzureTextToSpeechSettings
    with AzureTextToSpeechLocal {
  bool _isWorking;

  final _controller = StreamController<List<VoiceJob>>();

  // Private variable which represents the job list
  final _jobs = <VoiceJob>[];

  /// List of voice jobs
  Stream<List<VoiceJob>> get jobStream => _controller.stream;

  AzureTextToSpeech({Dio network, @required String subscriptionKey})
      : super(network: network, subscriptionKey: subscriptionKey) {
    _isWorking = false;
    subscriptionKey = subscriptionKey;
  }

  /// Init the application
  Future<void> init(Area area) async {
    await initLocal();
    this.area = area;
    await auth(subscriptionKey, area);
  }

  /// Transform [source file(string)] into audio file
  Future<void> transformFile(File sourceFile, File targetFile) async {
    var job = VoiceJob(
      sourceFile: sourceFile,
      targetFile: targetFile,
      voice: VoiceOption.fromJson(option.toJson()),
      cancelToken: CancelToken(),
    );
    await _transformSingle(job);
  }

  /// Transform [content] into wav file
  Future<void> transformContent(String content, File targetFile) async {
    var job = VoiceJob(
      targetFile: targetFile,
      content: content,
      voice: VoiceOption.fromJson(option.toJson()),
      cancelToken: CancelToken(),
    );
    await _transformSingle(job);
  }

  /// Cancel the voice [job]
  void cancelVoiceJob(VoiceJob job) {
    job.cancelToken?.cancel();
    job.isDone = false;
    job.percentage = 0;
    job.downloaded = 0;
    _controller.add(_jobs);
  }

  Future<void> _transformSingle(VoiceJob job) async {
    _jobs.add(job);
    _isWorking = true;
    try {
      String textContent;
      job.percentage = 0.3;
      // Update stream
      _controller.add(_jobs);

      // Build xml file
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
      // Update stream
      job.percentage = 0.6;
      _controller.add(_jobs);

      if (!await job.targetFile.exists()) {
        await job.targetFile.create();
      }
      var body = builder.build().toXmlString();
      await network.download(
        'https://${area.name}.$voiceEndPoint',
        job.targetFile.path,
        data: body,
        onReceiveProgress: (count, total) {
          // Update stream
          job.downloaded = count;
          _controller.add(_jobs);
        },
        options: Options(
          method: 'POST',
          contentType: 'text/plain',
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
      _controller.add(_jobs);
    } on DioError catch (err) {
      job.isError = true;
      _controller.add(_jobs);
      _controller.addError(err);
    } finally {
      _isWorking = false;
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
