import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_app/model/todo_model.dart';
import 'package:todo_app/services/database_services.dart';

class PendingWidget extends StatefulWidget {
  const PendingWidget({super.key});

  @override
  State<PendingWidget> createState() => _PendingWidgetState();
}

class _PendingWidgetState extends State<PendingWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  late String uid;

  final DatabaseServices _databaseServices = DatabaseServices();

  @override
  void initState(){
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Todo>>(
      stream: _databaseServices.todos,
      builder: (context, snapshot){
        if(snapshot.hasData){
          List<Todo> todos = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              Todo todo = todos[index];
              final DateTime dt = todo.timeStamp.toDate();
              return Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Slidable(
                  key: ValueKey(todo.id),
                  endActionPane: ActionPane(motion: DrawerMotion(), children: [
                    SlidableAction(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      icon: Icons.done,
                      label: "Done",
                      onPressed: (context){
                      _databaseServices.updateTodoStatus(todo.id, true);
                    })
                  ],),
                  startActionPane: ActionPane(motion: DrawerMotion(), children: [
                    SlidableAction(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: "Edit",	
                      onPressed: (context){
                      _showTaskDialog(context, todo: todo);
                    }),
                    SlidableAction(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: "Delete",
                      onPressed: (context) async{
                      await _databaseServices.deleteTodoTask(todo.id);
                    }),
                  ],),
                  child: ListTile(
                    title: Text(todo.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    ),
                    subtitle: Text(todo.description,
                    ),
                    trailing: Text("${dt.day}/${dt.month}/${dt.year}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  ),
                ),
              );
            }
          );
        }else{
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }
      },
    );
  }
  void _showTaskDialog(BuildContext context,{Todo? todo}) {
    final TextEditingController _titleController = TextEditingController(text: todo?.title);
    final TextEditingController _descriptionController = TextEditingController(text: todo?.description);
    final DatabaseServices _databaseService = DatabaseServices();


    showDialog (context: context, builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          todo == null? "Add Task" : "Edit Task",
          style: TextStyle(
          fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
          onPressed: () async {
            if(todo == null){
              await _databaseService.addToTask(_titleController.text, _descriptionController.text);
            }
            else{
              await _databaseService.updateTodo(todo.id, _titleController.text, _descriptionController.text);
            }
          
            Navigator.pop(context);
          }, child: Text(todo == null ? "Add" : "Update"),
          ),
        ]
      );
    },
    );
  }
}

