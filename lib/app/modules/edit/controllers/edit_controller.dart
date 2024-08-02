import 'dart:developer';

import 'package:ebook_builder/app/services/book_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

import '../../../data/models/book.dart';

class EditController extends GetxController {
  late Book book;

  TextEditingController chapterTitleController = TextEditingController();

  RxString title = ''.obs;

  RxInt chapterIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    book = Get.arguments;

    getBookById(book.id);
  }

  Future<void> getBookById(Id id) async {
    book = (await BookService.getBook(id: book.id))!;

    final chapters = book.chapters;
    log('total chapters = ${chapters.length}');
    title.value = book.title!;
    log('refresh');
    update(['chapter', 'content']);
  }

  Future<void> refreshContent() async {
    await getBookById(book.id);
  }
}
