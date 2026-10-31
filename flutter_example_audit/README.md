# Cleany acceptance artifacts

Open REPORT.md for the full assessment. The main app is ../flutter_example; the secondary direct-Dio provider fixture is dio_fixture.

- results.jsonl / cli_results.csv: individual CLI expectations, outputs and durations.
- summary.json: environment, generated entries and aggregate timings.
- runtime_results.jsonl: UAT/prod debug simulator build outcomes.
- logs/: CLI, analysis, unit, simulator, launch and packaging evidence. Older failing attempts are retained for transparency; files ending verified contain final passing tests.
- screenshots/: actual iPhone 17 Pro dev app capture.
- snapshots/: pre-demo generated source, registry and pre-workaround iOS configuration.
- fault_fixtures/: deliberately created unknown-state recovery data preserved by the safety test.
- demo_adjustments.json: example-specific edits; generator implementation was not changed.
- apply_icon_workaround.py: idempotent example-only fix for missing flavor icon catalogs.
- mock_api_server.py: synthetic loopback-only HTTP server for the simulator flows.

The suite_*.py scripts document a stateful acceptance sequence. They are not an idempotent command to run over an existing project. Their intentional edits, removal, interruption and reset steps apply only to the disposable example app. No production backend or database is involved.
