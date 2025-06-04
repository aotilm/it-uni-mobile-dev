import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';

class CardWidget {
  final String id;
  final String? index;
  final String? firstName;
  final String? lastName;
  final String? middleName;

  final List<Map<String, String>>? objects;

  final Function()? onTap;

  final Function()? onSwipe;
  final Function()? onLeadingSwipe;

  final bool? studentStatus;
  

  CardWidget({
    required this.id,
     this.index,
     this.firstName,
     this.lastName,
     this.middleName,
     this.objects,
     this.onTap,
    this.studentStatus,
    this.onSwipe,
    this.onLeadingSwipe
  });

  Card returnCard(context) {
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
            icon: Icon(Icons.edit, color: Colors.white,),
            onTap: (CompletionHandler handler) {
              if (onLeadingSwipe != null) {
                onLeadingSwipe!();
              }
            },

            color: Colors.green,
          ),
        ] : null,
        trailingActions: <SwipeAction>[
        SwipeAction(
          icon: Icon(Icons.delete, color: Colors.white,),
          onTap: (CompletionHandler handler) {
            if (onSwipe != null) {
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
            child: Container(
              width: MediaQuery.of(context).size.width * 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(index != null )
                      Column(
                        children: [
                          Text(
                            '№ з/п: $index',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 3),
                        ],
                      ),

                    if (firstName != null)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$lastName $firstName $middleName',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),

                    if(objects != null )
                      ..._returnTitles(),



                    if(studentStatus != null)
                      studentStatus! ?
                      const Column(
                        children: [
                          // SizedBox(height: 8),
                          Text(
                            'Вибув',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                        ],
                      )
                          : Container()


                  ],
                ),
              ),
            )
        ),

      ),
    );
  }

  List<Widget> _returnTitles() {
    List<Widget> widgets = [];

    for (var obj in objects!) {
      String key = obj.keys.first;
      String value = obj.values.first;

      if(value != null && value != ""){
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$key: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: value,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

}
