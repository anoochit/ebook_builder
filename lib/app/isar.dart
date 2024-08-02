import 'dart:developer';

import 'package:ebook_builder/app/data/models/book.dart';
import 'package:ebook_builder/app/data/models/chapter.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

late Isar isar;

isarInit() async {
  final dir = await getApplicationDocumentsDirectory();
  log('store = $dir');
  isar = await Isar.open(
    [BookSchema, ChapterSchema],
    directory: dir.path,
  );
}
