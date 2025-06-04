import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import '../curator_screens/all_student_info.dart';
import '../edit_form.dart';

class TeacherCard {
  final int id;
  final String curatorsGroup;
  final String firstName;
  final String lastName;
  final String middleName;
  final String email;
  final Function()? onTap;
  final Function()? onSwipe;


  TeacherCard({
    required this.id,
    required this.curatorsGroup,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.email,
    this.onTap,
    this.onSwipe
  });

  Card returnTeacherCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: SwipeActionCell(
        key: ValueKey(id),
        trailingActions: <SwipeAction>[
          if(true)
            SwipeAction(
              icon: Icon(Icons.delete, color: Colors.white,),
              onTap: (CompletionHandler handler) async {
                if(onSwipe != null){
                  onSwipe!();
                }
              },
              color: Colors.red,
            ),
        ],
        backgroundColor: Colors.transparent,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Куратор групи $curatorsGroup',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 3),
                Text(
                  '$lastName $firstName $middleName',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 3),
                Text(
                  'E-mail: $email',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ],

            ),
          ),
        ),

      ),
    );
  }

}