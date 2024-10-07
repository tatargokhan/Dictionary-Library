import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

Future<Database> getDatabase() async {
  final directory = await getApplicationDocumentsDirectory();
  final path = join(directory.path, 'my_database.db');

  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      // İlk açılışta yapılacak işlemler
    },
  );
}
