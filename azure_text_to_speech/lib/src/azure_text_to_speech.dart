import 'dart:async';
import 'dart:html';

import 'package:azure_text_to_speech/azure_text_to_speech.dart';
import 'package:azure_text_to_speech/src/azure_text_to_speech_auth.dart';
import 'package:azure_text_to_speech/src/azure_text_to_speech_local.dart';
import 'package:azure_text_to_speech/src/objects/voice.dart';
import 'package:dio/dio.dart';

class AzureTextToSpeech extends AzureTextToSpeechAuth
    with AzureTextToSpeechLocal {
  final StreamController _controller = StreamController<List<VoiceJob>>();

  Stream<List<VoiceJob>> get jobs => _controller.stream;

  AzureTextToSpeech({Dio network}) : super(network: network);

  Future<void> init() async {}

  Future<void> transferFile(File sourceFile, File targetFile) async {}

  Future<void> transferContent(String content, File targetFile) async {}
}
