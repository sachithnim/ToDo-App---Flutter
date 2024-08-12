import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseServices {
  final CollectionReference todoCollection = FirebaseFirestore.instance.collection('todos');

  User? user = FirebaseAuth.instance.currentUser;


//Add Todo task
  Future<DocumentReference> addToTask(String title, String description) async{
    return await todoCollection.add({
      'uid' : user!.uid,
      'title': title,
      'description': description,
      'isDone': false,
      'createAt' : FieldValue.serverTimestamp()
    });
  }

  //Update Todo task
  Future<void> updateTodo(String id, String title, String description) async{
    final updatetodoCollection = FirebaseFirestore.instance.collection('todos').doc(id);
    return await updatetodoCollection.update({
      'title': title,
      'description': description
    });
  }

  //update Todo status
  Future<void> updateTodoStatus(String id, bool isDone) async{
    return await todoCollection.doc(id).update({
      'isDone': isDone
    });
  }

  //detele Todo task
  Future<void> deleteTodoTask(String id) async{
    return await todoCollection.doc(id).delete();
  }

}