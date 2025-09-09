import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Fruit Bill')),
        body: const BillScreen(),
      ),
    );
  }
}

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final List<Map<String, String>> items = [];

  void _createPDF() async {
    if (items.isEmpty) return;

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('FRUIT BILL', style: const pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 20),
              pw.Text('Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
              pw.SizedBox(height: 20),

              for (var item in items)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(item['name']!),
                    pw.Text('\$${item['price']}'),
                  ],
                ),

              pw.SizedBox(height: 20),
              pw.Text('Total: \$${_calculateTotal()}'),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  String _calculateTotal() {
    double total = 0;
    for (var item in items) {
      total += double.parse(item['price']!);
    }
    return total.toStringAsFixed(2);
  }

  void _addItem() {
    if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      setState(() {
        items.add({
          'name': _nameController.text,
          'price': _priceController.text,
        });
        _nameController.clear();
        _priceController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Input fields
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Fruit name'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Price'),
                ),
              ),
              IconButton(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Items list
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]['name']!),
                  trailing: Text('\$${items[index]['price']}'),
                );
              },
            ),
          ),

          // Total and button
          Text('Total: \$${_calculateTotal()}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _createPDF,
            child: const Text('Make PDF'),
          ),
        ],
      ),
    );
  }
}