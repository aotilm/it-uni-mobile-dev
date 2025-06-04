import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';


class GroupsCard {
  final int id;
  final String groupName;
  final String curator;
  final Function()? onTap;
  final Function()? onSwipe;


  GroupsCard({
    required this.id,
    required this.groupName,
    required this.curator,
    this.onTap,
    this.onSwipe
  });

  Card returnGroupCard(BuildContext context) {
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
              icon: Icon(Icons.archive, color: Colors.white,),
              onTap: (CompletionHandler handler) async {
                if(onSwipe != null){
                  onSwipe!();
                }
              },
              color: Colors.green,
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
                SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      groupName,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Куратор: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: curator),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
