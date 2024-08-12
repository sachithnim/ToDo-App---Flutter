import 'package:cloud_firestore/cloud_firestore.dart';

class Todo{
  final String id;
  final String title;
  final String description;
  final bool isDone;
  final Timestamp timeStamp;

  Todo({required this.id, required this.title, required this.description, required this.isDone, required this.timeStamp});
}