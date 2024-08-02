import 'package:ebook_builder/app/data/models/book.dart';
import 'package:ebook_builder/app/routes/app_pages.dart';
import 'package:ebook_builder/app/services/book_service.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EBook builder'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Obx(
        () => (controller.listBook.isNotEmpty) ? bookGridView() : emptyBook(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // create
          showAddBookDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  GridView bookGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 2 / 3,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      itemCount: controller.listBook.length,
      itemBuilder: (BuildContext context, int index) {
        final book = controller.listBook[index];
        return GridTile(
          footer: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                book.title ?? 'unknow',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          child: InkWell(
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () => Get.toNamed(
              Routes.EDIT,
              arguments: book,
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: LayoutBuilder(builder: (context, constraints) {
                        return SizedBox(
                          width: (constraints.maxWidth - 22),
                          height: (((constraints.maxWidth - 22) * 3) / 2),
                        );
                      }),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        onPressed: () => showDeleteDialog(context, book),
                        icon: Icon(
                          Icons.delete_forever,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete'),
          content: Text('Delete "${book.title}" '),
          actions: [
            TextButton(
                onPressed: () => Get.back(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                BookService.deleteBook(id: book.id).then((value) {
                  if (value) {
                    Get.snackbar('Info', 'Book deleted');
                  } else {
                    Get.snackbar('Error', 'Cannot delete book');
                  }
                });
                Get.back();
              },
              child: const Text('Delete'),
            )
          ],
        );
      },
    );
  }

  Center emptyBook() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox),
          Text('No book, please create one.'),
        ],
      ),
    );
  }

  void showAddBookDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New book'),
        content: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: controller.bookTitleController,
              decoration: const InputDecoration(
                hintText: 'Title',
              ),
            ),
            TextFormField(
              controller: controller.bookAuthorController,
              decoration: const InputDecoration(
                hintText: 'Author',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              saveNewBook(
                context: context,
                title: controller.bookTitleController.text,
                author: controller.bookAuthorController.text,
              );
              controller.bookAuthorController.clear();
              controller.bookTitleController.clear();
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  saveNewBook(
      {required String title,
      required String author,
      required BuildContext context}) {
    if (title.trim().isNotEmpty && author.trim().isNotEmpty) {
      BookService.newBook(title: title, author: author)
          .then((value) => Get.snackbar(
                'Info',
                'Ebook create!',
                icon: const Icon(Icons.info),
              ))
          .catchError(
            (error) => Get.snackbar(
              'Error',
              'Cannot create an ebook!',
              icon: const Icon(Icons.error),
            ),
          );
    } else {
      Get.snackbar(
        'Error',
        'Please enter book title and author',
        icon: const Icon(Icons.error),
      );
    }
  }
}
