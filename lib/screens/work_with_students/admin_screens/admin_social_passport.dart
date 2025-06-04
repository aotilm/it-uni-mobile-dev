import 'dart:developer';

// import 'package:excel/excel.dart'
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:test_journal/screens/work_with_students/cards/card_widget.dart';
import '../../../theme_data.dart';
import '../edit_form.dart';
import 'dart:io';
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';


class AdminSocialPassport extends StatefulWidget {
  const AdminSocialPassport({super.key, this.email});
  final String? email;

  @override
  State<AdminSocialPassport> createState() => _AdminSocialPassportState();
}

class _AdminSocialPassportState extends State<AdminSocialPassport> {
  List<Map<String, dynamic>> spCategories = [];
  String? selectedCategory = EditForm.invalidCategory;
  Map<String, dynamic>? selectedCategoryMap;

  List<CardWidget> spDefaultCards = [];
  List<CardWidget> spManyCards = [];
  List<CardWidget> spInvalidCards = [];
  List<CardWidget> spChornobylCards = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    selectCategoriesNames();
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      isLoading = true;
      switch(selectedCategory){
        case EditForm.invalidCategory:
          List<CardWidget> cardsInvalid = await returnSpIvalidPeopleCard();
          setState(() {
            spInvalidCards = cardsInvalid;
            isLoading = false;
          });
        case EditForm.manyChildrenCategory:
          List<CardWidget> cardsMany = await returnSpManyChildrenCard();
          setState(() {
            spManyCards = cardsMany;
            isLoading = false;
          });
        case EditForm.chornobylCategory:
          List<CardWidget> cardsChoronobyl = await returnSpChornobyltsiCard();
          setState(() {
            spChornobylCards = cardsChoronobyl;
            isLoading = false;
          });
        default:
          List<CardWidget> cardsDefault = await returnSpDefaultCard();
          setState(() {
            spDefaultCards = cardsDefault;
            isLoading = false;
          });
      }

    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> selectCategoriesNames() async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    List<Map<String, dynamic>> fetchedCategories = await connHandler.selectSpCategoryName();

    await connHandler.close();

