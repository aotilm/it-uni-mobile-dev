import 'package:flutter/material.dart';
import 'package:accordion/accordion.dart';
import 'package:test_journal/screens/work_with_students/cards/card_widget.dart';
import '../../../theme_data.dart';
import '../edit_form.dart';

class GeneralInformation extends StatefulWidget {
  const GeneralInformation({super.key, required this.group});

  final String group;

  @override
  State<GeneralInformation> createState() => _GeneralInformationState();
}

class _GeneralInformationState extends State<GeneralInformation> {

  static const headerStyle = TextStyle(
      color: Color(0xffffffff), fontSize: 18, fontWeight: FontWeight.bold);

  List<CardWidget> generalCard = [];
  List<CardWidget> eduCard = [];
  List<CardWidget> servCard = [];
  List<CardWidget> jobCard = [];
  List<CardWidget> parentsCard = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      isLoading = true;
      final futures = await Future.wait([
        returnGeneralInfoCards(),
        returnEducationDataCards(),
        returnServiceInArmyCards(),
        returnJobActivityCards(),
        returnParentsInfoCards(),
      ]);

      List<CardWidget> cardsGen = futures[0];
      List<CardWidget> cardsEdu = futures[1];
      List<CardWidget> cardsServ = futures[2];
      List<CardWidget> cardsJob = futures[3];
      List<CardWidget> cardsParents = futures[4];

      setState(() {
        generalCard = cardsGen;
        eduCard = cardsEdu;
        servCard = cardsServ;
        jobCard = cardsJob;
        parentsCard = cardsParents;
        isLoading = false;
      });
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

