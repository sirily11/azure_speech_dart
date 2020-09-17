import 'package:azure_text_to_speech/src/objects/voice.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

/// Local files process class
class AzureTextToSpeechLocal {
  Database _database;

  /// Initialize database
  Future<void> initLocal({String dbPath}) async {
    var path = dbPath ?? 'speech.db';
    var dbFactory = databaseFactoryIo;
    _database = await dbFactory.openDatabase(path);
  }

  /// List of jobs which has been done before
  Stream<List<VoiceJob>> get getVoiceJobsFromDBStream {
    if (_database == null) {
      throw 'You need to call initLocal first';
    }
    var finder = Finder(sortOrders: [SortOrder('time')]);
    var store = StoreRef.main();
    return store.query(finder: finder).onSnapshots(_database).map(
          (event) => event
              .map(
                (e) => VoiceJob.fromJson(e.value),
              )
              .toList(),
        );
  }

  /// Add a voice job to db
  Future<void> addVoiceJob(VoiceJob job) async {
    var store = StoreRef.main();
    await store.add(_database, job.toJson());
  }

  /// Remove a voice job from db
  Future<void> removeVoiceJob(VoiceJob job) async {
    var store = StoreRef.main();
    await store.delete(
      _database,
      finder: Finder(
        filter: Filter.equals('time', job.dateTime.millisecondsSinceEpoch),
      ),
    );
  }
}
