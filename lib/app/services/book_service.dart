import 'dart:developer';

import 'package:ebook_builder/app/data/models/book.dart';
import 'package:ebook_builder/app/isar.dart';
import 'package:isar/isar.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_markdown/super_editor_markdown.dart';

import '../data/models/chapter.dart';

class BookService {
  static Future<Id> newBook(
      {required String title, required String author}) async {
    final book = Book()
      ..title = title
      ..author = author
      ..dateTime = DateTime.now();

    return await isar.writeTxn<Id>(() async {
      return await isar.books.put(book);
    });
  }

  static Stream<List<Book>> bookStream() {
    return isar.books.where().watch();
  }

  static Future<List<Book>> getBooks() async {
    return await isar.books.where().findAll();
  }

  static Future<bool> deleteBook({required Id id}) async {
    return await isar.writeTxn<bool>(() async {
      return await isar.books.delete(id);
    });
  }

  static Stream<void> bookItemStream({required Id id}) {
    return isar.books.where().filter().idEqualTo(id).watch();
  }

  static Future<void> newChapter(
      {required String title, required Id id}) async {
    final item = await isar.books.where().filter().idEqualTo(id).findFirst();

    final templateDocument = MutableDocument(
      nodes: [
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Header'),
          metadata: {
            'blockType': header1Attribution,
          },
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('This is the first paragraph'),
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('This is the second paragraph'),
        ),
      ],
    );

    final content = serializeDocumentToMarkdown(
      templateDocument,
      syntax: MarkdownSyntax.superEditor,
    );

    log(content);

    final chapter = Chapter()
      ..title = title
      ..content = content;

    return await isar.writeTxn(() async {
      await isar.chapters.put(chapter);
      item!.chapters.add(chapter);
      item.chapters.save();

      log('edit = ${id}');
    });
  }

  static Future<Book?> getBook({required Id id}) async {
    return await isar.books.get(id);
  }

  static Future<void> deleteBookChapter(
      {required int index, required Id chapterId}) async {
    return await isar.writeTxn(() async {
      await isar.chapters.delete(chapterId);
    });
  }
}
