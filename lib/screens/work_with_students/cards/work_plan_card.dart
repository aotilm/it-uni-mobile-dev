import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';

class WorkPlanCard {
  final int id;
  final int session;
  final String year;
  final String eventName;
  final String executionDate;
  final String executor;
  final bool isDone;
  final bool adminConfirmation;
  final String group;
  final Function() onTap;
  final Function()? onSwipe;
  final Function()? onLeadingSwipe;


  WorkPlanCard({
    required this.id,
    required this.session,
    required this.year,
    required this.eventName,
    required this.executionDate,
    required this.executor,
    required this.isDone,
    required this.adminConfirmation,
    required this.onTap,
    required this.group,
     this.onSwipe,
    this.onLeadingSwipe
  });

  Card returnWorkPlanCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias,

      child: SwipeActionCell(
        key: ValueKey(id),
        leadingActions: onLeadingSwipe != null
            ? <SwipeAction>[
          SwipeAction(
            icon: Icon(Icons.done, color: Colors.white,),
            onTap: (CompletionHandler handler) {
              if (onLeadingSwipe != null) {
                onLeadingSwipe!();
              }
            },

            color: Colors.green,
          ),
        ] : null,
        trailingActions: <SwipeAction>[
          if(true)
            SwipeAction(
              icon: const Icon(Icons.delete, color: Colors.white,),
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
                  'Семестр №$session $year н/р',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),

                const SizedBox(height: 6),
                Text(
                  eventName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text.rich(
                    TextSpan(
                        children: [
                          TextSpan(
                              text: 'Створив: ',
                              style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          TextSpan(text: group == 'admin' ? "Адміністратор" : group)
                        ]
                    )
                ),
                Text.rich(
                    TextSpan(
                        children: [
                          TextSpan(
                              text: 'Дата виконання: ',
                              style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          TextSpan(text: executionDate)
                        ]
                    )
                ),
                Text.rich(
                    TextSpan(
                        children: [
                          TextSpan(
                              text: 'Виконавець: ',
                              style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          TextSpan(text: executor)
                        ]
                    )
                ),
                SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        'Підтвердження адміністратора: ',
                        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    adminConfirmation
                        ? Icon(Icons.done, color: Colors.green)
                        : Icon(Icons.close, color: Colors.red),
                  ],
                ),

                Row(
                  children: [
                    Flexible(
                        child: Text(
                          'Cтатус виконання заходу: ',
                          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                    ),
                    isDone ? Icon(Icons.done, color: Colors.green) : Icon(Icons.close, color: Colors.red)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}
