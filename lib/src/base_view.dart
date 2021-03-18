import 'package:apn_state/src/base_state.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class BaseConsumerView<T extends BaseState> extends StatefulWidget {
  final Widget Function(BuildContext context, T model, Widget? child) builder;
  final T Function() create;

  BaseConsumerView({required this.create, required this.builder});

  @override
  _BaseConsumerViewState<T> createState() => _BaseConsumerViewState<T>();
}

class _BaseConsumerViewState<T extends BaseState> extends State<BaseConsumerView<T>> {
  late T model;

  @override
  void initState() {
    super.initState();
    model = widget.create();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (context) => model,
      child: Consumer<T>(builder: widget.builder),
    );
  }
}

class BaseSelectorView<T extends BaseState, O> extends StatefulWidget {
  final Widget Function(BuildContext context, O model, Widget? child) builder;
  final O Function(BuildContext, T) selector;
  final T Function() create;

  BaseSelectorView({
    required this.builder,
    required this.create,
    required this.selector,
  });

  @override
  _BaseSelectorViewState<T, O> createState() => _BaseSelectorViewState<T, O>();
}

class _BaseSelectorViewState<T extends BaseState, O> extends State<BaseSelectorView<T, O>> {
  late T model;

  @override
  void initState() {
    super.initState();
    model = widget.create();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (context) => model,
      child: Selector(
        selector: widget.selector,
        builder: widget.builder,
      ),
    );
  }
}
