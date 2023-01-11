import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

enum ViewState { Idle, Busy }

abstract class BaseState<V> extends ChangeNotifier {
  static T of<T>(BuildContext context, {bool listen = true}) => Provider.of<T>(context, listen: listen);
  final _subscriptions = <StreamSubscription>[];

  bool isDisposed = false;

  bool enablePagination = true;

  ViewState _state = ViewState.Idle;
  V? error;

  ViewState get state => _state;

  bool get isLoading => state == ViewState.Busy;

  bool get hasError => error != null;

  V? convertError(dynamic e);

  /// Make sure to implement the super.dispose() when
  /// overriding this method
  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    isDisposed = true;
    super.dispose();
  }

  Future<T> dispatch<E extends BaseStateEvent, T extends BaseState>(
    E event,
  ) async {
    event.state = this;
    await event.handle();
    return event.state as T;
  }

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  /// We allow calling the notifyListeners on our state
  /// objects. So we publicly expose it (in stead of relying
  /// on the parents @protected)
  @override
  void notifyListeners() {
    if (isDisposed) return;
    super.notifyListeners();
  }

  /// Asynchronously handle the callback and automatically set the state loading.
  Future<T?> process<T>(ValueGetter<Future<T>> callback, [bool handleLoading = true]) async {
    // * Clear previous error
    error = null;
    T? response;

    try {
      if (handleLoading) setState(ViewState.Busy);
      response = await callback();
    } catch (e) {
      error = convertError(e);
    }

    if (handleLoading) setState(ViewState.Idle);
    return response;
  }
}

abstract class BaseStateEvent<S extends BaseState> {
  /// Allows access anywhere in the event
  /// without explicitly passing it around
  late S state;

  /// Handle the event
  Future<void> handle();
}
