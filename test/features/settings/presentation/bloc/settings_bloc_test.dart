import 'package:flutter_test/flutter_test.dart';
import 'package:smart_univ/features/settings/presentation/bloc/settings_bloc.dart';

void main() {
  late SettingsBloc bloc;

  setUp(() {
    bloc = SettingsBloc();
  });

  tearDown(() => bloc.close());

  group('SettingsBloc', () {
    test('initial state is SettingsInitial', () {
      expect(bloc.state, isA<SettingsInitial>());
    });

    test('adding SettingsRequested does not throw', () {
      expect(
        () => bloc.add(const SettingsRequested()),
        returnsNormally,
      );
    });

    test('state remains SettingsInitial after SettingsRequested (stub)',
        () async {
      bloc.add(const SettingsRequested());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state, isA<SettingsInitial>());
    });
  });
}
