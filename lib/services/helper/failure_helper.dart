
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:team_work_project/services/helper/status_code.dart';
import '../error/exceptions.dart';
import '../error/log.dart';


class FailersHelper {
  static ServerException dynamicDioError(DioException error, int statusCode) {
    var message = "";
    var code = 0;

    if(error.response != null) {
      Map<String, dynamic> jsonData = jsonDecode(error.response.toString());
      Log.i("jsonData-- $jsonData");
      message = jsonData['message'];
      code = statusCode;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return FetchDataException(message,code);



      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case StatusCode.badRequest:
            return BadRequestException(message,code);
          case StatusCode.unautherized:
            return UnauthorizedException(message,code);
          case StatusCode.forbidden:
            return UnauthorizedException(message,code);
          case StatusCode.notFound:
            return NotFoundException(message,code);

          case StatusCode.serverFailure:
            return InternalServerErrorException(message,code);

          case StatusCode.unprocessable:
            return UnprocessableError(message,code);

          default:
            return UndefiendErrorException(message,code);
        }
      case DioExceptionType.cancel:
        return UndefiendErrorException(message,code);
      case DioExceptionType.unknown:
        return NoInternetConnectionException("No Internet Connection");
      default:
        return NoInternetConnectionException("No Internet Connection");
    }
  }

  static String getErroMessageFromDioErro({required DioException dioError}) {
    if (dioError.response?.statusCode == 404) {
      return
        // LocaleHelper.transate(
        //   mainNavKey.currentContext!,
          "request not found";
      // )!;
    } else if (dioError.type == DioExceptionType.connectionTimeout ||
        dioError.type == DioExceptionType.sendTimeout ||
        dioError.type == DioExceptionType.receiveTimeout) {
      return
        // LocaleHelper.transate(
        //   mainNavKey.currentContext!,
            "time_exception";
        // )!;
    }

    return 'not found';
  }

  static String mapFailureToMessage({required ServerException failure}) {
    // return LocaleHelper.transate(
    //         mainNavKey.currentContext!, failure.message!) ??
        return failure.message!;
  }
}
