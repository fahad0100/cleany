# Cleany example

Run `dart run example/cleany_example.dart` from the package checkout. It creates
a disposable Flutter manifest, prepares an initialization plan, prints a short
file summary, and cleans up. It neither runs Flutter commands nor applies changes
to an existing application.

For the interactive workflow, activate the package and run `cleany` in a Flutter
project. Choose 7 to initialize, 1 to create a feature, select Cubit/Bloc, and
choose a location. For custom fields, enter a count, then `name:type:jsonKey`
and y/n nullability for each field. Review and choose 1 to apply and validate.

See the [complete menu guide](../README.md#menu-guide) for every action and the
[usage walkthrough](../doc/USAGE_AR.md) for a guided example.
