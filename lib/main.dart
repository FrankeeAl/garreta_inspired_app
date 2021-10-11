import 'package:flutter/material.dart';
import 'package:garreta_v1/helpers/custom_route.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/orders.dart';
import '../screens/cart_screen.dart';
import '../screens/product_details_screen.dart';
import '../screens/products_overview_screen.dart';
import '../providers/products_provider.dart';
import '../screens/orders_screen.dart';
import '../screens/user_product_screen.dart';
import 'screens/auth_screen.dart';
import '../widgets/splash_screen.dart';
import '../screens/edit_product_screen.dart';
import '../providers/auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products?>(
          create: (_) => null,
          update: (ctx, auth, previousProducts) => Products(
            auth.token,
            previousProducts == null ? [] : previousProducts.items,
            auth.userId,
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders?>(
          create: (_) => null,
          update: (ctx, auth, previousOrders) => Orders(
            auth.token,
            previousOrders == null ? [] : previousOrders.orders,
            auth.userId,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Garreta',
          theme: ThemeData(
            primaryColor: const Color.fromRGBO(43, 69, 96, 1),
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(43, 69, 96, 10),
              secondary: Color.fromRGBO(47, 109, 128, 10),
              primaryVariant: Color.fromRGBO(106, 164, 176, 10),
              secondaryVariant: Color.fromRGBO(225, 231, 224, 10),
              background: Color.fromRGBO(220, 240, 224, 10),
              onPrimary: Colors.white70,
            ),
            iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.primary,
              opacity: 0.5,
            ),
            canvasColor: const Color.fromRGBO(225, 231, 224, 10),
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder(),
            }),
          ),
          home: auth.isAuth
              ? const ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          //home: const ProductsOverviewScreen(),
          routes: {
            ProductsOverviewScreen.routeName: (ctx) =>
                const ProductsOverviewScreen(),
            ProductDetailsScreen.routeName: (ctx) =>
                const ProductDetailsScreen(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            UserProductScreen.routeName: (ctx) => const UserProductScreen(),
            EditProductScreen.routeName: (ctx) => const EditProductScreen(),
            AuthScreen.routeName: (ctx) => const AuthScreen(),
          },
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
