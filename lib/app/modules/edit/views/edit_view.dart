import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_markdown/super_editor_markdown.dart';

import '../../../data/models/book.dart';
import '../../../services/book_service.dart';
import '../controllers/edit_controller.dart';

class EditView extends GetView<EditController> {
  const EditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('${controller.title}')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          SizedBox(
            width: 280,
            child: listChaptor(context),
          ),
          const VerticalDivider(),
          Expanded(
            child: GetBuilder<EditController>(
              init: EditController(),
              id: 'content',
              builder: (controller) {
                return IndexedStack(
                  index: controller.chapterIndex.value,
                  children:
                      List.generate(controller.book.chapters.length, (index) {
                    final markdown =
                        controller.book.chapters.toList()[index].content;

                    final document = deserializeMarkdownToDocument(
                      markdown!,
                      syntax: MarkdownSyntax.superEditor,
                    );

                    final editor = createDefaultDocumentEditor(
                      document: document,
                      composer: MutableDocumentComposer(),
                    );

                    editor.document
                        .addListener((value) => log('${value.changes}'));

                    return SuperEditor(
                      editor: editor,
                    );
                  }),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  listChaptor(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: () => showAddChapterDialog(context),
              label: const Text('New chapter'),
              icon: const Icon(Icons.add),
            )
          ],
        ),
        Expanded(
          child: GetBuilder<EditController>(
            init: EditController(),
            id: 'chapter',
            builder: (controller) => ListView.builder(
              itemCount: controller.book.chapters.length,
              itemBuilder: (context, index) {
                final item = controller.book.chapters.toList()[index];
                return ListTile(
                  title: Text('${item.title}'),
                  onTap: () {
                    controller.chapterIndex.value = index;
                    controller.update(['content']);
                  },
                  trailing: IconButton(
                    onPressed: () => deleteChapter(
                        book: controller.book,
                        chapterId: item.id!,
                        index: index),
                    icon: const Icon(Icons.delete),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  showAddChapterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add'),
          content: TextFormField(
            controller: controller.chapterTitleController,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          actions: [
            TextButton(
                onPressed: () => Get.back(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                addNewChapter(title: controller.chapterTitleController.text);
                Get.back();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  addNewChapter({required String title}) {
    final chapterTitle = title.trim();

    if (chapterTitle.isNotEmpty) {
      BookService.newChapter(id: controller.book.id, title: chapterTitle)
          .then((value) {
        controller.refreshContent();
        Get.snackbar('Info', 'Chapter added');
      });
    } else {
      Get.snackbar('Error', 'Enter title');
    }
  }

  deleteChapter(
      {required Book book, required Id chapterId, required int index}) {
    BookService.deleteBookChapter(index: index, chapterId: chapterId).then((v) {
      controller.refreshContent();
    });
  }
}
