import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_stream_provider.dart';
import '../models/order.dart' as ord;
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:ecommerce/providers/currency_provider.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    // Provider will automatically start streaming when accessed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = Provider.of<OrderStreamProvider>(context, listen: false);
      orderProvider.clearError();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.myOrders),
      ),
      body: Consumer<OrderStreamProvider>(
        builder: (context, orderProvider, child) {
          return StreamBuilder<List<ord.Order>>(
            stream: orderProvider.createOrdersStream(),
            builder: (context, snapshot) {
              // Handle loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(localization.loadingOrders),
                    ],
                  ),
                );
              }
              
              // Handle error state
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        localization.errorLoadingOrders,
                        style: TextStyle(fontSize: 18, color: Colors.red[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              final orders = snapshot.data ?? [];
              
              // Show empty state
              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, 
                        size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        localization.noOrders,
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Manual refresh orders
                          final orderProvider = Provider.of<OrderStreamProvider>(context, listen: false);
                          orderProvider.refreshOrders();
                        },
                        child: Text(localization.refresh),
                      ),
                    ],
                  ),
                );
              }
                      
              // Show orders list with pull-to-refresh
              return RefreshIndicator(
                onRefresh: () async {
                  // Manual refresh orders
                  final orderProvider = Provider.of<OrderStreamProvider>(context, listen: false);
                  await orderProvider.refreshOrders();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    Color statusColor;
                    IconData statusIcon;
                    String localizedStatus;

                    switch (order.status.toLowerCase()) {
                      case 'pending':
                        statusColor = Colors.orange;
                        statusIcon = Icons.hourglass_top_rounded;
                        localizedStatus = localization.pending;
                        break;
                      case 'processing':
                        statusColor = Colors.blueAccent;
                        statusIcon = Icons.sync_rounded;
                        localizedStatus = localization.processing;
                        break;
                      case 'shipped':
                        statusColor = Colors.green;
                        statusIcon = Icons.local_shipping_rounded;
                        localizedStatus = localization.shipped;
                        break;
                      case 'delivered':
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle_rounded;
                        localizedStatus = localization.delivered;
                        break;
                      case 'cancelled':
                        statusColor = Colors.redAccent;
                        statusIcon = Icons.cancel_rounded;
                        localizedStatus = localization.cancelled;
                        break;
                      default:
                        statusColor = Colors.grey;
                        statusIcon = Icons.info_outline_rounded;
                        localizedStatus = order.status;
                    }

                    return Dismissible(
                key: Key('order-${order.id}'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(localization.deleteConfirmation),
                        content: Text(localization.confirmDeleteOrder),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(localization.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              localization.delete,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) async {
                  // Delete the order using provider
                  final success = await orderProvider.deleteOrder(order.id);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localization.orderDeletedSuccess),
                        backgroundColor: Colors.green,
                        action: SnackBarAction(
                          label: localization.undo,
                          onPressed: () {
                            // Refresh to show all orders
                            orderProvider.refreshOrders();
                          },
                        ),
                      ),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localization.orderDeleteFailed),
                        backgroundColor: Colors.red,
                      ),
                    );
                    // Refresh to restore the order if deletion failed
                    orderProvider.refreshOrders();
                  }
                },
                background: Container(
                  color: Colors.red,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: statusColor.withValues(alpha: 0.15),
                              child: Icon(statusIcon, color: statusColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                localization.orderNumber(order.id.isNotEmpty
                                    ? order.id.substring(0, 6)
                                    : ''),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Text(
                              order.createdAt
                                  .toLocal()
                                  .toString()
                                  .substring(0, 10),
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.person,
                                size: 18, color: Colors.grey[700]),
                            const SizedBox(width: 6),
                            Text(order.name,
                                style: const TextStyle(fontSize: 14)),
                            const Spacer(),
                            Icon(Icons.phone,
                                size: 18, color: Colors.grey[700]),
                            const SizedBox(width: 6),
                            Text(order.phone,
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // New: Display Total Amount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localization.totalAmount,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: localization.localeName,
                                symbol: currencyProvider.currencyCode,
                                decimalDigits: 2,
                              ).format(order.total),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        // New: Display Delivery Cost
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localization
                                  .deliveryCost, // Assuming you have this string in your localization files
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[700]),
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: localization.localeName,
                                symbol: currencyProvider.currencyCode,
                                decimalDigits: 2,
                              ).format(currencyProvider.deliveryCost),
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        // New: Display Grand Total
                        const Divider(), // A visual separator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localization
                                  .grandTotal, // Assuming you have this string in your localization files
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple),
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: localization.localeName,
                                symbol: currencyProvider.currencyCode,
                                decimalDigits: 2,
                              ).format(
                                  order.total + currencyProvider.deliveryCost),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 18, color: Colors.grey[700]),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(order.address,
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black87)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(statusIcon,
                                      color: statusColor, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    localizedStatus,
                                    style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              localization.orderTotal(
                                  order.total.toStringAsFixed(2),
                                  currencyProvider.currencyCode),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.teal),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
