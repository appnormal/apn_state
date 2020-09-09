import 'package:apn_state/apn_state.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main() {
  // Optionally register your states (you can also use create => T)
  GetIt.I.registerFactory(() => CounterState());

  // Run the app
  runApp(MyApp());
}

/// Make a class that holds your state variables
class CounterState extends BaseState<String> {
  int counter = 0;

  @override
  String convertError(e) {
    print(e);
    return 'Something went wrong';
  }
}

/// Update your state by using events
class IncrementCounterEvent extends BaseStateEvent<CounterState> {
  @override
  Future<void> handle() async {
    state.counter++;
    state.notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        builder: (context, child) {
          return BaseConsumerView<CounterState>(
            builder: (context, state, child) => Scaffold(
              appBar: AppBar(
                title: Text('State example'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'You have pushed the button this many times:',
                    ),
                    Text(
                      '${state.counter}',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => state.dispatch(IncrementCounterEvent()),
                child: Icon(Icons.add),
              ),
            ),
          );
        });
  }
}
