import 'dart:async';

import 'package:apn_state/src/event_bus.dart';
import 'package:apn_state/src/event_bus_event.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

enum ViewState { Idle, Busy }

abstract class BaseState<V> extends ChangeNotifier {
  static T of<T>(BuildContext context, {bool listen = true}) => Provider.of<T>(context, listen: listen);
  final _subscriptions = <StreamSubscription>[];

  ViewState _state = ViewState.Idle;
  V error;

  ViewState get state => _state;

  bool get isLoading => state == ViewState.Busy;

  bool get hasError => error != null;

  V convertError(dynamic e);

  /// Emit an event that can be picked up by all other states
  @protected
  void emit(EventBusEvent event) => EventBus.emit(event);

  /// Listen to a specific type of event. This automatically closes
  /// the listener when the state is disposed
  @protected
  StreamSubscription<T> listen<T extends EventBusEvent>(void onListen(T)) {
    final subscription = EventBus.on<T>(onListen);
    _subscriptions.add(subscription);
    return subscription;
  }

  /// Make sure to implement the super.dispose() when
  /// overriding this method
  @override
  void dispose() {
    _subscriptions.forEach((sub) => sub.cancel());
    super.dispose();
  }

  Future<T> dispatch<E extends BaseStateEvent, T extends BaseState>(E event) async {
    event.state = this;
    await event.handle();
    return event.state;
  }

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  /// We allow calling the notifyListeners on our state
  /// objects. So we publicly expose it (in stead of relying
  /// on the parents @protected)
  void notifyListeners() => super.notifyListeners();

  /// Asynchronously handle the callback and automatically set the state loading.
  Future<T> process<T>(ValueGetter<Future<T>> callback, [handleLoading = true]) async {
    // * Clear previous error
    error = null;
    T response;

    try {
      if (handleLoading) setState(ViewState.Busy);
      response = await callback();
    } catch (e) {
      print(e);
      error = convertError(e);
    }

    if (handleLoading) setState(ViewState.Idle);
    return response;
  }
}

abstract class BaseStateEvent<S extends BaseState> {
  /// Allows access anywhere in the event
  /// without explicitly passing it around
  S state;

  /// Handle the event
  Future<void> handle();

  /// Emit an event that can be picked up by all other states
  @protected
  void emit(EventBusEvent event) => state.emit(event);

  /// Listen to a specific type of event. This automatically closes
  /// the listener when the state is disposed
  @protected
  StreamSubscription<T> listen<T extends EventBusEvent>(void onListen(T)) => state.listen(onListen);
}
