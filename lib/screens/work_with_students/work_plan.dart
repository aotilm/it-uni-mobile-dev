import 'dart:developer';
import 'package:flutter/material.dart';
import '../../theme_data.dart';
import 'cards/work_plan_card.dart';
import 'edit_form.dart';

class WorkPlan extends StatefulWidget {
  const WorkPlan({super.key, required this.isAdmin, required this.wpUser});
  final bool isAdmin;
  final String wpUser;
  @override
  State<WorkPlan> createState() => _WorkPlanState();
}

class _WorkPlanState extends State<WorkPlan> {

  List<Map<String, dynamic>> groupNames = [{'group_name': 'Усі'}];
  String? selectedGroup = 'Усі';

  List<WorkPlanCard> wpCards = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    selectGroupNames();
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      isLoading = true;
      List<WorkPlanCard> cards = await returnWorkPlanCards();
      setState(() {
        wpCards = cards;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> selectGroupNames() async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    List<Map<String, dynamic>> fetchedCategories = await connHandler.selectGroups();

    await connHandler.close();

    setState(() {
      groupNames = [{'group_name': 'Усі'}, ...fetchedCategories];
      if(groupNames.isNotEmpty){
        selectedGroup = groupNames.first['group_name'].toString();
      }
    });
  }

  AlertDialog updateWPDoneStatus(int id)  {
    return AlertDialog(
      title: const Text('Підтвердження'),
      content: Text('Ви підтверджуєте виконання заходу?'),
      actions: <Widget>[
        TextButton(
          onPressed: () async{
            try{
              final connHandler = MySqlConnectionHandler();
              await connHandler.connect();
              await connHandler.updateWPDoneStatus(id);
              await connHandler.close();

              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: Theme.of(context).primaryColor, content: Text('Захід було завершено!')),
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

  Future<List<WorkPlanCard>> returnWorkPlanCards() async { //
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();
    List<Map<String, dynamic>> records;
    if(widget.isAdmin){
      // records = await connHandler.selectWorkPlanAdmin();

      switch (selectedGroup){
        case "Усі":
          records = await connHandler.selectWorkPlanAdmin();
        default:
          records = await connHandler.selectWorkPlanAdminByGroup(selectedGroup!);
      }
    }else{
      records = await connHandler.selectWorkPlanCurator(widget.wpUser);
    }

    List<WorkPlanCard> dataCards = [];//

    for (var record in records) {
      final card = WorkPlanCard(//
        id: int.parse(record['id'].toString()),
        session: int.parse(record['session'].toString() ?? ''),
        year: record['year'].toString() ?? '',
        eventName: record['event_name'] ?? '',
        executionDate: record['execution_date'] ?? '',
        executor: record['executor'] ?? '',
        isDone: record['isDone'] == "1",
        adminConfirmation: record['admin_confirmation'] == "1",
        group: record['creator'] ?? '',
        onTap: () async{
          final bool adminConfirmation = record['admin_confirmation'] == "1";
          final result;
          if(!adminConfirmation) {
            result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditForm(
                  id: int.parse(record['id'].toString()),
                  idTable: int.parse(record['id'].toString()),
                  selectedValue: 'План роботи',
                  action: true,
                  isAdmin: widget.isAdmin,
                ),
              ),
            );
          }else{result = null;}
          if (result != null) {
              setState(() {_loadCards();});
          }
        },
        onSwipe: () async{
          switch (widget.wpUser){
            case 'admin':
              final res = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return deleteWP(int.parse(record['id'].toString()));
                },
              );
              if(res != null){
                setState(() {_loadCards();});
              }
            default:
              if(record['creator'] == widget.wpUser){
                final res = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return deleteWP(int.parse(record['id'].toString()));
                  },
                );
                if(res != null){
                  setState(() {_loadCards();});
                }
              }else{messageBar("Ви не можете видаляти записи адміністратора");}
          }
        },
        onLeadingSwipe: () async {
          bool isDone = record['isDone'] == "1";
          if(!isDone){
            final res = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return updateWPDoneStatus(int.parse(record['id'].toString()));
              },
            );
            if(res != null){
              setState(() {_loadCards();});
            }
          } else{
            messageBar('Захід вже виконано!');
          }
        }
      );

      dataCards.add(card);
    }

    await connHandler.close(); // Close the connection
    return dataCards; // Return the list of GeneralDataCard objects
  }

  Widget deleteWP(int id) {
    return AlertDialog(
      title: const Text('Видалення запису'),
      content: Text('Ви дійсно хочете видалити запис?'),
      actions: <Widget>[
        TextButton(
          onPressed: () async{
            try{
              final connHandler = MySqlConnectionHandler();
              await connHandler.connect();
              await connHandler.removeRow('work_plan', id);
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
        label: Text("План роботи"),
        icon: Icon(Icons.add),
        onPressed: () async{
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditForm(
                id: 0,
                selectedValue: 'План роботи',
                action: false,
                wpCreator: widget.wpUser,
                isAdmin: widget.isAdmin,
              ),
            ),
          );
          if(res != null){
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
                if(widget.isAdmin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widget.isAdmin ?
                      DropdownButton<String>(
                        hint: Text("Сортування за групою:"),
                        value: selectedGroup,
                        items: groupNames.map((Map<String, dynamic> item) {
                          return DropdownMenuItem<String>(
                              value: item['group_name'],
                              child: Container(
                                width: AppTheme.dropdownMenuWidthSp(context),
                                // width: MediaQuery.of(context).size.width * 0.65,
                                child: Text(item['group_name']),
                              )
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGroup = newValue!;
                            _loadCards();
                          });
                        },
                      ) : Container(),

                    ],
                  ),
                SizedBox(height: 25),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (errorMessage != null)
                  Center(child: Text("Виникла помилка"))
                else if (wpCards.isEmpty)
                    const Center(child: Text(''))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: wpCards.length,
                      itemBuilder: (context, index) {
                        return wpCards[index].returnWorkPlanCard(context);
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
