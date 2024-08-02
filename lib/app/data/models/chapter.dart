import 'package:isar/isar.dart';

part 'chapter.g.dart';

@collection
class Chapter {
  Id? id = Isar.autoIncrement;
  String? title;
  String? content;
}
