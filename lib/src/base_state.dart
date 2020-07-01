import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

enum ViewState { Idle, Busy }

abstract class BaseState<V> extends ChangeNotifier {
  static T of<T>(BuildContext context, {bool listen = true}) => Provider.of<T>(context, listen: listen);

  ViewState _state = ViewState.Idle;
  V error;

  ViewState get state => _state;

  bool get isLoading => state == ViewState.Busy;

  bool get hasError => error != null;

  V convertError(dynamic e);

  Future<T> dispatch<E extends BaseStateEvent<T>, T extends BaseState<V>>(E event) async {
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

  Future<T> process<T>(ValueGetter<Future<T>> callback) async {
    // * Clear previous error
    error = null;
    T response;

    try {
      setState(ViewState.Busy);
      response = await callback();
    } catch (e) {
      print(e);
      error = convertError(e);
    }
    setState(ViewState.Idle);
    return response;
  }
}

abstract class BaseStateEvent<S> {
  /// Allows access anywhere in the event
  /// without explicitly passing it around
  S state;

  /// Handle the event
  Future<void> handle();
}
