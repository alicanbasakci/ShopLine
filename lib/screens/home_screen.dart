import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  final List<Product> cartItems;
  final List<Product> favoriteItems;
  final Function(Product) onAddToCart;
  final Function(Product) onToggleFavorite;
  final bool Function(Product) isFavorite;

  const HomeScreen({
    super.key,
    required this.cartItems,
    required this.favoriteItems,
    required this.onAddToCart,
    required this.onToggleFavorite,
    required this.isFavorite,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  List<Product> filtered = [];
  bool isLoading = true;
  String sortType = 'default';
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> categories = [
    {'label': 'Telefonlar', 'value': 'smartphones'},
    {'label': 'Laptoplar', 'value': 'laptops'},
    {'label': 'Tabletler', 'value': 'tablets'},
    {'label': 'Aksesuarlar', 'value': 'mobile-accessories'},
  ];

  String selectedCategory = 'smartphones';

  @override
  void initState() {
    super.initState();
    fetchProducts(selectedCategory);
  }

  Future<void> fetchProducts(String category) async {
    setState(() => isLoading = true);
    final response = await http.get(
      Uri.parse('https://dummyjson.com/products/category/$category?limit=20'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['products'];
      setState(() {
        products = list.map((e) => Product.fromJson(e)).toList();
        filtered = List.from(products);
        isLoading = false;
      });
    }
  }

  void applySort(String type) {
    setState(() {
      sortType = type;
      switch (type) {
        case 'price_asc':
          filtered.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_desc':
          filtered.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'name_asc':
          filtered.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'name_desc':
          filtered.sort((a, b) => b.title.compareTo(a.title));
          break;
        default:
          filtered = List.from(products);
      }
    });
  }

  void filterProducts(String query) {
    setState(() {
      filtered = products
          .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
      applySort(sortType);
    });
  }

  Widget _sortOption(BuildContext context, String type, String label, IconData icon) {
    final isSelected = sortType == type;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.indigo : Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.indigo : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.indigo) : null,
      onTap: () {
        Navigator.pop(context);
        applySort(type);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 50,
            ),
            const SizedBox(width: 8),
            const Text(
              'ShopLine',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              sortType != 'default' ? Icons.sort : Icons.sort_outlined,
              color: sortType != 'default' ? Colors.indigo : null,
            ),
            tooltip: 'Sırala',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sıralama',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _sortOption(context, 'default', 'Varsayılan', Icons.refresh),
                        _sortOption(context, 'price_asc', 'Fiyat: Ucuzdan Pahalıya', Icons.arrow_upward),
                        _sortOption(context, 'price_desc', 'Fiyat: Pahalıdan Ucuza', Icons.arrow_downward),
                        _sortOption(context, 'name_asc', 'İsim: A → Z', Icons.sort_by_alpha),
                        _sortOption(context, 'name_desc', 'İsim: Z → A', Icons.sort_by_alpha_outlined),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat['value'] == selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = cat['value']!;
                      searchController.clear();
                      sortType = 'default';
                    });
                    fetchProducts(cat['value']!);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.indigo : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        cat['label']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: TextField(
              controller: searchController,
              onChanged: filterProducts,
              decoration: InputDecoration(
                hintText: 'Ürün ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      childAspectRatio: MediaQuery.of(context).size.width > 600 ? 0.8 : 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: filtered[index],
                        onAddToCart: widget.onAddToCart,
                        onToggleFavorite: widget.onToggleFavorite,
                        isFavorite: widget.isFavorite(filtered[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}