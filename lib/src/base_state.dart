import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

enum ViewState { Idle, Busy }

class BaseState extends ChangeNotifier {
  static T of<T>(BuildContext context, {bool listen = true}) => Provider.of<T>(context, listen: listen);

  ViewState _state = ViewState.Idle;
  ErrorResponse error;

  ViewState get state => _state;

  bool get isLoading => state == ViewState.Busy;

  bool get hasError => error != null;

  Future<T> dispatch<E extends BaseStateEvent<T>, T extends BaseState>(E event) async {
    event.state = this;
    await event.handle();
    return event.state;
  }

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  /// To shut up the invalid warning of "notifyListeners can only be called within the ChangeNotifier class"
  void notifyListeners() => super.notifyListeners();

  Future<T> apiCall<T>(ValueGetter<Future<T>> apiCall) async {
    // * Clear previous error
    error = null;

    try {
      setState(ViewState.Busy);
      return await apiCall();
    } on ErrorResponse catch (errorResponse) {
      error = errorResponse;
    } catch (e) {
      print(e);
      error = ErrorResponse.fromMessage("unknown");
    }
    setState(ViewState.Idle);
    return null;
  }
}

abstract class BaseStateEvent<S> {
  /// Allows access anywhere in the event
  /// without explicitly passing it around
  S state;

  /// Handle the event
  Future<void> handle();
}

// TODO ?
class ErrorResponse {
  int statusCode;
  String message;

  ErrorResponse({
    this.statusCode,
    this.message,
  });

  factory ErrorResponse.fromMessage(String message) => ErrorResponse(statusCode: 500, message: message);

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => new ErrorResponse(
        statusCode: json["error"] != null && json["error"]["status_code"] != null ? json["error"]["status_code"] : null,
        message: json["error"] != null && json["error"]["message"] != null ? json["error"]["message"] : null,
      );

  @override
  String toString() {
    return "ErrorResponse = $message";
  }
}
