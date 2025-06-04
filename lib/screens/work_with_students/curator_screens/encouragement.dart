import 'package:flutter/material.dart';
import 'package:accordion/accordion.dart';
import '../../../theme_data.dart';
import '../cards/card_widget.dart';
import '../edit_form.dart';


class Encouragement extends StatefulWidget {
  const Encouragement({super.key, required this.group});
  final String group;
  @override
  State<Encouragement> createState() => _EncouragementState();
}

class _EncouragementState extends State<Encouragement> {
  static const headerStyle = TextStyle(
      color: Color(0xffffffff), fontSize: 18, fontWeight: FontWeight.bold);

  List<CardWidget> engolCard = [];
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
      List<CardWidget> cardsEngo = await returnEncuragementCards();

      setState(() {
        engolCard = cardsEngo;
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

  Widget deleteRow(int id) {
    return AlertDialog(
      title: const Text('Видалення запису'),
      content: Text('Ви дійсно хочете видалити запис?'),
      actions: <Widget>[
        TextButton(
          onPressed: () async{
            try{
              final connHandler = MySqlConnectionHandler();
              await connHandler.connect();
              await connHandler.removeRow('encouragement', id);
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

  Future<List<CardWidget>> returnEncuragementCards() async { //
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    List<Map<String, dynamic>> records = await connHandler.selectEncouragement(widget.group);
    List<CardWidget> testCards = [];

    for (var record in records) {
      final card = CardWidget(
        id: record['id'].toString(),
        firstName: record['first_name'] ?? '',
        lastName: record['second_name'] ?? '',
        middleName: record['middle_name'] ?? '',
        objects: [
          {'Семестр №': record['session'] ?? ''},
          {'Дата': record['date'] ?? ''},
          {'Зміст': record['content'] ?? ''},
        ],
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditForm(
                id: int.parse(record['id'].toString()),
                selectedValue: "Заохочення",
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
                return deleteRow(int.parse(record['id'].toString()));
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
                  header: const Text('Заохочення', style: headerStyle),
                  content: Column(
                    children: [
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (errorMessage != null)
                        const Center(child: Text("Виникла помилка"))
                      else if (engolCard.isEmpty)
                          const Center(child: Text(''))
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: engolCard.length,
                            itemBuilder: (context, index) {
                              return engolCard[index].returnCard(context);
                            },
                          ),
                      SizedBox(height: 10,)
                    ],
                  )
              ),
            ]
        ),
      ),
    );
  }
}
