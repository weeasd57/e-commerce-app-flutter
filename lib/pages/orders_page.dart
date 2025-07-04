import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    // Fetch orders when the page is initialized
    Future.microtask(() => Provider.of<OrderProvider>(context, listen: false).fetchOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.orders.isEmpty) {
            return const Center(child: Text('لا توجد طلبات بعد.'));
          }

          return ListView.builder(
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
              Color statusColor;
              IconData statusIcon;
              switch (order.status.toLowerCase()) {
                case 'pending':
                  statusColor = Colors.orange;
                  statusIcon = Icons.hourglass_top_rounded;
                  break;
                case 'processing':
                  statusColor = Colors.blueAccent;
                  statusIcon = Icons.sync_rounded;
                  break;
                case 'shipped':
                  statusColor = Colors.green;
                  statusIcon = Icons.local_shipping_rounded;
                  break;
                case 'cancelled':
                  statusColor = Colors.redAccent;
                  statusIcon = Icons.cancel_rounded;
                  break;
                default:
                  statusColor = Colors.grey;
                  statusIcon = Icons.info_outline_rounded;
              }
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: statusColor.withOpacity(0.15),
                            child: Icon(statusIcon, color: statusColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'طلب رقم: ${order.id.isNotEmpty ? order.id.substring(0, 6) : ''}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Text(
                            order.createdAt.toLocal().toString().substring(0, 10),
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.person, size: 18, color: Colors.grey[700]),
                          const SizedBox(width: 6),
                          Text(order.name, style: const TextStyle(fontSize: 14)),
                          const Spacer(),
                          Icon(Icons.phone, size: 18, color: Colors.grey[700]),
                          const SizedBox(width: 6),
                          Text(order.phone, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 18, color: Colors.grey[700]),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(order.address, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(statusIcon, color: statusColor, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  order.status,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'الإجمالي: ${order.total.toStringAsFixed(2)} ج.م',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.teal),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
