// Creates presentation widgets and owns their Cubit/Bloc providers.
// Presentation factories are wired here, keeping the router independent of
// controllers and data-layer implementation details.
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../core/localization/generated/app_localizations.dart';

import 'package:test_cleany_dio/features/probe/presentation/pages/probe_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_cleany_dio/features/probe/presentation/bloc/probe_bloc.dart';
import 'package:test_cleany_dio/features/probe/presentation/bloc/probe_event.dart';

/// Creates presentation widgets and owns their Cubit/Bloc providers.
class FeaturePages {
  FeaturePages._();
  static Widget placeholder(GetIt container) => Builder(
    builder: (context) =>
        Center(child: Text(AppLocalizations.of(context).welcome)),
  );

  static Widget probe(GetIt container) => BlocProvider<ProbeBloc>(
    create: (_) => container<ProbeBloc>()..add(const ProbeEvent.requested()),
    child: const ProbePage(),
  );
}
