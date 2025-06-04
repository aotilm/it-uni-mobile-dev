import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../MySqlConnection.dart';
import '../../theme_data.dart';
import './enums/form_types.dart';

class EditForm extends StatefulWidget {
  EditForm({
    required this.id,
    this.idTable,
    required this.selectedValue,
    this.action,
    this.isAdmin,
    this.group,
    this.wpCreator,
    this.spCategory,
    this.showSpDropDown,
    this.studentName
  });

  final String? studentName;
  final int id;
  final int? idTable;
  String selectedValue;
  final bool? action;
  final bool? isAdmin;
  final String? group;
  final String? wpCreator;
  final String? spCategory;
  final bool? showSpDropDown;
  static const String manyChildrenCategory = "Студенти з багатодітних родин";
  static const String invalidCategory = "Студенти-інваліди";
  static const String chornobylCategory = "Студенти-чорнобильці";

  @override
  EditFormState createState() => EditFormState();
}

class EditFormState extends State<EditForm> {
  // String? selectedValue;

  @override
  void initState() {
    super.initState();
    widget.action! ? returnFormFields() : print('дані в поля форми не підтягуються');
    if(widget.selectedValue == "Соціальний паспорт"){
      selectCategoriesNames();
    }
    if(widget.selectedValue == "Додавання куратора"){
      selectGroupNames();
    }
  }

  DateTime? selectedDate1;
  DateTime? selectedDate2;

  bool isDone = false;
  bool adminConfirmation = false;



  final formKey = GlobalKey<FormState>();

 

  List<Map<String, dynamic>> spCategories = [];
  String? selectedCategory;
  Map<String, dynamic>? selectedCategoryMap;

  List<Map<String, dynamic>> groupNames = [];
  String? selectedGroup;
  Map<String, dynamic>? selectedGroupMap;



