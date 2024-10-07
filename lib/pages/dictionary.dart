import 'package:bookshelf/constants/colors.dart';
import 'package:bookshelf/data/dbhelper.dart';
import 'package:flutter/material.dart';

class DictionaryPage extends StatefulWidget {
  final String tableName;
  const DictionaryPage({super.key, required this.tableName});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  List<Map<String, dynamic>> words = []; // Tablo verilerini tutacak liste

  @override
  void initState() {
    super.initState();
    loadWords();
  }

  Future<void> loadWords() async {
    final db = await getDatabase();
    var res = await db
        .rawQuery('SELECT * FROM ${widget.tableName} ORDER BY word ASC');

    setState(() {
      words = List.from(res); // Gelen verileri listeye atıyoruz
    });
  }

  Future<void> deleteWord(String word) async {
    final db = await getDatabase();
    await db
        .rawDelete('DELETE FROM ${widget.tableName} WHERE word = ?', [word]);

    setState(() {
      words.removeWhere((element) => element['word'] == word);
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double pad = deviceWidth / 25;

    Map<String, List<Map<String, dynamic>>> groupedWords = {};
    for (var word in words) {
      String firstLetter = word['word'][0].toUpperCase();
      if (!groupedWords.containsKey(firstLetter)) {
        groupedWords[firstLetter] = [];
      }
      groupedWords[firstLetter]!.add(word);
    }

    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_outlined,
              color: appbartitlecolor,
            )),
        backgroundColor: appbarcolor,
        centerTitle: true,
        title: Text(
          widget.tableName,
          style: TextStyle(
              color: appbartitlecolor,
              fontWeight: FontWeight.bold,
              fontSize: 24),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(pad),
        child: ListView.builder(
          itemCount: words.length,
          itemBuilder: (context, index) {
            String word = words[index]['word'];
            String mean = words[index]['mean'];

            return GestureDetector(
              onLongPress: () {
                showDeleteDialog(
                    word); // Uzun basıldığında silme işlemi için dialog aç
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index == 0 ||
                        word[0].toUpperCase() !=
                            words[index - 1]['word'][0].toUpperCase()) ...[
                      Text(
                        word[0].toUpperCase(),
                        style: TextStyle(
                          color: appbarcolor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    Row(
                      children: [
                        Text(
                          word,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(" : "),
                        Text(
                          mean,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          createword();
        },
        backgroundColor: appbarcolor,
        label: Text(
          "Ekle",
          style: TextStyle(color: appbartitlecolor),
        ),
        icon: Icon(
          Icons.add,
          color: appbartitlecolor,
        ),
      ),
    );
  }

  Future<void> createword() async {
    final TextEditingController wordController = TextEditingController();
    final TextEditingController meaningController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Eklenecek Kelimeyi Giriniz",
            style: TextStyle(
                color: appbartitlecolor, fontWeight: FontWeight.bold)),
        actions: [
          Column(
            children: [
              TextField(
                controller: wordController,
                decoration: InputDecoration(
                    labelText: "Kelime",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusColor: Colors.white),
                style: TextStyle(
                  color: appbartitlecolor,
                ),
              ),
              TextField(
                controller: meaningController,
                decoration: InputDecoration(
                    labelText: "Anlamı",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusColor: Colors.white),
                style: TextStyle(
                  color: appbartitlecolor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: containerColor),
            onPressed: () async {
              String word = wordController.text.trim();
              String meaning = meaningController.text.trim();

              if (word.isNotEmpty && meaning.isNotEmpty) {
                await addWordToDatabase(widget.tableName, word, meaning);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Kelime eklendi: $word')),
                );
                setState(() {
                  // Sayfa otomatik güncellenir
                  loadWords();
                });
              }

              Navigator.pop(context);
            },
            child: const Text("Kelime Ekle",
                style: TextStyle(
                    color: Colors.yellow, fontWeight: FontWeight.bold)),
          ),
        ],
        backgroundColor: appbarcolor,
      ),
    );
  }

// Veritabanına kelime ekleme fonksiyonu
  Future<void> addWordToDatabase(
      String tableName, String word, String meaning) async {
    final db = await getDatabase();
    await db.insert(
      tableName,
      {'word': word, 'mean': meaning}, // Sütun adlarını burada kullanıyoruz
    );
  }

  Future<void> showDeleteDialog(String word) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "$word kelimesini silmek istiyor musunuz?",
            style: TextStyle(
              color: appbartitlecolor,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: containerColor),
              onPressed: () {
                Navigator.pop(context); // Vazgeç ve dialogu kapat
              },
              child: const Text(
                "Vazgeç",
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: containerColor),
              onPressed: () async {
                await deleteWord(word); // Kelimeyi sil
                Navigator.pop(context); // Dialogu kapat
              },
              child: const Text(
                "Sil",
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          backgroundColor: appbarcolor,
        ),
      );
}
