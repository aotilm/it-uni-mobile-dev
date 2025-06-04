import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:test_journal/MySqlConnection.dart';
import 'dart:math';
import 'package:test_journal/screens/password_recovery_html.dart';

import '../theme_data.dart';

class RecoverPassPage extends StatefulWidget {
  const RecoverPassPage({super.key});

  @override
  State<RecoverPassPage> createState() => _RecoverPassPageState();
}

class _RecoverPassPageState extends State<RecoverPassPage> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  int page = 0;
  int randomNumber = 0;
  String? email;

  String encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
  
  Future<void> sendRecoverCode(String recepient) async {
    String username = 'aotilm@gmail.com';
    String password = '';

    var random = Random();
    randomNumber = random.nextInt(100000);

    final smtpServer = gmail(username, password);

    // Create our message.
    final message = Message()
      ..from = Address(username, 'Журнал куратора')
      // ..recipients.add('muravets.i@nemk.ukr.education')
      ..recipients.add(recepient)
      ..subject = 'Відновлення пароля'
      ..text = 'Лист відновлення пароля'
      ..html = PasswordRecoveryHtml.html(randomNumber);


    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. $e');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
  final ValueNotifier<bool> isDisabled = ValueNotifier<bool>(false);

  Widget recoverForm(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: AppTheme.getResponsiveWidthContent(context),
          child: TextFormField(
            controller: emailController,
            maxLines: null,
            decoration: const InputDecoration(
              icon: Icon(Icons.mail),
              labelText: 'Email для відновлення',
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

              return null; // Валідація пройшла успішно
            },
            onSaved: (value) {
              emailController.text = value!;
            },
          ),
        ),
        SizedBox(height: 10),
        FilledButton(
          onPressed: () async {
            if (!isDisabled.value) {
              try{
                if (formKey.currentState!.validate()) {
                  isDisabled.value = true;

                  formKey.currentState!.save();
                  // await Future.delayed(Duration(seconds: 3));
                  email = emailController.text;
                  var connHandler = MySqlConnectionHandler();
                  await connHandler.connect();
                  List<Map<String, dynamic>> records = await connHandler.checkEmail(email!);
                  if(records.isNotEmpty){
                    await sendRecoverCode(email!);
                    setState(() {
                      page=1;
                    });
                  } else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(backgroundColor: Theme.of(context).primaryColor, content: Text('Дана електронна адреса не зареєстрована. Зверніться до адміністратора.')),
                    );
                  }

                }

              }finally{
                isDisabled.value = false;
              }
            }
          },
          child: ValueListenableBuilder<bool>(
            valueListenable: isDisabled,
            builder: (context, value, child) {
              return Text(value ? 'Зачекайте...' : 'Надіслати код відновлення');
            },
          ),
        )

      ],
    );
  }

  Widget codeConfirmForm(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Надіслано код - ${emailController.text}'),
        SizedBox(
          width: AppTheme.getResponsiveWidthContent(context),
          child: TextFormField(
            controller: codeController,
            maxLines: null,
            decoration: const InputDecoration(
              icon: Icon(Icons.person),
              labelText: 'Код підтвердження',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введіть код';
              }
              if(int.parse(value) != randomNumber){
                return 'Невірний код';
              }
              return null;
            },
            onSaved: (value) {
              codeController.text = value!;
            },
          ),
        ),
        SizedBox(height: 10),
        FilledButton(
            onPressed: (){
              if (formKey.currentState!.validate()) {
                setState(() {
                  page=2;
                });
              }
            },
            child: Text('Підтвердити')
        )

      ],
    );
  }

  Widget setNewPassForm(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: AppTheme.getResponsiveWidthContent(context),
          child: TextFormField(
            controller: passController,
            maxLines: null,
            decoration: const InputDecoration(
              icon: Icon(Icons.person),
              labelText: 'Новий пароль',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введіть новий пароль';
              }
              if (value.length < 8) {
                return 'Пароль повиннен містити не менше 8 символів';
              }
              return null;
            },
            onSaved: (value) {
              passController.text = value!;
            },
          ),
        ),
        SizedBox(height: 10),
        FilledButton(
            onPressed: () async {
              if(!isDisabled.value){
                try{
                  isDisabled.value = true;
                  if (formKey.currentState!.validate()) {
                    // await Future.delayed(Duration(seconds: 3));

                    await updatePass(encryptPassword(passController.text));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(backgroundColor: Theme.of(context).primaryColor, content: Text('Пароль відновленно')),
                    );
                  }
                }finally{
                  isDisabled.value = false;
                }
              }
            },
            child: ValueListenableBuilder<bool>(
              valueListenable: isDisabled,
              builder: (context, value, child) {
                return Text(value ? 'Зачекайте...' : 'Підтвердити');
              },
            ),
        )

      ],
    );
  }
  Future<void> updatePass(String pass) async{
    var connHandler = MySqlConnectionHandler();
    await connHandler.connect();
    await connHandler.updatePassword(emailController.text, pass);
    await connHandler.close();
  }

  Widget getBodyContent() {
    switch (page) {
      case 1:
        return codeConfirmForm();
      case 2:
        return setNewPassForm();
      default:
        return recoverForm();


    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Відновлення пароля'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: getBodyContent(),
          ),
        ),
      )
    );
  }
}
