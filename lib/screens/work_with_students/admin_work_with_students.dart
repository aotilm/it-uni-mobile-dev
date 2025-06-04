import 'package:flutter/material.dart';
import 'package:test_journal/screens/work_with_students/admin_screens/admin_social_passport.dart';
import 'package:test_journal/screens/work_with_students/admin_screens/groups.dart';
import 'package:test_journal/screens/work_with_students/admin_screens/teachers.dart';
// import 'package:test_journal/screens/work_with_students/excel_import_export.dart';
import 'package:test_journal/screens/work_with_students/work_plan.dart';

class AdminWorkWithStudents extends StatefulWidget {
  const AdminWorkWithStudents({super.key, this.email});
  final String? email;
  @override
  State<AdminWorkWithStudents> createState() => _AdminWorkWithStudentsState();
}

class _AdminWorkWithStudentsState extends State<AdminWorkWithStudents> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Сторінка адміністратора"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        // backgroundColor: Colors.green,


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
            label: 'Групи',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person, color: Colors.white,),
            icon: Icon(Icons.person),
            label: 'Викладачі',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.list_alt, color: Colors.white,),
            icon: Icon(Icons.list_alt),
            label: 'План',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.book, color: Colors.white,),
            icon: Icon(Icons.book),
            label: 'Соц. паспорт',
          ),
        ],
      ),

      body: <Widget>[
        Groups(isAdmin: true,),
        Teachers(),
        WorkPlan(isAdmin: true, wpUser: 'admin',),
        AdminSocialPassport(email: widget.email,)
      ][currentPageIndex]
    );
  }

}
