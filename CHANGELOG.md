## [1.2.1] - 21 August 2020.

* Allow events to make use of the emit function in the state objects

## [1.2.0] - 21 August 2020.

* Make listen and emit protected (force them to be used within a state class)
* Add example usage
* Add a few comments

## [1.1.1] - 12 August 2020.

* Fix missing generic pass to EvenBus that generated a `CastStreamSubscription` when using BaseState.listen

## [1.1.0] - 12 August 2020.

* Make Eventbus private and only expose listen and on methods to enforce intended use
* Fix a wierd error in generics on Flutter 1.20.*

## [1.0.0] - 1 July 2020.

* A new Appnormal flutter package, providing state management based on Flutter Provider and Event Bus for state to state communication.