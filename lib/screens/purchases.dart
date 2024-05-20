import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

const List<String> testID = ['test_id', "test_id2"];

class Purchase extends StatefulWidget {
  const Purchase({Key? key}) : super(key: key);

  @override
  _PurchaseState createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase> {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  StreamSubscription? _subscription;

  Future<void> _initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (_isAvailable) {
      await _getUserProducts();
      // await _getPastPurchases();
      _verifyPurchases();
      _subscription = _iap.purchaseStream.listen((data) => setState(() {
            _purchases.addAll(data);
            _verifyPurchases();
          }));
    }
  }

  Future<void> _getUserProducts() async {
    Set<String> ids = Set.from(testID);
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    setState(() {
      _products = response.productDetails;
    });
  }

  PurchaseDetails _findPurchase(String productID) {
    return _purchases.firstWhere(
      (purchase) => purchase.productID == productID,
      orElse: () => PurchaseDetails(
        purchaseID: '',
        productID: '',
        status: PurchaseStatus.error,
        transactionDate: null,
        verificationData: PurchaseVerificationData(
          localVerificationData: '',
          serverVerificationData: '',
          source: '',
        ),
      ),
    );
  }

  PurchaseDetails _hasUserPurchased(String productID) {
    final purchase = _findPurchase(productID);
    if (purchase.status == PurchaseStatus.purchased) {
      return purchase;
    }
    return PurchaseDetails(
      purchaseID: '',
      productID: '',
      status: PurchaseStatus.error,
      transactionDate: null,
      verificationData: PurchaseVerificationData(
        localVerificationData: '',
        serverVerificationData: '',
        source: '',
      ),
    );
  }

  void _verifyPurchases() {
    // Loop through each product ID in testID
    for (String productID in testID) {
      PurchaseDetails purchase = _hasUserPurchased(productID);

      // If a purchase is found for the current product
      if (purchase.status == PurchaseStatus.purchased) {
        // Show SnackBar indicating plan purchased
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan Purchased'),
          ),
        );
      }
    }
  }

  void _buyProduct(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: false);
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void dispose() {
    _subscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_isAvailable ? 'Product Available' : 'No Product Available'),
      ),
      body: Center(
        child: Column(
          children: _products.map((product) {
            final hasPurchased = _hasUserPurchased(product.id).status ==
                PurchaseStatus.purchased;

            return Card(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 8, left: 8, right: 8, bottom: 15),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    const CircleAvatar(
                      child: Icon(Icons.shopping_cart),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    if (hasPurchased) ...[
                      Text(
                        product.description,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ] else ...[
                      Text(
                        product.title,
                      ),
                      Text(product.description),
                      Text(
                        product.price,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text("Validity 1 Month"),
                      ListTile(
                        leading: const Icon(
                          Icons.check_box_rounded,
                          color: Colors.green,
                        ),
                        title: Text(product.description),
                      ),
                      ElevatedButton(
                        onPressed: () => _buyProduct(product),
                        child: const Text('Buy'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
