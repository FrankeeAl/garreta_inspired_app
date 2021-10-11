import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products_provider.dart';
import '../widgets/navigation_menu.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);
  static const routeName = "/edit-product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // ignore: prefer_final_fields
  var _editProduct = Product(
    id: null,
    description: '',
    title: '',
    price: 0,
    imageUrl: '',
  );
  var isInit = true;
  var _isLoading = false;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String?;
      if (productId != null) {
        _editProduct =
            Provider.of<Products>(context, listen: false).findById(productId);

        _initValues = {
          'title': _editProduct.title!,
          'description': _editProduct.description!,
          'price': _editProduct.price.toString(),
          // 'imageUrl': _editProduct.imageUrl!,
          'imageUrl': '',
        };
        _imageUrlController.text = _editProduct.imageUrl!;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editProduct.id!, _editProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editProduct);
      } catch (e) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('An error occured!'),
            content: const Text(
              'Something unexpected happened.',
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Okay'),
              ),
            ],
          ),
        );
      }
      // } finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _saveForm();
              // Navigator.of(context).pushNamed(UserProductScreen.routeName);
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: const InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) => {
                        _editProduct = Product(
                          title: value,
                          price: _editProduct.price,
                          description: _editProduct.description,
                          imageUrl: _editProduct.imageUrl,
                          id: _editProduct.id,
                          isFavourite: _editProduct.isFavourite,
                        ),
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Ooops empty field!';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: const InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onSaved: (value) => {
                        _editProduct = Product(
                          title: _editProduct.title,
                          price: double.parse(value!),
                          description: _editProduct.description,
                          imageUrl: _editProduct.imageUrl,
                          id: _editProduct.id,
                          isFavourite: _editProduct.isFavourite,
                        ),
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Ooops! empty field!';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ooops! try a valid price.';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Ooops! not a valid price.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      focusNode: _descriptionFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) => {
                        _editProduct = Product(
                          title: _editProduct.title,
                          price: _editProduct.price,
                          description: value,
                          imageUrl: _editProduct.imageUrl,
                          id: _editProduct.id,
                          isFavourite: _editProduct.isFavourite,
                        ),
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Ooops empty field!';
                        }
                        if (value.length <= 10) {
                          return 'Ooops! Too short to be a catchy description.';
                        }
                        return null;
                      },
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(top: 8, right: 14),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? const Text('Enter a URL')
                              : Image.network(
                                  _imageUrlController.text,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) => {_saveForm()},
                            onSaved: (value) => {
                              _editProduct = Product(
                                title: _editProduct.title,
                                price: _editProduct.price,
                                description: _editProduct.description,
                                imageUrl: value,
                                id: _editProduct.id,
                                isFavourite: _editProduct.isFavourite,
                              ),
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Ooops empty field!';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const NavigationBarMenu(),
    );
  }
}
