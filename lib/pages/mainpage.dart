import 'package:bookshelf/constants/colors.dart';
import 'package:bookshelf/data/dbhelper.dart';
import 'package:bookshelf/data/dbtablecreate.dart';
import 'package:bookshelf/pages/dictionary.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {

  List<String> tables = []; // Dinamik olarak oluşturulan tablo isimlerini saklar

  @override
  void initState() {
    super.initState();
    loadTables(); // Uygulama başlarken tabloları yükler
  }

  Future<void> loadTables() async {
    final db = await getDatabase();
    var res = await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
    
    setState(() {
      tables = res.map((table) => table['name'].toString()).toList();
    });
  }

  // bookshelfcontainer(context, deviceWidth, deviceHeight),

  final TextEditingController _tableNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;


    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: appbarcolor,
        centerTitle: true,
        title: Text("Kitaplığın",style: TextStyle(color: appbartitlecolor,fontWeight: FontWeight.bold,fontSize: 24),),
      ),
      body: Expanded(child: tables.isNotEmpty ?
      ListView.builder(itemCount: tables.length,itemBuilder: (context, index) {
        return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DictionaryPage(tableName: tables[index],),));
      },
      child: Container(
        color: containerColor,
        width: deviceWidth,
        height: deviceHeight / 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 10,),
            Text(tables[index], style: TextStyle(color: appbartitlecolor, fontWeight: FontWeight.w900, fontSize: 18),),
            Spacer(),
            GestureDetector(onTap: () {
              updatebookshelf(tables[index]);
            },child: Icon(Icons.settings, color: Colors.grey.shade400, size: 28,)),
            SizedBox(width: 5,),
            GestureDetector(onTap: () {
              deletebookshelf(tables[index], index);
            },child: Icon(Icons.delete_forever_rounded, color: Colors.red.shade700, size: 28,)),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
      },) : Center()
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {
        createbookshelf(); 
      },
      backgroundColor: appbarcolor,
      label: Text("Oluştur",style: TextStyle(color: appbartitlecolor),),
      icon: Icon(Icons.book,color: appbartitlecolor,),
      ),
    );
  }

  
  
  Future createbookshelf() => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Sözlük Adını Giriniz",style: TextStyle(color: appbartitlecolor,fontWeight: FontWeight.bold),),
      actions: [
        TextField(
        controller: _tableNameController,
          decoration: InputDecoration(
            labelText: "Sözlük İsmi",
            labelStyle: TextStyle(
              color: Colors.white
            ),
            enabledBorder: UnderlineInputBorder(      
              borderSide: BorderSide(color: Colors.white),   
            ),  
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),  
            focusColor: Colors.white
          ),
        style: TextStyle(
          color: appbartitlecolor,
        ),
        ),
        SizedBox(height: 10,),
        ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: containerColor 
        ),
        onPressed: () async{
          String tableName = _tableNameController.text.trim();
                if (tableName.isNotEmpty) {
                  await createTable(tableName);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sözlük $tableName oluşturuldu')),
                  );
                  loadTables();
                  _tableNameController.text = "";
                }
          Navigator.pop(context);
        }, child: const Text("Sözlük Oluştur",style: TextStyle(color: Colors.yellow,fontWeight: FontWeight.bold
            ),
          ),
        )
      ],
      backgroundColor: appbarcolor,
    ),
    );

    Future deletebookshelf(String tabloadi, index) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Center(child: Text(tabloadi + " Adlı Sözlük Silinecek ",style: TextStyle(color: appbartitlecolor,fontWeight: FontWeight.bold),)),
      actions: [
        SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: containerColor 
        ),
        onPressed: () {                
          Navigator.pop(context);
        }, child: const Text("Vazgeç",style: TextStyle(color: Colors.yellow,fontWeight: FontWeight.bold
            ),
          ),
        ),
        ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: containerColor 
        ),
        onPressed: () async{        
                  deleteTable(tables[index]);
                  loadTables();
          Navigator.pop(context);
        }, child: const Text("Tabloyu sil",style: TextStyle(color: Colors.yellow,fontWeight: FontWeight.bold
            ),
          ),
        )

          ],
        ),
      ],
      backgroundColor: appbarcolor,
    ),
    );


    Future updatebookshelf(String oldtablename) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Yeni Sözlük Adını Giriniz",style: TextStyle(color: appbartitlecolor,fontWeight: FontWeight.bold),),
      actions: [
        TextField(
        controller: _tableNameController,
          decoration: InputDecoration(
            labelText: "Sözlük İsmi",
            labelStyle: TextStyle(
              color: Colors.white
            ),
            enabledBorder: UnderlineInputBorder(      
              borderSide: BorderSide(color: Colors.white),   
            ),  
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),  
            focusColor: Colors.white
          ),
        style: TextStyle(
          color: appbartitlecolor,
        ),
        ),
        SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: containerColor 
        ),
        onPressed: () async{
          Navigator.pop(context);
        }, child: const Text("Vazgeç",style: TextStyle(color: Colors.yellow,fontWeight: FontWeight.bold
            ),
          ),
        ),
        ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: containerColor 
        ),
        onPressed: () async{
          String tableName = _tableNameController.text.trim();
                if (tableName.isNotEmpty) {
                  await updateTable(oldtablename,tableName);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tablo ismi $tableName olarak güncellendi')),
                  );
                  loadTables();
                  _tableNameController.text = "";
                }
          Navigator.pop(context);
        }, child: const Text("Değiştir",style: TextStyle(color: Colors.yellow,fontWeight: FontWeight.bold
            ),
          ),
        ),
          ],
        ),
      ],
      backgroundColor: appbarcolor,
    ),
    );


}