  Row buttonRow() {
    return Row(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: isDisabled,
          builder: (context, value, child) {
            return Row(
              children: [
                Icon(value ? Icons.hourglass_empty : Icons.save),
                SizedBox(width: 5),
                Text(value ? 'Зачекайте...' : 'Зберегти'),
              ],
            );
          },
        ),
        // Icon(Icons.save),
        // SizedBox(width: 5),
        // Text('Зберегти'),
      ],
    );
  }
  Future<void> formFunc(Future<void> Function() onTap) async {
    if(!isDisabled.value){
      isDisabled.value = true;

      try{
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          await onTap();
          messageBar('Інформацію оновлено у базі даних!');
          Navigator.pop(context, true);
          isDisabled.value = false;

        }
      } on SocketException catch (e) {
        messageBar('Перевірте з\'єднання з інтернетом!');
        return;
      } catch(e){
        print('$e');
        messageBar('Вибачте, виникла помилка');
      }finally {
        isDisabled.value = false; // Завжди скидаємо стан кнопки
      }
    }else{
      print('cant login');
    }
  }
  final ValueNotifier<bool> isDisabled = ValueNotifier<bool>(false);


  void messageBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Theme.of(context).primaryColor, content: Text(message)),
    );
  }

  Future<DateTime?> selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (date != null) {
      setState(() {
        selectedDate1 = date;
        fieldController1.text = '${selectedDate1!.year}-${selectedDate1!.month}-${selectedDate1!.day}';
      });
    }
    return selectedDate1;
  }

  Future<void> selectDate2() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (date != null) {
      setState(() {
        selectedDate2 = date;
        fieldController2.text = '${selectedDate2!.year}-${selectedDate2!.month}-${selectedDate2!.day}';
      });
    }
  }

  Widget getGenInfoForm(){
    return Form(
      key: formKey,
      child: Column(
        children: [

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController1,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.date_range),
                    labelText: 'Дата народження',
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть дату';
                    }
                    return null;
                  },
                  onTap: () {
                    selectDate();
                  },
                  onSaved: (value) {
                    fieldController1.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController2,
                  maxLines: 1,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\+?\d*$')),
                    LengthLimitingTextInputFormatter(13)
                  ],
                  decoration: const InputDecoration(
                    icon: Icon(Icons.phone),
                    labelText: 'Номер телефону',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть номер телефону';
                    }

                    if (value.startsWith('+')) {
                      if (value.length < 10 || value.length > 15) {
                        return 'Невірно введено номер';
                      }
                    } else {
                      if (value.length < 10 || value.length > 10) {
                        return 'Невірно введено номер';
                      }
                    }

                    return null;
                  },
                  onSaved: (value) {
                    fieldController2.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController3,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Адреса',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть адресу';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController4.text = value!;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () async {
                  await formFunc(() async{
                    await updateGenInfo(fieldController2.text, fieldController1.text, fieldController3.text, widget.action!);
                  });
                },
                child: buttonRow(),
              ),
            ],
          )
        ],
      ),
    );
  }
  Future<void> updateGenInfo(String phone_number, String date, String address, bool doUpdate) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();
    doUpdate ?
    await connHandler.updateGenInfo(widget.id, phone_number, date, address) :
    await connHandler.insertGenInfo(phone_number, date, address, false, widget.id);

    await connHandler.close();
  }

  Widget getEduDataForm(){
    return Form(
      key: formKey,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController1,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.date_range),
                    labelText: 'Дата закінчення',
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть дату';
                    }
                    return null;
                  },
                  onTap: () {
                    selectDate();
                  },
                  onSaved: (value) {
                    fieldController1.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController2,
                  maxLines: null,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // Дозволяє лише числа і крапку
                  ],
                  decoration: const InputDecoration(
                    icon: Icon(Icons.score),
                    labelText: 'Середній бал',
                  ),
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Введіть середній бал';
                  //   }
                  //   return null;
                  // },
                  onSaved: (value) {
                    fieldController2.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController3,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.school),
                    labelText: 'Назва закладу',
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80)
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть заклад';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController3.text = value!;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () async {
                  await formFunc(() async{
                    await updateEduData(fieldController3.text, fieldController1.text, fieldController2.text, widget.action!);
                  });
                },
                child: buttonRow(),
              ),
            ],
          )
        ],
      ),
    );
  }
  Future<void> updateEduData(String institutionName, String endDate, String averageScore, bool doUpdate) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    doUpdate ?
    await connHandler.updateEduData(widget.id, institutionName, endDate, averageScore) :
    await connHandler.insertEduDate(endDate, institutionName, averageScore, widget.id);

    await connHandler.close();
  }

  Widget getArmyServForm(){
    return Form(
      key: formKey,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController1,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.date_range),
                    labelText: 'Дата початку',
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть дату';
                    }
                    return null;
                  },
                  onTap: () {
                    selectDate();
                  },
                  onSaved: (value) {
                    fieldController1.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController2,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.date_range),
                    labelText: 'Дата закінчення',
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть дату';
                    }
                    return null;
                  },
                  onTap: () {
                    selectDate2();
                  },
                  onSaved: (value) {
                    fieldController2.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController3,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.military_tech),
                    labelText: 'Підрозділ',
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть підрозділ';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController3.text = value!;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () async {
                  await formFunc(() async{
                    await updateArmyServ(fieldController3.text, fieldController2.text, fieldController1.text, widget.action!); // Додаємо await, щоб переконатися, що оновлення завершується до показу діалогу
                  });
                },
                child: buttonRow(),
              ),
            ],
          )
        ],
      ),
    );
  }
  Future<void> updateArmyServ(String unit, String endDate, String startDate, bool doUpdate) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    doUpdate ?
    await connHandler.updateArmyServ(widget.id, startDate, endDate, unit):
    await connHandler.insertArmyServ(endDate, startDate, unit, widget.id);

    await connHandler.close();
  }

  Widget getJobActivityForm(){
    return Form(
      key: formKey,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9, // 30% of screen width
                child: TextFormField(
                  controller: fieldController1,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.date_range),
                    labelText: 'Дата початку',
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть дату';
                    }
                    return null;
                  },
                  onTap: () {
                    selectDate();
                  },
                  onSaved: (value) {
                    fieldController1.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9, // 30% of screen width
                child: TextFormField(
                  controller: fieldController2,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.date_range),
                    labelText: 'Дата закінчення',
                  ),
                  readOnly: true,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Введіть дату';
                  //   }
                  //   return null;
                  // },
                  onTap: () {
                    selectDate2();
                  },
                  onSaved: (value) {
                    fieldController2.text = value!;
                    // log(fieldController2.text);
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController3,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.work),
                    labelText: 'Місце роботи',
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80)
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть місце роботи';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController3.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController4,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.work),
                    labelText: 'Посада',
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80)
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть посаду';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController4.text = value!;
                  },
                ),
              ),

            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () async {
                  await formFunc(() async{
                    await updateJobActivity(fieldController1.text, fieldController2.text, fieldController3.text,
                        fieldController4.text, fieldController5.text, widget.action!);
                  });
                },
                child: buttonRow(),
              ),
            ],
          )
        ],
      ),
    );
  }
  Future<void> updateJobActivity(String startDate, String endDate, String place, String jobPosition, String phoneNumber, bool doUpdate) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    doUpdate ?
    await connHandler.updateJobActivity(widget.id, startDate, endDate, place, jobPosition, phoneNumber):
    await connHandler.insertJobActivity(widget.id, startDate, endDate, place, jobPosition, phoneNumber);

    await connHandler.close();
  }

  Widget getParentsInfoForm(){
    return Form(
      key: formKey,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController1,
                  maxLines: null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80)
                  ],
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Батько',
                  ),
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Введіть ПІБ батька';
                  //   }
                  //   return null;
                  // },
                  onSaved: (value) {
                    fieldController1.text = value!;
                  },
                ),
              ),

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController2,
                  maxLines: 1,
                  keyboardType: TextInputType.phone,

                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\+?\d*$')), // Дозволяє тільки цифри і +
                    LengthLimitingTextInputFormatter(13)
                  ],
                  decoration: const InputDecoration(
                    icon: Icon(Icons.phone),
                    labelText: 'Телефон батька',
                  ),
                  validator: (value) {
                    // if (value == null || value.isEmpty) {
                    //   return 'Введіть номер телефону';
                    // }

                    if(value != null && value.isNotEmpty){
                      if (value.startsWith('+')) {
                        if (value.length < 10 || value.length > 15) {
                          return 'Невірно введено номер';
                        }
                      } else {
                        if (value.length < 10 || value.length > 10) {
                          return 'Невірно введено номер';
                        }
                      }

                      return null;
                    }
                  },
                  onSaved: (value) {
                    fieldController2.text = value!;
                  },
                ),
              ),

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController3,
                  maxLines: null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80)
                  ],
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Матір',
                  ),
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Введіть ПІБ матері';
                  //   }
                  //   return null;
                  // },
                  onSaved: (value) {
                    fieldController3.text = value!;
                  },
                ),
              ),

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController4,
                  maxLines: 1,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\+?\d*$')), // Дозволяє тільки цифри і +
                    LengthLimitingTextInputFormatter(13)
                  ],
                  decoration: const InputDecoration(
                    icon: Icon(Icons.phone),
                    labelText: 'Телефон матері',
                  ),
                  validator: (value) {
                    if(value != null && value.isNotEmpty){
                      if (value.startsWith('+')) {
                        if (value.length < 10 || value.length > 15) {
                          return 'Невірно введено номер';
                        }
                      } else {
                        if (value.length < 10 || value.length > 10) {
                          return 'Невірно введено номер';
                        }
                      }

                      return null;
                    }
                  },
                  onSaved: (value) {
                    fieldController4.text = value!;
                  },
                ),
              ),

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController5,
                  maxLines: null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80)
                  ],
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Примітка',
                  ),
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Введіть телефон матері';
                  //   }
                  //   return null;
                  // },
                  onSaved: (value) {
                    fieldController5.text = value!;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () async {
                  if(fieldController1.text.isEmpty && fieldController3.text.isEmpty){
                    messageBar("Введіть одного з батьків!");
                  }else{
                    await formFunc(() async{
                      await updateParentsInfo(
                          fieldController1.text,
                          fieldController2.text,
                          fieldController3.text,
                          fieldController4.text,
                          fieldController5.text,
                          widget.action!
                      );
                    });
                  }
                },

                child: buttonRow(),
              ),
            ],
          )
        ],
      ),
    );
  }
  Future<void> updateParentsInfo(String father, String fathersPhone, String mother, String mothersPhone, String note, bool doUpdate) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    doUpdate?
    await connHandler.updateParentsInfo(widget.id, father, fathersPhone, mother, mothersPhone, note):
    await connHandler.insertParentsInfo(widget.id, father, fathersPhone, mother, mothersPhone, note);

    await connHandler.close();
  }

  Widget getSocialActivityForm(){
    return Form(
      key: formKey,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController1,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Семестр',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть семестр';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController1.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController2,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.date_range),
                    labelText: 'Дата',
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть дату';
                    }
                    return null;
                  },
                  onTap: () {
                    selectDate2();
                  },
                  onSaved: (value) {
                    fieldController2.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController3,
                  maxLines: null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80)
                  ],
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Діяльність',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть діяльність';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController3.text = value!;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () async {
                  await formFunc(() async{
                    await updateSocialActivity(int.parse(fieldController1.text), fieldController2.text, fieldController3.text, widget.action!);
                  });
                },
                child: buttonRow(),
              ),
            ],
          )
        ],
      ),
    );
  }
  Future<void> updateSocialActivity(int session, String date, String activity, bool doUpdate) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    doUpdate ?
    await connHandler.updateSocialActivity(widget.id, session, date, activity) :
    await connHandler.insertSocialActivity(widget.id, session, date, activity);

    await connHandler.close();
    // Navigator.pop(context);
  }

  Widget getCircleActivityForm(){
    return Form(
      key: formKey,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController1,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Семестр',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть семестр';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController1.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController2,
                  maxLines: null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80)
                  ],
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Гурток',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть гурток';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController2.text = value!;
                  },
                ),
              ),

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController3,
                  maxLines: null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80)
                  ],
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Нотатка',
                  ),
                  onSaved: (value) {
                    fieldController3.text = value!;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () async {
                  await formFunc(() async{
                    await updateCircleActivity(int.parse(fieldController1.text), fieldController2.text, fieldController3.text, widget.action!);
                  });
                },
                child: buttonRow(),
              ),
            ],
          )
        ],
      ),
    );
  }
  Future<void> updateCircleActivity(int session, String circleName, String note, bool doUpdate) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    doUpdate ?
    await connHandler.updateCircleActivity(widget.id, session, circleName, note) :
    await connHandler.insertCircleActivity(widget.id, session, circleName, note);

    await connHandler.close();
  }

  Widget getIndividualEscortForm(){
    return Form(
      key: formKey,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController1,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Семестр',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть семестр';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController1.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController2,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.date_range),
                    labelText: 'Дата',
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть дату';
                    }
                    return null;
                  },
                  onTap: () {
                    selectDate2();
                  },
                  onSaved: (value) {
                    fieldController2.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController3,
                  maxLines: null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80)
                  ],
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Зміст',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть зміст';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController3.text = value!;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () async {
                  await formFunc(() async{
                    await updateIndividualEscort(int.parse(fieldController1.text), fieldController2.text, fieldController3.text, widget.action!);
                  });
                },
                child: buttonRow(),
              ),
            ],
          )
        ],
      ),
    );
  }
  Future<void> updateIndividualEscort(int session, String date, String content, doUpdate) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    doUpdate ?
    await connHandler.updateIndividualEscort(widget.id, session, date, content) :
    await connHandler.insertIndividualEscort(widget.id, session, date, content);

    await connHandler.close();
  }

  Widget getEncouragementForm(){
    return Form(
      key: formKey,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController1,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Семестр',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть семестр';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController1.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController2,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.date_range),
                    labelText: 'Дата',
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть дату';
                    }
                    return null;
                  },
                  onTap: () {
                    selectDate2();
                  },
                  onSaved: (value) {
                    fieldController2.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController3,
                  maxLines: null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80)
                  ],
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Зміст',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть зміст';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController3.text = value!;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () async {
                  await formFunc(() async{
                    await updateEncouragement(int.parse(fieldController1.text), fieldController2.text, fieldController3.text, widget.action!);
                  });
                },
                child: buttonRow(),
              ),
            ],
          )
        ],
      ),
    );
  }
  Future<void> updateEncouragement(int session, String date, String content, doUpdate) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    doUpdate ?
    await connHandler.updateEncouragement(widget.id, session, date, content) :
    await connHandler.insertEncouragement(widget.id, session, date, content);

    await connHandler.close();
  }

  Widget getSpForms(){
    if (selectedCategory == EditForm.invalidCategory ) {
      return invalidSpForm();
    } else if (selectedCategory == EditForm.chornobylCategory) {
      return chornobyltciSpForm();
    } else if (selectedCategory == EditForm.manyChildrenCategory) {
      return manyChildrenSpForm();
    } else if (selectedCategory == null) {
      return Container();
    } else {
      return defaultSpForm();
    }

  }

  Widget defaultSpForm(){
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9, // 30% of screen width
              child: TextFormField(
                controller: fieldController1,
                maxLines: null,
                decoration: const InputDecoration(
                  icon: Icon(Icons.date_range),
                  labelText: 'Дата початку',
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введіть дату';
                  }
                  return null;
                },
                onTap: () {
                  selectDate();
                },
                onSaved: (value) {
                  fieldController1.text = value!;
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9, // 30% of screen width
              child: TextFormField(
                controller: fieldController2,
                maxLines: null,
                decoration: const InputDecoration(
                  icon: Icon(Icons.date_range),
                  labelText: 'Дата закінчення',
                ),
                readOnly: true,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Введіть дату';
                //   }
                //   return null;
                // },
                onTap: () {
                  selectDate2();
                },
                onSaved: (value) {
                  fieldController2.text = value!;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () async {
                await formFunc(() async{
                  await updateDefaultSp(
                      widget.id,
                      fieldController1.text,
                      fieldController2.text,
                      widget.action
                  );
                });
              },
              child: buttonRow(),
            ),
          ],
        )
      ],
    );
  }
  Future<void> updateDefaultSp(int idStudent, String startDate, String endDate, doUpdate) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();
    doUpdate?
      await connHandler.updateDefaultSp(widget.id, startDate, endDate):
      await connHandler.insertDefaultSp(idStudent, int.parse(selectedCategoryMap?['id']), startDate, endDate);
    await connHandler.close();
  }


  Widget invalidSpForm(){
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9, // 30% of screen width
              child: TextFormField(
                controller: fieldController1,
                maxLines: null,
                decoration: const InputDecoration(
                  icon: Icon(Icons.date_range),
                  labelText: 'Дата початку',
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введіть дату';
                  }
                  return null;
                },
                onTap: () {
                  selectDate();
                },
                onSaved: (value) {
                  fieldController1.text = value!;
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9, // 30% of screen width
              child: TextFormField(
                controller: fieldController2,
                maxLines: null,
                decoration: const InputDecoration(
                  icon: Icon(Icons.date_range),
                  labelText: 'Дата закінчення',
                ),
                readOnly: true,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Введіть дату';
                //   }
                //   return null;
                // },
                onTap: () {
                  selectDate2();
                },
                onSaved: (value) {
                  fieldController2.text = value!;
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextFormField(
                controller: fieldController3,
                maxLines: null,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10)
                ],
                decoration: const InputDecoration(
                  icon: Icon(Icons.note),
                  labelText: 'Група інвалідності',
                ),
                onSaved: (value) {
                  fieldController3.text = value!;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () async {
                await formFunc(() async{
                  await updateInvalidSp(
                      widget.id,
                      fieldController1.text.isNotEmpty ? fieldController1.text : '',
                      fieldController2.text.isNotEmpty ? fieldController2.text : '',
                      fieldController3.text.isNotEmpty ? fieldController3.text : '',
                      widget.action!
                  );
                });
              },
              child: buttonRow(),
            ),
          ],
        )
      ],
    );

  }
  Future<void> updateInvalidSp(int idStudent, String startDate, String endDate, String invalidGroup, bool doUpdate) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();
    doUpdate?
        await connHandler.updateInvalidSp(widget.id, startDate, endDate, invalidGroup) :
        await connHandler.insertInvalidSp(idStudent, int.parse(
            selectedCategoryMap?['id']), startDate, endDate, invalidGroup);
    await connHandler.close();
  }


  Widget chornobyltciSpForm(){
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9, // 30% of screen width
              child: TextFormField(
                controller: fieldController1,
                maxLines: null,
                decoration: const InputDecoration(
                  icon: Icon(Icons.date_range),
                  labelText: 'Дата початку',
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введіть дату';
                  }
                  return null;
                },
                onTap: () {
                  selectDate();
                },
                onSaved: (value) {
                  fieldController1.text = value!;
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9, // 30% of screen width
              child: TextFormField(
                controller: fieldController2,
                maxLines: null,
                decoration: const InputDecoration(
                  icon: Icon(Icons.date_range),
                  labelText: 'Дата закінчення',
                ),
                readOnly: true,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Введіть дату';
                //   }
                //   return null;
                // },
                onTap: () {
                  selectDate2();
                },
                onSaved: (value) {
                  fieldController2.text = value!;
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextFormField(
                controller: fieldController3,
                maxLines: null,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10)
                ],
                decoration: const InputDecoration(
                  icon: Icon(Icons.note),
                  labelText: 'Група',
                ),
                onSaved: (value) {
                  fieldController3.text = value!;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () async {
                await formFunc(() async{
                  await updateChornobyltsiSp(widget.id,
                      fieldController1.text.isNotEmpty ? fieldController1.text : '',
                      fieldController2.text.isNotEmpty ? fieldController2.text : '',
                      fieldController3.text.isNotEmpty ? fieldController3.text : '',
                      widget.action!
                  );
                });
              },
              child: buttonRow(),
            ),
          ],
        )
      ],
    );

  }
  Future<void> updateChornobyltsiSp(int idStudent, String startDate, String endDate, String group, bool doUpdate) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();
    doUpdate?
      await connHandler.updateChornobyltsiSp(widget.id, startDate, endDate, group) :
      await connHandler.insertChornobyltsiSp(idStudent, int.parse(selectedCategoryMap?['id']), startDate, endDate, group);
    await connHandler.close();
  }



  Widget manyChildrenSpForm(){
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9, // 30% of screen width
              child: TextFormField(
                controller: fieldController1,
                maxLines: null,
                decoration: const InputDecoration(
                  icon: Icon(Icons.date_range),
                  labelText: 'Дата початку',
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введіть дату';
                  }
                  return null;
                },
                onTap: () {
                  selectDate();
                },
                onSaved: (value) {
                  fieldController1.text = value!;
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9, // 30% of screen width
              child: TextFormField(
                controller: fieldController2,
                maxLines: null,
                decoration: const InputDecoration(
                  icon: Icon(Icons.date_range),
                  labelText: 'Дата закінчення',
                ),
                readOnly: true,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Введіть дату';
                //   }
                //   return null;
                // },
                onTap: () {
                  selectDate2();
                },
                onSaved: (value) {
                  fieldController2.text = value!;
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextFormField(
                controller: fieldController3,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10)
                ],
                maxLines: null,
                decoration: const InputDecoration(
                  icon: Icon(Icons.note),
                  labelText: 'Кількість дітей',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введіть кількість дітей';
                  }
                  return null;
                },
                onSaved: (value) {
                  fieldController3.text = value!;
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextFormField(
                controller: fieldController6,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10)
                ],
                maxLines: null,
                decoration: const InputDecoration(
                  icon: Icon(Icons.note),
                  labelText: 'З них яким менше 18',
                ),
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Введіть ';
                //   }
                //   return null;
                // },
                onSaved: (value) {
                  fieldController6.text = value!;
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextFormField(
                controller: fieldController5,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10)
                ],
                maxLines: null,
                decoration: const InputDecoration(
                  icon: Icon(Icons.note),
                  labelText: 'З них яким більше 18 та навчаються',
                ),
                onSaved: (value) {
                  fieldController5.text = value!;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () async {
                if (!isDisabled.value) {
                  isDisabled.value = true;

                  try {
                    if (formKey.currentState!.validate()) {
                      // Перевірка валідності полів
                      if (fieldController6.text.isNotEmpty && int.tryParse(fieldController6.text) == null) {
                        messageBar('Введіть коректне число в полі "Кількість існуючих дітей"');
                        isDisabled.value = false;
                        return;
                      }

                      if (fieldController3.text.isNotEmpty && int.tryParse(fieldController3.text) == null) {
                        messageBar('Введіть коректне число в полі "Загальна кількість дітей"');
                        isDisabled.value = false;
                        return;
                      }

                      if (fieldController5.text.isNotEmpty && int.tryParse(fieldController5.text) == null) {
                        messageBar('Введіть коректне число в полі "З них яким більше 18 та навчаються"');
                        isDisabled.value = false;
                        return;
                      }

                      // Parse значення
                      int existingChildren = int.tryParse(fieldController6.text) ?? 0;
                      int totalChildren = int.tryParse(fieldController3.text) ?? 0;
                      int newChildren = int.tryParse(fieldController5.text) ?? 0;

                      // Логічні перевірки
                      if (existingChildren > totalChildren) {
                        messageBar('Кількість вказаних дітей не може перевищувати загальну кількість дітей');
                      } else if (fieldController5.text.isNotEmpty) {
                        if ((existingChildren + newChildren) > totalChildren) {
                          messageBar('Введіть коректну кількість дітей');
                        } else {
                          formKey.currentState!.save();
                          await updateManyChildrenSp(
                            widget.id,
                            int.parse(selectedCategoryMap?['id'] ?? '0'),
                            fieldController1.text.isNotEmpty ? fieldController1.text : '',
                            fieldController2.text.isNotEmpty ? fieldController2.text : '',
                            fieldController3.text.isNotEmpty ? fieldController3.text : '',
                            fieldController6.text.isNotEmpty ? fieldController6.text : '',
                            fieldController5.text.isNotEmpty ? fieldController5.text : '',
                            widget.action ?? false,
                          );
                          messageBar('Інформацію оновлено у базі даних!');
                          Navigator.pop(context, true);
                        }
                      } else {
                        formKey.currentState!.save();
                        await updateManyChildrenSp(
                          widget.id,
                          int.parse(selectedCategoryMap?['id'] ?? '0'),
                          fieldController1.text.isNotEmpty ? fieldController1.text : '',
                          fieldController2.text.isNotEmpty ? fieldController2.text : '',
                          fieldController3.text.isNotEmpty ? fieldController3.text : '',
                          fieldController6.text.isNotEmpty ? fieldController6.text : '',
                          fieldController5.text.isNotEmpty ? fieldController5.text : '',
                          widget.action ?? false,
                        );
                        messageBar('Інформацію оновлено у базі даних!');
                        Navigator.pop(context, true);
                      }
                    }
                  } catch (e) {
                    print('$e');
                    messageBar('Вибачте, виникла помилка');
                  } finally {
                    isDisabled.value = false;
                  }
                } else {
                  print('cant login');
                }
              },



              child: buttonRow(),
            ),
          ],
        )
      ],
    );

  }
  Future<void> updateManyChildrenSp(int idStudent, int idCategory, String startDate, String endDate, String numOfChild, String lessThan18, String moreThan18Studying, bool doUpdate) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();
    doUpdate ?
        await connHandler.updateSpManyChildrenByIdSp(widget.id, startDate, endDate, numOfChild, lessThan18, moreThan18Studying) :
        await connHandler.insertManyChildrenSp(idStudent, idCategory, startDate, endDate, numOfChild, lessThan18, moreThan18Studying);
    await connHandler.close();
  }

  Widget getSocialPassportForm(){
    return Form(
      key: formKey,
      child: Column(
        children: [
          if(widget.showSpDropDown!)
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
                fieldController4.text= newValue!;
                selectedCategoryMap = spCategories.firstWhere(
                      (element) => element['category'] == selectedCategory,
                );
                // print(selectedCategoryMap?['id']);
                // clearData();
                // returnFormFields();
              });
            },
          ),
          getSpForms(),
        ],
      ),
    );
  }

  Future<void> selectCategoriesNames() async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    List<Map<String, dynamic>> fetchedCategories = await connHandler.selectSpCategoryName();

    await connHandler.close();

    setState(() {
      spCategories = fetchedCategories;
      if(widget.spCategory != null){
        selectedCategory = widget.spCategory;
      }
    });
  }
  String? year;
  Widget getWorkPlanForm(){

    return Form(
      key: formKey,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController3,
                  maxLines: null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80)
                  ],
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Назва заходу',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть захід';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController3.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController4,
                  maxLines: null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80)
                  ],
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Виконавець',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть виконавця';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController4.text = value!;
                  },
                ),
              ),

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController2,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Семестр',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть семестр';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController2.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9, // 30% of screen width
                child: TextFormField(
                  controller: fieldController1,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.date_range),
                    labelText: 'Дата проведення',
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть дату';
                    }
                    return null;
                  },
                  onTap: () async {
                    DateTime? date = await selectDate();
                    if (date != null) {
                      if (date.month >= 1 && date.month <= 8) {
                        year = '${date.year - 1}-${date.year}';
                      } else {
                        year = '${date.year}-${date.year + 1}';
                      }
                    }
                  }
                  ,
                  onSaved: (value) {
                    fieldController1.text = value!;
                  },
                ),
              ),
              
              SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                      value: isDone,
                      onChanged: (bool? value) {
                        setState(() {
                          isDone = value!;
                        });
                      }
                  ),
                  Text('Статус виконання заходу', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),),

                ],
              ),

              if(widget.isAdmin!)
                Row(
                  children: [
                    Checkbox(
                        value: adminConfirmation,
                        onChanged: (bool? value) {
                          setState(() {
                            adminConfirmation = value!;
                          });
                        }
                    ),
                    Text('Підтвердження адміністратора', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),),

                  ],
                )

            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () async {
                  await formFunc(() async{
                    await updateWorkPlan(int.parse(fieldController2.text), fieldController3.text, fieldController1.text,
                        fieldController4.text, isDone, adminConfirmation, widget.action);
                  });
                },
                child: buttonRow(),
              ),
            ],
          )
        ],
      ),
    );
  }
  Future<void> updateWorkPlan(int session, String eventName, String executionDate, String executor, bool isDone, bool adminConfirmation, doUpdate) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    doUpdate ?
    await connHandler.updateWorkPlan(widget.idTable!, session, eventName, executionDate, executor, isDone, adminConfirmation) :
    await connHandler.insertWorkPlan(session, eventName, executionDate, executor, isDone, adminConfirmation, widget.wpCreator!, year!);

    await connHandler.close();
  }

  Widget addStudentForm(){

    return Form(
      key: formKey,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController3,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Прізвище',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть прізвище';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController3.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController4,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Ім\'я',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть ім\'я';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController4.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController5,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Побатькові',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть побатькові';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController5.text = value!;
                  },
                ),
              ),


            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () async {
                  await formFunc(() async{
                    await updateStudent(fieldController3.text, fieldController4.text, fieldController5.text, widget.action);
                  });
                },
                child: buttonRow(),
              ),
            ],
          )
        ],
      ),
    );
  }
  Future<void> updateStudent(String secondName, String firstName, String middleName, doUpdate) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    doUpdate ?
    await connHandler.updateStudent(widget.id, secondName, firstName, middleName):
    await connHandler.insertStudent(secondName, firstName, middleName, widget.group!);

    await connHandler.close();
  }


  Future<void> insertStudent(String secondName, String firstName, String middleName, String group) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    await connHandler.insertStudent(secondName, firstName, middleName, group);
    await connHandler.close();
  }

  String encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
  Widget addCuratorForm(){

    return Form(
      key: formKey,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController1,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Прізвище',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть прізвище';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController1.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController2,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Ім\'я',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть ім\'я';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController2.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController3,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Побатькові',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть побатькові';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController3.text = value!;
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController4,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.mail),
                    labelText: 'E-mail для входу',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть E-mail';
                    }
                    if(!value.contains("@")){
                      return 'E-mail має містити @';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController4.text = value!;
                  },
                ),
              ),
              DropdownButton<String>(
                hint: Text("Призначити групу:"),
                value: selectedGroup,
                items: groupNames.map((Map<String, dynamic> item) {
                  return DropdownMenuItem<String>(
                    value: item['group_name'],
                    child: Text(item['group_name']),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGroup = newValue!;
                    selectedGroupMap = groupNames.firstWhere(
                          (element) => element['group_name'] == selectedGroup,
                    );
                    // print(selectedCategoryMap?['id']);
                    // clearData();
                    // returnFormFields();
                  });
                },
              ),


            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () async {
                  await formFunc(() async{
                    await updateCurators(fieldController1.text, fieldController2.text, fieldController3.text,
                        selectedGroup!, fieldController4.text, 'Куратор', widget.action );
                  });
                },

                child: buttonRow(),
              ),
            ],
          )
        ],
      ),
    );
  }
  Future<void> updateCurators(String secondName, String firstName, String middleName, String group, String email, String role, doUpdate) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();
    if(doUpdate){
      await connHandler.updateCurator(widget.id, secondName, firstName, middleName, group, email);
    }else{
      var random = Random();
      var randomNumber = random.nextInt(100000);
      String pass = encryptPassword("$randomNumber");
      await connHandler.insertCurator(secondName, firstName, middleName, group, email, role, pass);
    }
    await connHandler.close();
  }

  Future<void> selectGroupNames() async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();

    List<Map<String, dynamic>> fetchedCategories = await connHandler.selectGroups();

    await connHandler.close();

    setState(() {
      groupNames = fetchedCategories;
    });
  }

  Widget addGroupNameForm(){
    return Form(
      key: formKey,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController3,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Назва групи',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть назву групи';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController3.text = value!;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () async {
                  await formFunc(() async{
                    await addGroupNames(fieldController3.text);
                  });
                },
                child: buttonRow(),
              ),
            ],
          )
        ],
      ),
    );
  }
  Future<void> addGroupNames(String groupName) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();
    await connHandler.insertGroupName(groupName);
    await connHandler.close();
  }


  Widget addCategoryNameForm() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextFormField(
                  controller: fieldController3,
                  maxLines: null,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.note),
                    labelText: 'Назва категорії',
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть назву картегорії';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fieldController3.text = value!;
                  },

                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () async {
                  await formFunc(() async{
                    await addCategoryNames(fieldController3.text);
                  });
                },
                child: buttonRow(),
              ),
            ],
          )
        ],
      ),
    );
  }
  Future<void> addCategoryNames(String categoryName) async {
    final connHandler = MySqlConnectionHandler();
    await connHandler.connect();
    await connHandler.insertCategoryName(categoryName);
    await connHandler.close();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: (widget.studentName == null || widget.studentName!.isEmpty)
            ? Text('${widget.selectedValue}')
            :
             Column(
                children: [
                  Row(
                    children: [
                      Text('${widget.studentName}'),
                    ],
                  ),
                  Row(
                    children: [Text('${widget.selectedValue}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),)],
                  )
                ],
              ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SizedBox(
                  width: AppTheme.getResponsiveWidthContent(context),
                  child: Column(
                    children: [
                      getFormContent()
                    ],
                  ),
                ),
              )
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
