import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/navigation_menu.dart';
import '../providers/products_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  // final String title;
  static const routeName = '/product-detail';

  const ProductDetailsScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String;
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);

    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(loadedProduct.title!),
        // ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(loadedProduct.title!),
                background: Hero(
                  tag: loadedProduct.id!,
                  child: Image.network(
                    loadedProduct.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(height: 10),
                  Text(
                    '\$${loadedProduct.price}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      loadedProduct.description!,
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(height: 800),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: const NavigationBarMenu(),
      ),
    );
  }
}
