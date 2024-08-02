import 'package:ebook_builder/app/data/models/chapter.dart';
import 'package:isar/isar.dart';

part 'book.g.dart';

@collection
class Book {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  @Index(type: IndexType.value)
  String? title;

  final chapters = IsarLinks<Chapter>();

  String? author;

  DateTime? dateTime;
}
