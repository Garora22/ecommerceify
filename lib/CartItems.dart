// ignore_for_file: prefer_const_constructors, file_names

import 'main.dart'; 
import 'package:flutter/material.dart';
import 'package:ecommerceify/provider.dart';
import 'package:provider/provider.dart';

// ignore: use_key_in_widget_constructors
class CartItemWidget extends StatelessWidget {
  final Product cartItem;
  final VoidCallback onRemove;

  const CartItemWidget({
    Key? key,
    required this.cartItem,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isInCart = Provider.of<provider>(context).cartlist.contains(cartItem);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          // Add your logic for tapping on a cart item if needed
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(45.0, 15.0, 45.0, 15.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: isInCart ? Colors.green.withOpacity(1) : Colors.grey.withOpacity(1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            title: Text(cartItem.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price: \$${cartItem.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            leading: Image.network(
              cartItem.image,
              width: 70,
              height: 70,
            ),
            trailing: IconButton(
              icon: Icon(Icons.remove_shopping_cart),
              onPressed: onRemove,
            ),
          ),
        ),
      ),
    );
  }
}

class CartItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart Items'),
      ),
      body: Consumer<provider>(
        builder: (context, cartProvider, child) {
          List<Product> cartItems = cartProvider.cartlist;

          if (cartItems.isEmpty) {
            return Center(
              child: Text('Your cart is empty.'),
            );
          }

          double totalAmount = cartItems.fold(
            0,
            (previousValue, element) => previousValue + element.price,
          );

          return ListView(
            children: [
              for (final cartItem in cartItems)
                CartItemWidget(
                  cartItem: cartItem,
                  onRemove: () {
                    cartProvider.remove(cartItem.id);
                  },
                ),
              SizedBox(
                height: 108, // Adjust the height as needed
                child: Card(
                  margin: EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Implement your checkout logic here
                          },
                          child: Text('Checkout'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}