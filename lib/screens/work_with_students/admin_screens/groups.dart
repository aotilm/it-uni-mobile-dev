import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:test_journal/screens/work_with_students/cards/groups_card.dart';
import '../../../theme_data.dart';
import '../curators_work_with_students.dart';
import '../edit_form.dart';
import 'model/student.dart';


class Groups extends StatefulWidget {
  const Groups({super.key, required this.isAdmin});
  final bool isAdmin;
  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  List<GroupsCard> groupCards = [];
  List<GroupsCard> groupGradCards = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGroupCards();
  }

  Future<void> _loadGroupCards() async {
    try {
      isLoading = true;
      List<GroupsCard> cards = await returnCards(false);
      List<GroupsCard> cards1 = await returnCards(true);
      setState(() {
        groupCards = cards;
        groupGradCards = cards1;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<List<Student>> getExcelStudentData() async {
    List<Student> studentsList = [];


    var bytes = await rootBundle.load('assets/student.xlsx');
    var excel = Excel.decodeBytes(bytes.buffer.asUint8List());

    var firstSheetKey = excel.tables.keys.first;
    var sheet = excel.tables[firstSheetKey]!;
    for (var row in sheet.rows.skip(1)) {
      if (row.every((cell) => cell == null || cell.value == null || cell.value.toString().trim().isEmpty)) {
        continue;
      }

      var firstName = row[0]?.value;
      var lastName = row[1]?.value;
      var middleName = row[2]?.value;
      var group = row[3]?.value;
      var student = Student(firstName: firstName.toString(), secondName: lastName.toString(), middleName: middleName.toString(), group: group.toString());
      studentsList.add(student);
      // print('$i Імя: $column1, Прізвище: $column2, По батькові: $column3, Група: $column4');
    }
    log('Читання завершено');
    return studentsList;
  }

  Widget archiveGroup(int id) {
    return AlertDialog(
      title: const Text('Архівування'),
      content: Text('Ви дійсно хочете архівувати групу? Архівування означатиме, що група була випущенна'),
      actions: <Widget>[
        TextButton(
          onPressed: () async{
            try{
              final connHandler = MySqlConnectionHandler();
              await connHandler.connect();
              await connHandler.updateGroupStatus(id);
              await connHandler.close();

              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: Theme.of(context).primaryColor, content: Text('Групу перенесено до архіву!')),
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

  Future<List<GroupsCard>> returnCards(isGrad) async { //
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    // Get the records
    List<Map<String, dynamic>> records = await connHandler.selectGroupsMain(isGrad); //
    List<GroupsCard> dataCards = [];//

    for (var record in records) {
      final bool isGrad = record['isGrad'] == '1';
      final card = GroupsCard(
        id: 0,
        groupName: record['group'] ?? 'No',
        curator: record['curators'] ?? 'No',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CuratorsWorkWithStudents(
                  group: record['group'],
                  isAdmin: widget.isAdmin,
                )
            ),
          );
        },
        onSwipe:  () async{
          if(!isGrad){
            final res = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return archiveGroup(int.parse(record['id'].toString()));
              },
            );
            if(res != null){
              setState(() {_loadGroupCards();});
            }
          } else{messageBar('Група вже в архіві!');}

        }
      );

      dataCards.add(card);
    }

    await connHandler.close();
    return dataCards; 
  }

  final GlobalKey<State> _key = GlobalKey<State>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: DefaultTabController(
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
                      Text("Групи"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.archive),
                      SizedBox(width: 8),
                      Text("Архів"),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Scaffold(
                    resizeToAvoidBottomInset: true,
                    floatingActionButtonLocation: AppTheme.fABPosition(context),
                    floatingActionButton: FloatingActionButton.extended(
                      label: Text('Створити групу'),
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditForm(
                              id: 0,
                              selectedValue: "Додавання групи",
                              action: false,
                            ),
                          ),
                        );

                        if (result != null) {
                          setState(() {_loadGroupCards();});
                        }
                      },
                    ),
                    body: SingleChildScrollView(
                      child: Center(
                        child: SizedBox(
                          width: AppTheme.getResponsiveWidthContent(context),
                          child: Column(
                            children: [
                              const SizedBox(height: 25),

                              if (isLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (errorMessage != null)
                                Center(child: Text("Виникла помилка"))
                              else if (groupCards.isEmpty)
                                  const Center(child: Text(''))
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: groupCards.length,
                                  itemBuilder: (context, index) {
                                    return groupCards[index].returnGroupCard(context);
                                  },
                                ),

                              const SizedBox(height: 130),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Scaffold(
                    resizeToAvoidBottomInset: true,
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
                                Center(child: Text(errorMessage!))
                              else if (groupGradCards.isEmpty)
                                  const Center(child: Text(''))
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: groupGradCards.length,
                                    itemBuilder: (context, index) {
                                      return groupGradCards[index].returnGroupCard(context);
                                    },
                                  ),

                              const SizedBox(height: 130)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }
}
