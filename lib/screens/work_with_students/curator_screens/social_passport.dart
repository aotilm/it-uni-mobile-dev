import 'package:flutter/material.dart';
import 'package:accordion/accordion.dart';
import '../../../theme_data.dart';
import '../cards/card_widget.dart';
import '../edit_form.dart';


class SocialPassport extends StatefulWidget {
  const SocialPassport({super.key, required this.group});
  final String group;

  @override
  State<SocialPassport> createState() => _SocialPassportState();
}

class _SocialPassportState extends State<SocialPassport> {
  static const headerStyle = TextStyle(
      color: Color(0xffffffff), fontSize: 18, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    selectCategoriesNames();
    _loadCards();
  }

  List<Map<String, dynamic>> spCategories = [];
  String selectedCategory = EditForm.invalidCategory;
  Map<String, dynamic>? selectedCategoryMap;

  List<CardWidget> spDefaultCards = [];
  List<CardWidget> spManyCards = [];
  List<CardWidget> spInvalidCards = [];
  List<CardWidget> spChornobylCards = [];
  bool isLoading = true;
  String? errorMessage;

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

  Future<void> selectCategoriesNames() async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    List<Map<String, dynamic>> fetchedCategories = await connHandler.selectSpCategoryName();

    await connHandler.close();

    setState(() {
      spCategories = fetchedCategories;
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
    // default:
    //   return Text("data");
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

  Future<List<CardWidget>> returnSpDefaultCard() async { //
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    // Get the records
    List<Map<String, dynamic>> records = await connHandler.selectSpDefaultByGroup(widget.group, selectedCategory!);
    List<CardWidget> testCards = [];

    for (var record in records) {
      final card = CardWidget(
        id: record['id'].toString(),
        firstName: record['first_name'] ?? '',
        lastName: record['second_name']  ?? '',
        middleName: record['middle_name'] ?? '',
        objects: [
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
    List<Map<String, dynamic>> records = await connHandler.selectSpManyChildrenByGroup(widget.group);
    List<CardWidget> testCards = [];

    for (var record in records) {
      final card = CardWidget(
        id: record['id'].toString(),
        firstName: record['first_name'] ?? '',
        lastName: record['second_name']  ?? '',
        middleName: record['middle_name']  ?? '',
        objects: [
          {'Категорія': record['category'] ?? ''},
          {'Дата початку': record['start_date'] ?? ''},
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
    List<Map<String, dynamic>> records = await connHandler.selectSpInvalidPeopleByGroup(widget.group); //
    List<CardWidget> testCards = [];

    for (var record in records) {
      final card = CardWidget(
        id: record['id'].toString(),
        firstName: record['first_name']  ?? '',
        lastName: record['second_name']  ?? '',
        middleName: record['middle_name'] ?? '',
        objects: [
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
    List<Map<String, dynamic>> records = await connHandler.selectSpChornobyltsiByGroup(widget.group); //
    List<CardWidget> testCards = [];

    for (var record in records) {
      final card = CardWidget(
        id: record['id'].toString(),
        firstName: record['first_name']  ?? '',
        lastName: record['second_name']  ?? '',
        middleName: record['middle_name']  ?? '',
        objects: [
          {'Категорія': record['category'] ?? ''},
          {'Група чорнобильця': record['group'] ?? ''},
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: AppTheme.getResponsiveWidthContent(context),
        child: Accordion(
            disableScrolling: true,
            scaleWhenAnimating: false,
            children: [
              AccordionSection(
                  isOpen: true,
                  contentVerticalPadding: 0,
                  contentHorizontalPadding: 0,
                  headerPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  leftIcon: const Icon(Icons.text_fields_rounded, color: Colors.white),
                  header: const Text('Соціальний паспорт', style: headerStyle),
                  content: Column(
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
                                  width: AppTheme.dropdownMenuWidthSp(context),
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
                        ],
                      ),
                      getSpCards(),
                      SizedBox(height: 10),
                    ],
                  )
              ),
            ]
        ),
      ),
    );
  }
}
