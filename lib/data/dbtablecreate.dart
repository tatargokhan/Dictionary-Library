import 'package:bookshelf/data/dbhelper.dart';

Future<void> createTable(String tableName) async {
  final db = await getDatabase();

  // Dinamik olarak SQL sorgusu oluştur
  String query = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      word varchar(55),
      mean varchar(55)
    )
  ''';

  await db.execute(query);
  
}

Future<void> deleteTable(String tableName) async {
  final db = await getDatabase();

  // Dinamik olarak SQL sorgusu oluştur
  String query = '''
   DROP TABLE $tableName
  ''';

  await db.execute(query);
  
}


Future<void> updateTable(String tableName, String newtableName) async {
  final db = await getDatabase();

   print('Old table name: $tableName (Type: ${tableName.runtimeType})');
  print('New table name: $newtableName (Type: ${newtableName.runtimeType})');

  // Dinamik olarak SQL sorgusu oluştur
  String query = '''
   ALTER TABLE $tableName RENAME TO $newtableName
  ''';
  

  await db.execute(query);
  
}

Future<void> getData(String tableName) async {
  final db = await getDatabase();

  // Dinamik olarak SQL sorgusu oluştur
  String query = '''
   Select * FROM $tableName
  ''';

  await db.execute(query);
  
}



