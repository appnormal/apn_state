## [1.2.8] - 8 September 2020.

* Add ability to create a state object without resolving from get_it

## [1.2.7] - 6 September 2020.

* Remove print function call on error 

## [1.2.6] - 2 September 2020.

* Switch from pendantic to lint package for analysis
* Fix new lint issues

## [1.2.5] - 1 September 2020.

* Fix analysis errors
* Make listen function callback properly set the event type on the callback

## [1.2.2] - 21 August 2020.

* Bugfix
* Allow events to make use of the emit function in the state objects
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