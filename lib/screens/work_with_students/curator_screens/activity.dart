import 'package:flutter/material.dart';
import 'package:accordion/accordion.dart';
import '../../../theme_data.dart';
import '../cards/card_widget.dart';
import '../edit_form.dart';
class Activity extends StatefulWidget {
  const Activity({super.key, required this.group});

  final String group;

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  static const headerStyle = TextStyle(
      color: Color(0xffffffff), fontSize: 18, fontWeight: FontWeight.bold);

  List<CardWidget> socialCard = [];
  List<CardWidget> circleCard = [];

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
      List<CardWidget> cardsSocial = await returnSocialActivityCards();
      List<CardWidget> cardCircle = await returnCircleActivityCards();
   
      setState(() {
        socialCard = cardsSocial;
        circleCard = cardCircle;
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
                case 'social_activity':
                  await connHandler.removeRow('social_activity', id);
                  break;
                case 'circle_activity':
                  await connHandler.removeRow('circle_activity', id);
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

  Future<List<CardWidget>> returnSocialActivityCards() async { //
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    List<Map<String, dynamic>> records = await connHandler.selectSocialActivity(widget.group);
    List<CardWidget> testCards = [];

    for (var record in records) {
      final card = CardWidget(
        id: record['id'].toString(),
        firstName: record['first_name'] ?? '',
        lastName: record['second_name']  ?? '',
        middleName: record['middle_name'] ?? '',
        objects: [
          {'Семестр №': record['session'] ?? ''},
          {'Дата': record['date'] ?? ''},
          {'Діяльність': record['activity'] ?? ''},
        ],
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditForm(
                id: int.parse(record['id'].toString()),
                selectedValue: "Громадська діяльність",
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
                return deleteRow(int.parse(record['id'].toString()), 'social_activity');
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
  Future<List<CardWidget>> returnCircleActivityCards() async { //
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    List<Map<String, dynamic>> records = await connHandler.selectCircleActivity(widget.group);
    List<CardWidget> testCards = [];

    for (var record in records) {
      final card = CardWidget(
        id: record['id'].toString(),
        firstName: record['first_name'] ?? '',
        lastName: record['second_name'] ?? '',
        middleName: record['middle_name'] ?? '',
        objects: [
          {'Семестр №': record['session'] ?? ''},
          {'Назва гуртка': record['circle_name'] ?? ''},
          {'Нотатка': record['note'] ?? ''},
        ],
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditForm(
                id: int.parse(record['id'].toString()),
                selectedValue: "Гурткова діяльність",
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
                return deleteRow(int.parse(record['id'].toString()), 'circle_activity');
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

  List<bool> sectionOpened = [false, false];

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
                  sectionOpened=[true, false];


                },
                onCloseSection: (){
                  sectionOpened[0]=false;
                },
                contentVerticalPadding: 0,
                contentHorizontalPadding: 0,
                headerPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                leftIcon: const Icon(Icons.text_fields_rounded, color: Colors.white),
                header: const Text('Громадська діяльність', style: headerStyle),
                content: Column(
                  children: [
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (errorMessage != null)
                      const Center(child: Text("Виникла помилка"))
                    else if (socialCard.isEmpty)
                        const Center(child: Text(''))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: socialCard.length,
                          itemBuilder: (context, index) {
                            return socialCard[index].returnCard(context);
                          },
                        ),
                    SizedBox(height: 10)
                  ],
                ),
              ),
              AccordionSection(
                // isOpen: true,
                isOpen: sectionOpened[1],
                onOpenSection: (){
                  sectionOpened=[false, true];

                },
                onCloseSection: (){
                  sectionOpened[1]=false;
                },
                contentVerticalPadding: 0,
                contentHorizontalPadding: 0,
                headerPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                leftIcon:
                const Icon(Icons.text_fields_rounded, color: Colors.white),
                header: const Text('Гурткова діяльність', style: headerStyle),
                // content: Text('hello'),
                content: Column(
                  children: [
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (errorMessage != null)
                      const Center(child: Text("Виникла помилка"))
                    else if (circleCard.isEmpty)
                        const Center(child: Text(''))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: circleCard.length,
                          itemBuilder: (context, index) {
                            return circleCard[index].returnCard(context);
                          },
                        ),
                    SizedBox(height: 10,)
                  ],
                ),
              ),
            ]
        ),
      ),
    );
  }
}
