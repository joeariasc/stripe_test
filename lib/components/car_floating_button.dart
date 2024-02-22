import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_test/pages/cart_page.dart';
import '../model/cart_model.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Accessing CartModel to determine if we need to show the dot
    var cartModel = Provider.of<CartModel>(context);
    bool showDot = cartModel.cartItems.isNotEmpty;

    return Stack(
      alignment:
          Alignment.topRight, // Adjust this to position the dot as needed
      children: [
        FloatingActionButton(
          backgroundColor:
              cartModel.cartItems.isNotEmpty ? Colors.black : Colors.grey,
          onPressed: cartModel.cartItems.isNotEmpty
              ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartPage(),
                    ),
                  )
              : null,
          child: const Icon(Icons.shopping_bag, color: Colors.white),
        ),
        if (showDot)
          Positioned(
            // You can adjust the position as needed
            top: 8,
            right: 8,
            child: Container(
              width: 12, // Dot size
              height: 12, // Dot size
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white,
                    width:
                        2), // White border around the dot for better visibility
              ),
            ),
          ),
      ],
    );
  }
}
