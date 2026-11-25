import 'dart:io' show SocketException;

/// Mengecek apakah [error] merupakan [SocketException] pada platform IO.
bool isNetworkSocketException(Object error) => error is SocketException;
