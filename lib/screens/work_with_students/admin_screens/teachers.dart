import 'package:flutter/material.dart';
import '../../../theme_data.dart';
import '../cards/teacher_card.dart';
import '../edit_form.dart';

class Teachers extends StatefulWidget {
  const Teachers({super.key});

  @override
  State<Teachers> createState() => _TeachersState();
}

class _TeachersState extends State<Teachers> {

  List<TeacherCard> teacherCards = [];
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
      List<TeacherCard> cards = await returnTeacherCards();
      setState(() {
        teacherCards = cards;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }
  
  Future<List<TeacherCard>> returnTeacherCards() async { //
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();


    List<Map<String, dynamic>> records = await connHandler.selectCurators(); //
    List<TeacherCard> dataCards = [];//

    for (var record in records) {
      final card = TeacherCard(//
          id: int.parse(record['id'].toString()),
          curatorsGroup: record['group'].toString(),
          firstName: record['first_name'].toString(),
          lastName: record['second_name'].toString(),
          middleName: record['middle_name'].toString(),
          email: record['email'].toString(),
          onTap: () async{
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditForm(
                  id: int.parse(record['id'].toString()),
                  selectedValue: "Додавання куратора",
                  action: true,
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
                return deleteTeacher(int.parse(record['id'].toString()));
              },
            );
            if(res != null){
              setState(() {_loadCards();});
            }
          }
      );

      dataCards.add(card);
    }

    await connHandler.close(); 
    return dataCards; 
  }

  Widget deleteTeacher(int id) {
    return AlertDialog(
      title: const Text('Видалення запису'),
      content: Text('Ви дійсно хочете видалити запис?'),
      actions: <Widget>[
        TextButton(
          onPressed: () async{
            try{
              final connHandler = MySqlConnectionHandler();
              await connHandler.connect();
              await connHandler.removeRow('curators', id);
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

  void messageBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Theme.of(context).primaryColor, content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: AppTheme.fABPosition(context),
      floatingActionButton: FloatingActionButton.extended(
          label: Text("Додати куратора"),
          icon: Icon(Icons.add),
          onPressed: () async{
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditForm(
                  id: 0,
                  selectedValue: "Додавання куратора",
                  action: false,
                ),
              ),
            );
            if(result != null){
              setState(() {_loadCards();});
            }
          }
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: AppTheme.getResponsiveWidthContent(context),
            child: Column(
                    children: [
                      SizedBox(height: 25),
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (errorMessage != null)
                        Center(child: Text("Виникла помилка"))
                      else if (teacherCards.isEmpty)
                          const Center(child: Text(''))
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: teacherCards.length,
                            itemBuilder: (context, index) {
                              return teacherCards[index].returnTeacherCard(context);
                            },
                          ),
                      SizedBox(height: 130)
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
