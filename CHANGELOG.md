## MecksUnit CHANGELOG

### Version 0.1.9 (April 19, 2020)

* Interpolate module attributes into mocked modules (thanks for reporting @Kintull)
* Ignore non-path arguments when running tests (thanks for reporting @hrubi)

### Version 0.1.8 (March 29, 2019)

* Fix extracting preserved mock functions (thanks for reporting @naag)

### Version 0.1.7 (March 9, 2019)

* Add ability to "preserve" mock module definitions through out test case using `preserve: true` (feature request by @aalepis)

### Version 0.1.6 (January 24, 2019)

* Tackle possible not mocked error when unloading modules

### Version 0.1.5 (January 22, 2019)

* Fix error when trying to mock functions with arity 0
* Register mocked functions at `MecksUnit.Server`
* Fix `ExCoveralls` related errors by unloading all mocked modules before calculating the test coverage (w00t!)

### Version 0.1.4 (January 22, 2019)

* Accept extra pattern match argument for mocked_test
* Improve efficiency when mocking modules

### Version 0.1.3 (January 21, 2019)

* Solve `:meck` related compile errors when using MecksUnit in multiple test files (yay! ^^)

### Version 0.1.2 (January 15, 2019)

* Add `called` and `assert_called` to assert function calls within (asynchronous) tests

### Version 0.1.1 (January 14, 2019) [RETIRED]

* This version is retired as the assertion of function calls (extracted from Mock) are not supported in asynchronous tests (forgot about that)

### Version 0.1.0 (January 12, 2019)

* Initial release
