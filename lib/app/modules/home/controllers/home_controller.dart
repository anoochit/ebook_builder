import 'package:ebook_builder/app/data/models/book.dart';
import 'package:ebook_builder/app/services/book_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final TextEditingController bookTitleController = TextEditingController();
  final TextEditingController bookAuthorController = TextEditingController();

  RxList<Book> listBook = <Book>[].obs;

  late Stream<List<Book>> bookStream;

  @override
  void onInit() {
    super.onInit();
    bookInitStream();
    getBooks();
  }
  
  void bookInitStream() {
    bookStream = BookService.bookStream();
    bookStream.listen((book) {
      listBook.value = book;
    });
  }

  void getBooks() {
    BookService.getBooks().then((books) => listBook.value = books);
  }
}