  Widget deleteRow(int id, String table) {
    return AlertDialog(
      title: const Text('Видалення запису'),
      content: Text('Ви дійсно хочете видалити запис?'),
      actions: <Widget>[
        TextButton(
          onPressed: () async{
            try{
              final connHandler = MySqlConnectionHandler();
              await connHandler.connect();
              switch (table){
                case 'general_info':
                  await connHandler.removeRow('general_info', id);
                  break;
                case 'education_data':
                  await connHandler.removeRow('education_data', id);
                  break;
                case 'service_in_army':
                  await connHandler.removeRow('service_in_army', id);
                  break;
                case 'job_activity':
                  await connHandler.removeRow('job_activity', id);
                  break;
                case 'parents_info':
                  await connHandler.removeRow('parents_info', id);
                  break;
              }

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

  Future<List<CardWidget>> returnGeneralInfoCards() async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    List<Map<String, dynamic>> records = await connHandler.selectGenInfo(widget.group);
    List<CardWidget> testCards = [];

    for (var record in records) {
      final card = CardWidget(
        id: record['id'].toString(),
        firstName: record['first_name'] ?? '',
        lastName: record['second_name'] ?? '',
        middleName: record['middle_name'] ?? '',
        studentStatus: record['status'] == '1',

        objects: [
          {'Дата народження': record['date']?? ''},
          {'Номер телефону': record['phone_number'] ?? ''},
          {'Адреса проживання': record['address'] ?? ''},
        ],
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditForm(
                id: int.parse(record['id'].toString()),
                selectedValue: "Загальні дані",
                action: true,
                studentName: "${record['second_name'] ?? ''} ${record['first_name'][0] ?? ''}. ${record['middle_name'][0] ?? ''}.",
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
              return deleteRow(int.parse(record['id'].toString()), 'general_info');
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
  Future<List<CardWidget>> returnEducationDataCards() async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    List<Map<String, dynamic>> records = await connHandler.selectEduData(widget.group);
    List<CardWidget> testCards = [];

    for (var record in records) {
      final card = CardWidget(
        id: record['id'].toString(),
        firstName: record['first_name'] ?? '',
        lastName: record['second_name'] ?? '',
        middleName: record['middle_name'] ?? '',
        objects: [
          {'Закінчив навчальний заклад': record['institution_name'] ?? ''},
          {'Дата закінчення': record['end_date'] ?? ''},
          {'Середній бал': record['average_score'] ?? ''},
        ],
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditForm(
                id: int.parse(record['id'].toString()),
                selectedValue: "Дані про освіту",
                action: true,
                studentName: "${record['second_name'] ?? ''} ${record['first_name'][0] ?? ''}. ${record['middle_name'][0] ?? ''}.",
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
              return deleteRow(int.parse(record['id'].toString()), 'education_data');
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
  Future<List<CardWidget>> returnServiceInArmyCards() async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    List<Map<String, dynamic>> records = await connHandler.selectServInArmyData(widget.group);
    List<CardWidget> testCards = [];

    for (var record in records) {
      final card = CardWidget(
        id: record['id'].toString(),
        firstName: record['first_name'] ?? '',
        lastName: record['second_name'] ?? '',
        middleName: record['middle_name'] ?? '',
        objects: [
          {'Служба в ЗСУ': ("${record['start_date'] ?? ''}-${record['end_date'] ?? ''} ")},
          {'Підрозділ': record['unit'] ?? ''},
        ],
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditForm(
                id: int.parse(record['id'].toString()),
                selectedValue: "Служба в ЗСУ",
                action: true,
                studentName: "${record['second_name'] ?? ''} ${record['first_name'][0] ?? ''}. ${record['middle_name'][0] ?? ''}.",
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
              return deleteRow(int.parse(record['id'].toString()), 'service_in_army');
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
  Future<List<CardWidget>> returnJobActivityCards() async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    List<Map<String, dynamic>> records = await connHandler.selectJobActivityData(widget.group);
    List<CardWidget> testCards = [];

    for (var record in records) {
      final card = CardWidget(
        id: record['id'].toString(),
        firstName: record['first_name']  ?? '',
        lastName: record['second_name'] ?? '',
        middleName: record['middle_name'] ?? '',
        objects: [
          {'Місце роботи': record['place'] ?? ''},
          {'Посада': record['job_position'] ?? ''},
          {'Дата початку': record['start_date'] ?? ''},
          {'Дата закінчення': record['end_date'] ?? ''}
        ],
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditForm(
                id: int.parse(record['id'].toString()),
                selectedValue: "Трудова діяльність",
                action: true,
                studentName: "${record['second_name'] ?? ''} ${record['first_name'][0] ?? ''}. ${record['middle_name'][0] ?? ''}.",
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
              return deleteRow(int.parse(record['id'].toString()), 'job_activity');
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
  Future<List<CardWidget>> returnParentsInfoCards() async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    List<Map<String, dynamic>> records = await connHandler.selectParentsInfoData(widget.group);
    List<CardWidget> testCards = [];

    for (var record in records) {
      final card = CardWidget(
        id: record['id'].toString(),
        firstName: record['first_name'] ?? '',
        lastName: record['second_name'] ?? '',
        middleName: record['middle_name'] ?? '',
        objects: [
          {'Батько': record['father'] ?? ''},
          {'Моб. тел.': record['fathers_phone'] ?? ''},
          {'Мати': record['mother'] ?? ''},
          {'Моб. тел.': record['mothers_phone'] ?? ''}
        ],
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditForm(
                id: int.parse(record['id'].toString()),
                selectedValue: "Інформація про батьків",
                action: true,
                studentName: "${record['second_name'] ?? ''} ${record['first_name'][0] ?? ''}. ${record['middle_name'][0] ?? ''}.",
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
              return deleteRow(int.parse(record['id'].toString()), 'parents_info');
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
  
  List<bool> sectionOpened = [false, false, false, false, false];

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
                  isOpen: sectionOpened[0],
                  onOpenSection: (){
                    sectionOpened=[true, false, false, false, false];

                  },
                  onCloseSection: (){
                    sectionOpened[0]=false;
                  },
                  contentVerticalPadding: 0,
                  contentHorizontalPadding: 0,
                  headerPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  leftIcon: const Icon(Icons.text_fields_rounded, color: Colors.white),
                  header: const Text('Загальні Дані', style: headerStyle),
                  content: Column(
                    children: [
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (errorMessage != null)
                        const Center(child: Text("Виникла помилка"))
                      else if (generalCard.isEmpty)
                          const Center(child: Text(''))
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: generalCard.length,
                            itemBuilder: (context, index) {
                              return generalCard[index].returnCard(context);
                            },
                          ),
                      const SizedBox(height: 10)
                    ],
                  )



              ),
              AccordionSection(
                // isOpen: true,
                  isOpen: sectionOpened[1],
                  onOpenSection: (){
                    sectionOpened=[false, true, false, false, false];

                  },
                  onCloseSection: (){
                    sectionOpened[1]=false;
                  },
                  contentVerticalPadding: 0,
                  contentHorizontalPadding: 0,
                  headerPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  leftIcon:
                  const Icon(Icons.text_fields_rounded, color: Colors.white),
                  header: const Text('Дані про освіту', style: headerStyle),
                  // content: Text('hello'),
                  content: Column(
                    children: [
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (errorMessage != null)
                        Center(child: Text("Виникла помилка"))
                      else if (eduCard.isEmpty)
                          const Center(child: Text(''))
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: eduCard.length,
                            itemBuilder: (context, index) {
                              return eduCard[index].returnCard(context);
                            },
                          ),
                      SizedBox(height: 10)
                    ],
                  )
              ),
              AccordionSection(
                // isOpen: true,
                  isOpen: sectionOpened[2],
                  onOpenSection: (){
                    sectionOpened=[false, false, true, false, false];

                  },
                  onCloseSection: (){
                    sectionOpened[2]=false;
                  },
                  contentVerticalPadding: 0,
                  contentHorizontalPadding: 0,
                  headerPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  leftIcon:
                  const Icon(Icons.text_fields_rounded, color: Colors.white),
                  header: const Text('Служба в ЗСУ', style: headerStyle),
                  content: Column(
                    children: [
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (errorMessage != null)
                        Center(child: Text("Виникла помилка"))
                      else if (servCard.isEmpty)
                          const Center(child: Text(''))
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: servCard.length,
                            itemBuilder: (context, index) {
                              return servCard[index].returnCard(context);
                            },
                          ),
                      SizedBox(height: 10)
                    ],
                  )
              ),
              AccordionSection(
                // isOpen: true,
                  isOpen: sectionOpened[3],
                  onOpenSection: (){
                    sectionOpened=[false, false, false, true, false];

                  },
                  onCloseSection: (){
                    sectionOpened[3]=false;
                  },
                  contentVerticalPadding: 0,
                  contentHorizontalPadding: 0,
                  headerPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  leftIcon:
                  const Icon(Icons.text_fields_rounded, color: Colors.white),
                  header: const Text('Трудова діяльність', style: headerStyle),
                  content: Column(
                    children: [
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (errorMessage != null)
                        Center(child: Text("Виникла помилка"))
                      else if (jobCard.isEmpty)
                          const Center(child: Text(''))
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: jobCard.length,
                            itemBuilder: (context, index) {
                              return jobCard[index].returnCard(context);
                            },
                          ),
                      SizedBox(height: 10)
                    ],
                  )
              ),
              AccordionSection(
                // isOpen: true,
                  isOpen: sectionOpened[4],
                  onOpenSection: (){
                    sectionOpened=[false, false, false, false, true];

                  },
                  onCloseSection: (){
                    sectionOpened[4]=false;
                  },
                  contentVerticalPadding: 0,
                  contentHorizontalPadding: 0,
                  headerPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  leftIcon:
                  const Icon(Icons.text_fields_rounded, color: Colors.white),
                  header: const Text('Інформація про батьків', style: headerStyle),
                  content: Column(
                    children: [
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (errorMessage != null)
                        Center(child: Text("Виникла помилка"))
                      else if (parentsCard.isEmpty)
                          const Center(child: Text(''))
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: parentsCard.length,
                            itemBuilder: (context, index) {
                              return parentsCard[index].returnCard(context);
                            },
                          ),
                      SizedBox(height: 10)
                    ],
                  )
              )
            ]
        ),
      ),
    );


  }
}


