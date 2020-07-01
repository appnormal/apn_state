import 'dart:async';

/// Primarily used for inter state (state2state) communication
class EventBus {
  StreamController<BaseEvent> _controller = StreamController<BaseEvent>.broadcast();

  /// Destroy this [EventBus]. This is generally only in a testing context.
  ///
  static void dispose() => _instance._dispose();

  /// Emits a new event on the event bus with the specified [event].
  ///
  static void emit(BaseEvent event) => _instance._controller.add(event);

  /// Listens for events of Type [T] and its subtypes.
  ///
  /// The method is called like this: NotificationService.on<MyType>();
  ///
  /// If the method is called without a type parameter, the [Stream] contains every
  /// event of this [EventBus].
  ///
  /// The returned [Stream] is a broadcast stream so multiple subscriptions are
  /// allowed.
  ///
  /// Each listener is handled independently, and if they pause, only the pausing
  /// listener is affected. A paused listener will buffer events internally until
  /// unpaused or canceled. So it's usually better to just cancel and later
  /// subscribe again (avoids memory leak).
  ///
  static StreamSubscription<T> on<T extends BaseEvent>(void onListen(T)) {
    Stream<BaseEvent> stream;
    if (T == dynamic) {
      stream = _instance._controller.stream;
    } else {
      stream = _instance._controller.stream.where((event) => event is T).cast<T>();
    }
    return stream.listen(onListen, onError: (e) => print(e));
  }

  EventBus._();

  static final EventBus _instance = EventBus._();

  void _dispose() => _controller.close();
}

class BaseEvent {}
