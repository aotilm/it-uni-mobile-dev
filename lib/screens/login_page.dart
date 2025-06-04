import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:test_journal/screens/recover_pass_page.dart';
// import 'package:test_journal/theme_data.dart';
import 'package:test_journal/screens/work_with_students/admin_work_with_students.dart';
import 'package:test_journal/screens/work_with_students/curators_work_with_students.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../MySqlConnection.dart';
import 'package:crypto/crypto.dart';

import '../theme_data.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController loginController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  final _storage = const FlutterSecureStorage();

  Future<void> _readFromStorage() async{
    loginController.text = await _storage.read(key: 'USERNAME') ?? '';
  }
  String encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<void> logining() async {

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      final connHandler = MySqlConnectionHandler();
      await connHandler.connect();
      // bool result = await connHandler.loginUser(loginController.text, passController.text);
      String pass = encryptPassword(passController.text);
      List<Map<String, dynamic>> records = await connHandler.selectCuratorInfo(loginController.text, pass);
      await connHandler.close();

      if(records.isNotEmpty){
        await _storage.write(key: "USERNAME", value: loginController.text);
        switch (records[0]["role"]){
          case 'Адміністратор':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminWorkWithStudents(email: loginController.text,)
              ),
            );
          case 'Куратор':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => CuratorsWorkWithStudents(group: records[0]['group'], isAdmin: false,)
              ),
            );
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor: Theme.of(context).primaryColor, content: Text('Skill issue!')),
            );
        }
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Theme.of(context).primaryColor, content: Text('Невірні дані для входу!')),
        );

      }
    }

  }

  @override
  void initState() {
    super.initState();
    _readFromStorage();
  }
  final ValueNotifier<bool> isDisabled = ValueNotifier<bool>(false);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Сторінка авторизації'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Container(
              width: AppTheme.getResponsiveWidthForms(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Вітаємо з поверненням!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Введіть дані для входу в додаток',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: TextFormField(
                      autofillHints: [AutofillHints.username],
                      controller: loginController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.mail),
                        labelText: 'E-mail',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введіть E-mail';
                        }

                        if (!value.contains('@')) {
                          return 'E-mail має містити @';
                        }

                        final parts = value.split('@');
                        if (parts.length != 2 || parts[1] != 'nemk.ukr.education') {
                          return 'E-mail має містити домен @nemk.ukr.education';
                        }

                        final dotCount = parts[1].split('.').length - 1;
                        if (dotCount != 2) {
                          return 'Доменне імʼя має містити лише дві крапки';
                        }

                        return null;
                      },
                      onSaved: (value) {
                        loginController.text = value!;
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: TextFormField(
                      autofillHints: [AutofillHints.username],
                      obscureText: true,
                      // obscuringCharacter: "!",
                      controller: passController,
                      // maxLines: null,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.key),
                        labelText: 'Пароль',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введіть пароль';
                        }

                        return null;
                      },
                      onSaved: (value) {
                        passController.text = value!;
                      },
                    ),
                  ),
                  SizedBox(height: 25),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: FilledButton(
                      onPressed: () async {
                        if(!isDisabled.value){
                          isDisabled.value = true;

                          try{
                            // await Future.delayed(Duration(seconds: 3));
                            await logining();
                          }catch(e){
                            log("$e");
                          }finally{
                            isDisabled.value = false;
                          }
                        }else{
                          log('cant login');
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Центрування тексту
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: isDisabled,
                            builder: (context, value, child) {
                              return Icon(value ? Icons.hourglass_empty : Icons.login);
                            },
                          ),
                          // Icon(Icons.login),
                          SizedBox(width: 5),
                          // Text('Увійти'),
                          ValueListenableBuilder<bool>(
                            valueListenable: isDisabled,
                            builder: (context, value, child) {
                              return Text(value ? 'Зачекайте...' : 'Увійти');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  TextButton(
                      onPressed: () async {
                        // await recoverPassword();

                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => RecoverPassPage()
                        ));
                      },
                      child: Text('Забув пароль'))

                ],
              ),
            ),
          )
        )
      )
    );
  }
}
