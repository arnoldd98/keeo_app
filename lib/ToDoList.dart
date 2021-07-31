import 'package:flutter/material.dart';

class ToDoList extends StatefulWidget {
  final Map<String, bool> toDoMap;

  const ToDoList({required this.toDoMap});

  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.toDoMap.length,
          itemBuilder: (BuildContext context, int index) {
            String currentToDo = widget.toDoMap.keys.elementAt(index);
            bool isChecked = widget.toDoMap[currentToDo]!;
            return Row(
              children: [
                Checkbox(
                    value: isChecked,
                    onChanged: (checked) {
                      if (checked == null) return;
                      widget.toDoMap[currentToDo] = checked;
                      setState(() {});
                    }),
                Text(currentToDo)
              ],
            );
          }),
    );
  }
}
