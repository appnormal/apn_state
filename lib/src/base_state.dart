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

  void emit(EventBusEvent event) => EventBus.emit(event);
  StreamSubscription<T> listen<T extends EventBusEvent>(void onListen(T)) {
     final subscription = EventBus.on(onListen);
     _subscriptions.add(subscription);
     return subscription;
  }

  @override
  void dispose(){
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
