import 'package:equatable/equatable.dart';

class CacheException implements Exception {}

class ServerException extends Equatable implements Exception {
  final String? message;
  final int? code;

  const ServerException([this.message,this.code]);

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return '$message';
  }
}

class FetchDataException extends ServerException {
  const FetchDataException([message,code]) : super(message,code);
}

class BadRequestException extends ServerException {
  const BadRequestException([message,code]) : super(message,code);
}


class UnauthorizedException extends ServerException {
  const UnauthorizedException([message,code]) : super(message,code);
}

class NotFoundException extends ServerException {
  const NotFoundException([message,code]) : super(message,code);
}

class ConflictException extends ServerException {
  const ConflictException([message,code]) : super(message,code);
}

class InternalServerErrorException extends ServerException {
  const InternalServerErrorException([message,code]) : super(message,code);
}

class UndefiendErrorException extends ServerException {
  const UndefiendErrorException([message,code]) : super(message,code);
}

class NoInternetConnectionException extends ServerException {
  const NoInternetConnectionException([message,code]) : super(message,code);
}

//422Unprocessable Entity
class UnprocessableError extends ServerException {
  const UnprocessableError([message,code]) : super(message,code);
}