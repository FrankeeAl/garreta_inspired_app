import 'package:flutter/material.dart';

import '../screens/cart_screen.dart';
import '../screens/edit_product_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/product_details_screen.dart';
import '../screens/products_overview_screen.dart';
import '../screens/user_product_screen.dart';

class NavigationBarMenu extends StatefulWidget {
  const NavigationBarMenu({Key? key}) : super(key: key);

  @override
  _NavigationBarMenuState createState() => _NavigationBarMenuState();
}

class _NavigationBarMenuState extends State<NavigationBarMenu> {
  int index = 0;
  final screens = const [
    ProductDetailsScreen(),
    OrdersScreen(),
    UserProductScreen(),
    EditProductScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: Theme.of(context).colorScheme.primaryVariant,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      child: NavigationBar(
        height: 60,
        backgroundColor: Theme.of(context).colorScheme.primary,
        selectedIndex: index,
        onDestinationSelected: (index) => setState(() {
          if (index == 0) {
            this.index = index;
            Navigator.of(context)
                .pushReplacementNamed(ProductsOverviewScreen.routeName);
          } else if (index == 1) {
            this.index = index;
            Navigator.of(context).pushReplacementNamed(CartScreen.routeName);
          } else if (index == 2) {
            this.index = index;
            Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
          } else {
            this.index = index;
            Navigator.of(context)
                .pushReplacementNamed(EditProductScreen.routeName);
          }
        }),
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart),
            label: 'My Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_shopping_cart),
            label: 'My Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_search),
            label: 'Products',
          ),
        ],
      ),
    );
  }
}
