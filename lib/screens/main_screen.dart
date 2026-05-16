import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';
import 'account_screen.dart';
import '../models/product.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Product> cartItems = [];
  List<Product> favoriteItems = [];

  void addToCart(Product product) {
    setState(() => cartItems.add(product));
  }

  void removeFromCart(Product product) {
    setState(() => cartItems.remove(product));
  }

  void toggleFavorite(Product product) {
    setState(() {
      if (favoriteItems.any((p) => p.id == product.id)) {
        favoriteItems.removeWhere((p) => p.id == product.id);
      } else {
        favoriteItems.add(product);
      }
    });
  }

  bool isFavorite(Product product) {
    return favoriteItems.any((p) => p.id == product.id);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        cartItems: cartItems,
        favoriteItems: favoriteItems,
        onAddToCart: addToCart,
        onToggleFavorite: toggleFavorite,
        isFavorite: isFavorite,
      ),
      FavoritesScreen(
        favoriteItems: favoriteItems,
        onToggleFavorite: toggleFavorite,
        onAddToCart: addToCart,
      ),
      CartScreen(
        cartItems: cartItems,
        onRemove: removeFromCart,
      ),
      const AccountScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: favoriteItems.isNotEmpty,
              label: Text('${favoriteItems.length}'),
              child: const Icon(Icons.favorite_outline),
            ),
            activeIcon: const Icon(Icons.favorite),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: cartItems.isNotEmpty,
              label: Text('${cartItems.length}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: const Icon(Icons.shopping_cart),
            label: 'Sepet',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Hesap',
          ),
        ],
      ),
    );
  }
}