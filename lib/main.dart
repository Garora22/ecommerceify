import 'dart:math';
import 'package:ecommerceify/CartItems.dart';
import 'package:flutter/material.dart';
import 'package:ecommerceify/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => provider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter APP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Product>> futureproduct;

  @override
  void initState() {
    super.initState();
    futureproduct = fetchProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Ecommerciefy"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_sharp),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartItems()),
              );
            },
            tooltip: 'Cart',
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: futureproduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Product> products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                Product product = products[index];
                bool isInCart =
                    Provider.of<provider>(context).cartlist.contains(product);
                String des = product.description.substring(
                    0, min(100, product.description.length));
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(product.title),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.network(
                                  product.image,
                                  width: 150,
                                  height: 150,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Description:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Price: \$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(product.description),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(45.0, 15.0, 45.0, 15.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: isInCart
                                ? Colors.green.withOpacity(1)
                                : Colors.grey.withOpacity(1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(product.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("$des...."),
                            const SizedBox(height: 8),
                            Text(
                              'Price: \$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        leading: Image.network(
                          product.image,
                          width: 70,
                          height: 270,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Consumer<provider>(
                              builder: (context, cartProvider, child) {
                                return ElevatedButton(
                                  onPressed: () {
                                    if (isInCart) {
                                      cartProvider.remove(product.id);
                                    } else {
                                      cartProvider.add(product);
                                    }
                                  },
                                  child:
                                      Text(isInCart ? 'Added' : 'Add to Cart'),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

Future<List<Product>> fetchProduct() async {
  final response =
      await http.get(Uri.parse('https://fakestoreapi.com/products'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    List<Product> products =
        data.map((json) => Product.fromJson(json)).toList();
    return products;
  } else {
    throw Exception('Failed to load products');
  }
}

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String image;
  final String category;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      price: json['price'],
      description: json['description'],
      image: json['image'],
      category: json['category'],
      id: json['id'],
      title: json['title'],
    );
  }
}
