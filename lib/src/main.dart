import 'package:cryptonic/src/presentation/screens/crypto_list_screen.dart';
import 'package:cryptonic/src/utils/resources/router/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'presentation/blocs/crypto_list_bloc/crypto_bloc.dart';
import 'presentation/blocs/crypto_preview_bloc/crypto_preview_bloc.dart';
import 'presentation/blocs/crypto_selected_bloc/crypto_selected_bloc.dart';
import 'presentation/blocs/crypto_swap_bloc/crypto_swap_data_bloc.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = MainNavigation();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CryptoBloc()..add(OnFetch(currencyCode: "usd")),
        ),
        BlocProvider(
          create: (context) => CryptoPreviewBloc(),
        ),
        BlocProvider(
          create: (context) => CryptoSelectedBloc(),
        ),
        BlocProvider(
          create: (context) => CryptoSwapDataBloc(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(376, 812),
        builder: (context, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: CryptoListScreen(),
          onGenerateRoute: navigation.onGenerateRoute,
        ),
      ),
    );
  }
}
