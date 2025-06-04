import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:test_journal/theme_data.dart';
import 'package:test_journal/screens/work_with_students/cards/card_widget.dart';
import 'package:test_journal/screens/work_with_students/curator_screens/activity.dart';
import 'package:test_journal/screens/work_with_students/curator_screens/encouragement.dart';
import 'package:test_journal/screens/work_with_students/curator_screens/individual_support.dart';
import 'package:test_journal/screens/work_with_students/curator_screens/social_passport.dart';
import 'package:test_journal/screens/work_with_students/work_plan.dart';

import '../../MySqlConnection.dart';
import 'curator_screens/all_student_info.dart';
import 'curator_screens/general_information.dart';
import 'edit_form.dart';

class CuratorsWorkWithStudents extends StatefulWidget {
  const CuratorsWorkWithStudents({super.key, required this.group, required this.isAdmin});

  final String group;
  final bool isAdmin;

  @override
  State<CuratorsWorkWithStudents> createState() => _CuratorsWorkWithStudentsState();
}

class _CuratorsWorkWithStudentsState extends State<CuratorsWorkWithStudents> {
  int selectedPage = 1 ;
  int currentPageIndex = 0;
  // String group = "2-КТ-21";
  final List<String> pages = ['Загальні відомості', 'Громадська та гурткова діяльність', 'Індивідуальний супровід' ,'Заохочення', 'Соціальний паспорт'];

  List<CardWidget> studentCards = [];
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
      List<CardWidget> cards = await returnCards();
      setState(() {
        studentCards = cards;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }
  
  Widget deleteStudent(int id) {
    return AlertDialog(
      title: const Text('Видалення запису'),
      content: Text('Ви дійсно хочете видалити запис?'),
      actions: <Widget>[
        TextButton(
          onPressed: () async{
            final connHandler = MySqlConnectionHandler();
            await connHandler.connect();
            await connHandler.updateStudentStatus(id);
            await connHandler.close();

            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor: Theme.of(context).primaryColor, content: Text('Студент вибув')),
            );

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

  Future<List<CardWidget>> returnCards() async { //
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    // Get the records
    List<Map<String, dynamic>> records = await connHandler.selectStudentData(widget.group); //
    List<CardWidget> dataCards = [];//
    int recordNumber = 1;
    for (var record in records) {
      bool studentStatus = record['status'] == '1';
      final card = CardWidget(
        id: record['id'].toString(),
        index: recordNumber.toString(),
        firstName: record['first_name'] ?? '',
        lastName: record['second_name'] ?? '',
        middleName: record['middle_name']  ?? '',
        studentStatus: record['status'] == '1',
        onTap: (){
          final res = Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllStudentInfo(
                id: int.parse(record['id'].toString()),
                firstName: record['first_name'] ?? '',
                lastName: record['second_name']  ?? '',
                middleName: record['middle_name']  ?? '',
              ),
            ),
          );
          if(res != null){
            setState(() {_loadCards();});
          }
        },
        onSwipe: () async{
          if(widget.isAdmin ){
            if(!studentStatus){
              final res = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return deleteStudent(int.parse(record['id'].toString()));
                },
              );
              if(res != null){
                setState(() {_loadCards();});
              }
            }else{
              messageBar('Студент уже вибув!');
            }

          }else{
            messageBar('Ви не є адміністратором!');
          }

        },
        onLeadingSwipe: () async{
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditForm(
                id: int.parse(record['id'].toString()),
                group: widget.group,
                selectedValue: "Додавання студента",
                action: true,
              ),
            ),
          );
          // setState(() {returnCards();});

          if(result != null){
            setState(() {_loadCards();});
          }
        }
      );
      recordNumber++;
      dataCards.add(card);
    }

    await connHandler.close();
    return dataCards; 
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("${widget.group} - Робота з студентами",
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),

      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Theme.of(context).primaryColor,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.people, color: Colors.white,),
            icon: Icon(Icons.people),
            label: 'Робота з студентами',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.list_alt, color: Colors.white,),
            icon: Icon(Icons.list_alt),
            label: 'План роботи',
          ),
        ],
      ),
      body:  <Widget>[
        DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people),
                        SizedBox(width: 8),
                        Text("Усі студенти"),
                      ],
                    ),
                  ),

                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people),
                        SizedBox(width: 8),
                        Text("Розширенна"),
                      ],
                    ),
                  )

                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Scaffold(
                      floatingActionButtonLocation: AppTheme.fABPosition(context),
                      floatingActionButton: FloatingActionButton.extended(
                        onPressed: () async{
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditForm(
                                id: 0,
                                group: widget.group,
                                selectedValue: "Додавання студента",
                                action: false,
                              ),
                            ),
                          );
                          if (result != null ) {
                            setState(()  {_loadCards();});
                          }
                        },
                        icon: Icon(Icons.add),
                        label: Text("Додати студента"),
                      ) ,
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
                                else if (studentCards.isEmpty)
                                    const Center(child: Text(''))
                                  else
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: studentCards.length,
                                      itemBuilder: (context, index) {
                                        return studentCards[index].returnCard(context);
                                      },
                                    ),
                                SizedBox(height: 130)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        DropdownButton<String>(
                          hint: Text("Виберіть сторінку:"),
                          value: pages[selectedPage - 1],
                          items: pages.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item, style: TextStyle(fontSize: 16 / MediaQuery.textScaleFactorOf(context)),),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedPage = pages.indexOf(newValue!) + 1;
                            });
                          },
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // SizedBox(height: 25),
                                _getBodyContent(),
                                SizedBox(height: 130)
                              ],
                            ),
                          ),
                        ),
                      ],
                    )


                  ],
                ),
              )

            ],
          ),
        ),
        WorkPlan(isAdmin: widget.isAdmin, wpUser: widget.group,),
      ][currentPageIndex]
    );
  }
  Widget _getBodyContent() {
    switch (selectedPage) {
      case 1:
        return GeneralInformation(group: widget.group,);
      case 2:
        return Activity(group: widget.group,);
      case 3:
        return IndividualEscort(group: widget.group,);
      case 4:
        return Encouragement(group: widget.group,);
      case 5:
        return SocialPassport(group: widget.group,);
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Вітаємо!"),
            Text('Виберіть розділ у меню')
          ],
        );
    }
  }
}