    setState(() {
      spCategories = fetchedCategories;
      // selectedCategory = spCategories.first['category'];
      selectedCategory = EditForm.invalidCategory;
    });
  }

  Widget getSpCards(){
    switch(selectedCategory){
      case EditForm.invalidCategory:
        if (isLoading){
          return const Center(child: CircularProgressIndicator());
        }
        else if (errorMessage != null){
          return Center(child: Text("Виникла помилка"));
        }
        else if (spInvalidCards.isEmpty){
          return const Center(child: Text(''));
         }
        else
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: spInvalidCards.length,
            itemBuilder: (context, index) {
              return spInvalidCards[index].returnCard(context);
            },
          );
      case EditForm.chornobylCategory:
        if (isLoading){
          return const Center(child: CircularProgressIndicator());
        }
        else if (errorMessage != null){
          return Center(child: Text("Виникла помилка"));
        }
        else if (spChornobylCards.isEmpty){
          return const Center(child: Text(''));
        }
        else
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: spChornobylCards.length,
            itemBuilder: (context, index) {
              return spChornobylCards[index].returnCard(context);
            },
          );
      case EditForm.manyChildrenCategory:
        if (isLoading){
          return const Center(child: CircularProgressIndicator());
        }
        else if (errorMessage != null){
          return Center(child: Text("Виникла помилка"));
        }
        else if (spManyCards.isEmpty){
          return const Center(child: Text(''));
        }
        else
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: spManyCards.length,
            itemBuilder: (context, index) {
              return spManyCards[index].returnCard(context);
            },
          );
      default:
        if (isLoading){
          return const Center(child: CircularProgressIndicator());
        }
        else if (errorMessage != null){
          return Center(child: Text("Виникла помилка"));
        }
        else if (spDefaultCards.isEmpty){
          return const Center(child: Text(''));
        }
        else
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: spDefaultCards.length,
            itemBuilder: (context, index) {
              return spDefaultCards[index].returnCard(context);
            },
          );
    }
  }

  void messageBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Theme.of(context).primaryColor, content: Text(message)),
    );
  }

  Widget deleteSP(int id) {
    return AlertDialog(
      title: const Text('Видалення запису'),
      content: Text('Ви дійсно хочете видалити запис?'),
      actions: <Widget>[
        TextButton(
          onPressed: () async{
            try{
              final connHandler = MySqlConnectionHandler();
              await connHandler.connect();
              await connHandler.removeRow('sp_category', id);
              await connHandler.close();

              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: Theme.of(context).primaryColor, content: Text('Запис видалено!')),
              );
              setState(() {
                selectedCategory = EditForm.invalidCategory;
              });
            }catch(e){
              messageBar("Вибачте, виникла помилка :(");
              Navigator.pop(context);
            }

          },
          child: const Text('Так'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Скасувати'),
        ),
      ],
    );
  }


  Future<List<CardWidget>> returnSpDefaultCard() async { //
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    // Get the records
    List<Map<String, dynamic>> records = await connHandler.selectSpDefault(selectedCategory!);
    List<CardWidget> testCards = [];

    for (var record in records) {
      final card = CardWidget(
        id: record['id'].toString(),
        firstName: record['first_name']  ?? '',
        lastName: record['second_name'] ?? '',
        middleName: record['middle_name'] ?? '',
        objects: [
          {'Група': record['group'] ?? ''},
          {'Категорія': record['category'] ?? ''},
          {'Дата початку': record['start_date'] ?? ''},
          {'Дата кінця': record['end_date'] ?? ''},
        ],
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditForm(
                  id: int.parse(record['id'].toString()),
                  selectedValue: "Соціальний паспорт",
                  spCategory: record['category'],
                  action: true,
                  showSpDropDown: false,
                ),
              ),
            );
            if(result != null){
              setState(() {_loadCards();});
            }
          },
        onSwipe: () async{
          final res = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return deleteSP(int.parse(record['id'].toString()));
            },
          );
          if(res != null){
            setState(() {_loadCards();});
          }
        }
      );

      testCards.add(card);
    }

    await connHandler.close();
    return testCards;
  }

  Future<List<CardWidget>> returnSpManyChildrenCard() async { //
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    // Get the records
    List<Map<String, dynamic>> records = await connHandler.selectSpManyChildren();
    List<CardWidget> testCards = [];

    for (var record in records) {
      final card = CardWidget(
        id: record['id'].toString(),
        firstName: record['first_name'] ?? 'No Name',
        lastName: record['second_name'] ?? 'No Second Name',
        middleName: record['middle_name'] ?? 'No Middle Name',
        objects: [
          {'Група': record['group'] ?? ''},
          {'Категорія': record['category']},
          {'Дата початку': record['start_date']},
          {'Дата кінця': record['end_date'] ?? ''},
          {'Всього дітей': record['number_of_children'] ?? ''},
          {'З них неповнолітніх': record['less_than_18'] ?? ''},
          {'Більше 18/навчаються': record['more_than_18_studying'] ?? ''}
        ],
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditForm(
                  id: int.parse(record['id'].toString()),
                  selectedValue: "Соціальний паспорт",
                  spCategory: record['category'],
                  action: true,
                  showSpDropDown: false,
                ),
              ),
            );
            if(result != null){
              setState(() {_loadCards();});
            }
          },
          onSwipe: () async{
            final res = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return deleteSP(int.parse(record['id'].toString()));
              },
            );
            if(res != null){
              setState(() {_loadCards();});
            }
          }
      );

      testCards.add(card);
    }

    await connHandler.close();
    return testCards;
  }

  Future<List<CardWidget>> returnSpIvalidPeopleCard() async { //
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    // Get the records
    List<Map<String, dynamic>> records = await connHandler.selectSpInvalidPeople(); //
    List<CardWidget> testCards = [];

    for (var record in records) {
      final card = CardWidget(
        id: record['id'].toString(),
        firstName: record['first_name']  ?? '',
        lastName: record['second_name'] ?? '',
        middleName: record['middle_name'] ?? '',
        objects: [
          {'Група': record['group'] ?? ''},
          {'Категорія': record['category'] ?? ''},
          {'Група інвалідності': record['invalid_group'] ?? ''},
          {'Дата початку': record['start_date'] ?? ''},
          {'Дата кінця': record['end_date'] ?? ''},
        ],
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditForm(
                  id: int.parse(record['id'].toString()),
                  selectedValue: "Соціальний паспорт",
                  spCategory: record['category'],
                  action: true,
                  showSpDropDown: false,
                ),
              ),
            );
            if(result != null){
              setState(() {_loadCards();});
            }
          },
          onSwipe: () async{
            final res = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return deleteSP(int.parse(record['id'].toString()));
              },
            );
            if(res != null){
              setState(() {_loadCards();});
            }
          }
      );

      testCards.add(card);
    }

    await connHandler.close();
    return testCards;
  }

  Future<List<CardWidget>> returnSpChornobyltsiCard() async { //
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    // Get the records
    List<Map<String, dynamic>> records = await connHandler.selectSpChornobyltsi(); //
    List<CardWidget> testCards = [];

    for (var record in records) {
      final card = CardWidget(
        id: record['id'].toString(),
        firstName: record['first_name'] ?? '',
        lastName: record['second_name'] ?? '',
        middleName: record['middle_name'] ?? '',
        objects: [
          {'Група': record['group'] ?? ''},
          {'Категорія': record['category'] ?? ''},
          {'Група чорнобильця': record['cgroup'] ?? ''},
          {'Дата початку': record['start_date'] ?? ''},
          {'Дата кінця': record['end_date'] ?? ''},
        ],
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditForm(
                  id: int.parse(record['id'].toString()),
                  selectedValue: "Соціальний паспорт",
                  spCategory: record['category'],
                  action: true,
                  showSpDropDown: false,
                ),
              ),
            );
            if(result != null){
              setState(() {_loadCards();});
            }
          },
          onSwipe: () async{
            final res = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return deleteSP(int.parse(record['id'].toString()));
              },
            );
            if(res != null){
              setState(() {_loadCards();});
            }
          }
      );

      testCards.add(card);
    }

    await connHandler.close();
    return testCards;
  }

  Future<void> exportToExcel(List<Map<String, dynamic>> records) async {
    try {
      var excelInstance = excel.Excel.createExcel();
      var sheetObject = excelInstance['Sheet1'];

      // Стиль для комірки з межами
      var cellStyle = excel.CellStyle(
        fontFamily: getFontFamily(FontFamily.Calibri),
        leftBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
        rightBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
        topBorder: excel.Border(borderStyle: excel.BorderStyle.Thin, ),
        bottomBorder: excel.Border(borderStyle: excel.BorderStyle.Thin, ),
        numberFormat: excel.CustomDateTimeNumFormat(formatCode: 'dd-MM-yyyy')
      );


        // Додавання заголовка
      var headerRow = [
        TextCellValue('Прізвище'),
        TextCellValue('Ім’я'),
        TextCellValue('По батькові'),
        TextCellValue('Група'),
        TextCellValue('Дата народження'),
        TextCellValue('Категорія'),
        TextCellValue('Повнолітній'),
      ];
      sheetObject.appendRow(headerRow);

      for (var record in records) {
      bool isAdult = record['is_adult'] == 'Так';
      var row = [
        excel.TextCellValue(record['second_name']),
        excel.TextCellValue(record['first_name']),
        excel.TextCellValue(record['middle_name']),
        excel.TextCellValue(record['group']),
        record['date'] != null
            ? excel.DateCellValue(
          day: (record['date'] is String)
              ? DateTime.parse(record['date']).day
              : record['date'].day,
          month: (record['date'] is String)
              ? DateTime.parse(record['date']).month
              : record['date'].month,
          year: (record['date'] is String)
              ? DateTime.parse(record['date']).year
              : record['date'].year,
        )
            : excel.TextCellValue(''),
        excel.TextCellValue(record['category']),
        excel.TextCellValue(isAdult ? "Так": "Ні"),
      ];

      sheetObject.appendRow(row);

      // Застосування стилю до кожної комірки в рядку
      for (var i = 0; i < row.length; i++) {
        var cell = sheetObject.cell(excel.CellIndex.indexByString('${String.fromCharCode(65 + i)}${sheetObject.maxRows}'));
        if (row[i] is excel.DateCellValue) {
          // Apply date-specific format if the value is a date
          cell.cellStyle = cellStyle;
        } else {
          // Apply general style to non-date cells
          cell.cellStyle = cellStyle;
        }
      }
    }


      var directory = await getTemporaryDirectory();
      log('$directory');
      String filePath = '${directory?.path}/social-passport-list.xlsx';
      var bytes = await excelInstance.encode() ?? [];
      var file = File(filePath);
      await file.writeAsBytes(bytes);

      log(' $filePath');

      // Надсилаємо файл
      await sendSpExportFile(widget.email!, filePath);
      messageBar('Файл надіслано - ${widget.email}');

    } catch (e) {
      print('Error saving or sending the file: $e');
      messageBar('Виникла помилка при експорті файлу.');
    }

  }

  Future<void> sendSpExportFile(String recipient, String filePath) async {
    String username = 'aotilm@gmail.com';
    String password = 'hjeo cyed jrwm tuzi';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Журнал куратора')
      ..recipients.add(recipient) // Вказуємо отримувача
      ..subject = 'Експорт соціального паспорту'
      ..text = 'Доданий файл експорту соціального паспорту'
      ..attachments.add(FileAttachment(File(filePath)));


      final sendReport = await send(message, smtpServer);
      log('Message sent: $sendReport');

  }
  // bool isDisabled = false;
  final ValueNotifier<bool> isDisabled = ValueNotifier<bool>(false);
  AlertDialog removeSpCategory()  {
    return AlertDialog(
      title: const Text('Увага!'),
      content: Text('Видалення категорії "$selectedCategory" соціального паспорту призведе до видалення усіх записів пов\'язаних з цією категорією. '),
      actions: <Widget>[
        TextButton(
          onPressed: () async{
            try{
              final connHandler = MySqlConnectionHandler();
              await connHandler.connect();
              await connHandler.removeSPCategory(selectedCategory!);
              await connHandler.close();

              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: Theme.of(context).primaryColor, content: Text('Категорію видалено!')),
              );
            }catch(e){
              log("$e");
              messageBar("Вибачте, виникла помилка :(");
              Navigator.pop(context);
            }
          },
          child: const Text('Видалити'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Скасувати'),
        ),
      ],
    );
  }

  Future<void> addNewCategory(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditForm(
          id: 0,
          selectedValue: "Додавання категорії",
          action: false,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        selectCategoriesNames();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: AppTheme.fABPosition(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!isDisabled.value) {
            isDisabled.value = true; // Вимикаємо кнопку

            try {
              final connHandler = MySqlConnectionHandler();
              await connHandler.connect();
              List<Map<String, dynamic>> records = await connHandler.selectExportSp();
              await connHandler.close();
              await exportToExcel(records);

            } catch (e) {
              log("$e");
            } finally {
              isDisabled.value = false; // Увімкнути кнопку
            }
          } else {
            log('cant send message');
          }
        },
        label: ValueListenableBuilder<bool>(
          valueListenable: isDisabled,
          builder: (context, value, child) {
            return Text(value ? 'Зачекайте...' : 'Експорт');
          },
        ),
        icon: ValueListenableBuilder<bool>(
          valueListenable: isDisabled,
          builder: (context, value, child) {
            return Icon(value ? Icons.hourglass_empty : Icons.save_alt);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: AppTheme.getResponsiveWidthContent(context),
            child: Column(
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     DropdownButton<String>(
                      hint: Text("Виберіть категорію:"),
                      value: selectedCategory,
                      items: spCategories.map((Map<String, dynamic> item) {
                        return DropdownMenuItem<String>(
                          value: item['category'],
                          child: Container(
                            width: AppTheme.dropdownMenuWidthSp(context), // Обмеження ширини
                            // width: MediaQuery.of(context).size.width * 0.65,
                            child: Text(
                              item['category'],
                              softWrap: false,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16 / MediaQuery.textScaleFactorOf(context)),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                          _loadCards();
                        });
                      },

                    ),
                    SizedBox(height: 25),

                    PopupMenuButton<int>(
                      icon: Icon(Icons.edit),
                      onSelected: (int value) async {
                        if (value == 1) {
                          await addNewCategory(context);
                        } else if (value == 2) {
                          if(selectedCategory! != EditForm.manyChildrenCategory && selectedCategory! != EditForm.invalidCategory && selectedCategory! != EditForm.chornobylCategory ){
                            final res = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return removeSpCategory();
                              },
                            );
                            if(res != null){
                              setState(() {
                                selectCategoriesNames();
                              });
                            }
                          } else{
                            messageBar("Неможливо видалити дану категорію");
                          }

                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<int>(
                          value: 1,
                          child: ListTile(
                            leading: Icon(Icons.add),
                            title: Text('Додати'),
                          ),
                        ),
                        const PopupMenuItem<int>(
                          value: 2,
                          child: ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Видалити'),
                          ),
                        ),
                      ],
                    ),
                  
                  ],
                ),
                getSpCards(),
                SizedBox(height: 130),

              ],
            ),
          ),
        ),
      ),
    );
  }

}
