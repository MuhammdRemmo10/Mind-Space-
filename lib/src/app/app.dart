import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_picker/country_picker.dart';

import '../core/di/service_locator.dart';
import '../core/localization/generated/app_localizations.dart';
import '../core/localization/l10n_extensions.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/presentation/cubit/locale_cubit.dart';
import '../features/settings/presentation/cubit/theme_cubit.dart';
import '../features/splash/presentation/pages/splash_page.dart';

class MindSpaceApp extends StatelessWidget {
  const MindSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<ThemeCubit>()),
          BlocProvider(create: (_) => sl<LocaleCubit>()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return BlocBuilder<LocaleCubit, Locale?>(
              builder: (context, locale) {
                return MaterialApp(
                  onGenerateTitle: (context) => context.l10n.appName,
                  debugShowCheckedModeBanner: false,
                  locale: locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localeResolutionCallback: (deviceLocale, supportedLocales) {
                    if (deviceLocale == null) {
                      return const Locale('tr');
                    }

                    for (final supportedLocale in supportedLocales) {
                      if (supportedLocale.languageCode ==
                          deviceLocale.languageCode) {
                        return supportedLocale;
                      }
                    }

                    return const Locale('tr');
                  },
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    CountryLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  themeMode: themeMode,
                  theme: AppTheme.light(),
                  darkTheme: AppTheme.dark(),
                  home: child ?? const SplashPage(),
                );
              },
            );
          },
        ),
      ),
      child: const SplashPage(),
    );
  }
}
