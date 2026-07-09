import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:emkf_triage_app/core/theme/app_theme.dart';
import 'package:emkf_triage_app/features/triage/presentation/bloc/triage_bloc.dart';
import 'package:emkf_triage_app/features/triage/presentation/pages/triage_form_page.dart';
import 'package:emkf_triage_app/injection/injection_container.dart';

class TriageApp extends StatelessWidget {
  const TriageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TriageBloc>(),
      child: MaterialApp(
        title: 'EMKF Triage',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const TriageFormPage(),
      ),
    );
  }
}
