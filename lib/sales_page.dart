import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';  // Importa el paquete intl para formatear la fecha y hora

class SalesPage extends StatefulWidget {
  SalesPage({required this.title, required this.username});

  final String title;
  final String username;

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  List<Map<String, dynamic>> _suggestions = [];
  List<Map<String, dynamic>> _selectedItems = [];
  List<Map<String, dynamic>> _sales = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isLoading = false;
  bool _isSalesVisible = false;

  Future<void> _searchMenu(String query) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse('http://localhost:5000/search_menu?query=$query'));

    if (response.statusCode == 200) {
      setState(() {
        _suggestions = List<Map<String, dynamic>>.from(json.decode(response.body));
        _isSearching = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load suggestions')),
      );
    }
  }

  void _selectItem(Map<String, dynamic> item) {
    setState(() {
      _selectedItems.add(item);
      _suggestions.remove(item);
      _searchController.clear();
    });
  }

  Future<void> _createSale() async {
    setState(() {
      _isLoading = true;
    });

    final items = _selectedItems.map((item) => {
          'name': item['name'],
          'quantity': 1,
          'price': item['price'],
        }).toList();

    // Obtener la hora local del dispositivo
    final localTime = DateTime.now().toIso8601String();

    final response = await http.post(
      Uri.parse('http://localhost:5000/sales'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'items': items,
        'username': widget.username,
        'timestamp': localTime // Enviar la hora local
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Venta registrada')),
      );
      setState(() {
        _selectedItems.clear();
        _isLoading = false;
      });
      _fetchSales(); // Actualizar la lista de ventas después de crear una nueva venta
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create sale: ${response.body}')),
      );
    }
  }

  Future<void> _fetchSales() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse('http://localhost:5000/sales'));

    if (response.statusCode == 200) {
      final salesData = List<Map<String, dynamic>>.from(json.decode(response.body));
      print('Sales Data: $salesData');  // Registrar la respuesta del servidor
      setState(() {
        _sales = salesData;
        _isSalesVisible = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load sales: ${response.body}')),
      );
    }
  }

  void _closeSales() {
    setState(() {
      _isSalesVisible = false;
      _sales.clear();
    });
  }

  double getPrice(Map<String, dynamic> item) {
    final price = item['price'];
    if (price is double) {
      return price;
    } else if (price is int) {
      return price.toDouble();
    } else if (price is String) {
      return double.tryParse(price) ?? 0.0;
    } else {
      return 0.0;
    }
  }

  String formatDateTime(DateTime dateTime) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    return '${dateFormat.format(dateTime)} ${timeFormat.format(dateTime)}';
  }

  double calculateTotalDailySales(List<Map<String, dynamic>> sales) {
    final today = DateTime.now().toLocal().toString().split(' ')[0];
    return sales
        .where((sale) {
          final saleDate = sale['timestamp'] != null
              ? DateTime.parse(sale['timestamp']).toLocal().toString().split(' ')[0]
              : '';
          return saleDate == today;
        })
        .fold(0.0, (sum, sale) {
          final totalPrice = sale['total_price'] ?? 0.0;
          final doublePrice = totalPrice is double
              ? totalPrice
              : (totalPrice is String ? double.tryParse(totalPrice) ?? 0.0 : 0.0);
          return sum + doublePrice;
        });
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _addNewItem() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nuevo Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre del Item'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Precio del Item'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text;
                final priceStr = priceController.text;
                final price = double.tryParse(priceStr);

                if (name.isEmpty || price == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All fields are required')),
                  );
                  return;
                }

                final response = await http.post(
                  Uri.parse('http://localhost:5000/add_item'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'name': name, 'price': price}),
                );

                if (response.statusCode == 201) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Item added successfully')),
                  );
                  _searchMenu(name); // Actualizar las sugerencias con el nuevo item
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add item: ${response.body}')),
                  );
                }

                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF007AFF); // Color azul característico de Apple
    final textFieldBackground = Color(0xFFFFFFFF); // Fondo blanco para inputs
    final textColor = Colors.black; // Texto negro

    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Image.asset(
            'assets/images/bandeja_paisa.jpg', // Ruta de la imagen
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5), // Capa de oscuridad para mejorar la legibilidad
            ),
          ),
          Center(
            child: Container(
              width: 600, // Ancho fijo para un diseño centrado y más grande
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9), // Fondo blanco semitransparente
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.add, color: primaryColor, size: 32),
                        onPressed: _addNewItem,
                        tooltip: 'Nuevo Item',
                      ),
                      Spacer(),
                      if (_isSalesVisible)
                        IconButton(
                          icon: Icon(Icons.close, color: textColor),
                          onPressed: _closeSales,
                        ),
                    ],
                  ),
                  if (_isSearching)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar plato',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: textFieldBackground,
                              prefixIcon: Icon(Icons.search, color: Colors.grey),
                            ),
                            onChanged: (value) {
                              _searchMenu(value);
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: textColor),
                          onPressed: () {
                            setState(() {
                              _isSearching = false;
                              _searchController.clear();
                              _suggestions.clear();
                            });
                          },
                        ),
                      ],
                    ),
                  if (!_isSearching)
                    IconButton(
                      icon: Icon(Icons.search, color: textColor),
                      onPressed: () {
                        setState(() {
                          _isSearching = true;
                        });
                      },
                    ),
                  if (_suggestions.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_suggestions[index]['name'], style: TextStyle(color: textColor)),
                            subtitle: Text('Precio: ${_suggestions[index]['price']}', style: TextStyle(color: Colors.grey)),
                            onTap: () {
                              _selectItem(_suggestions[index]);
                            },
                          );
                        },
                      ),
                    ),
                  if (_selectedItems.isNotEmpty)
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: _selectedItems.length,
                              itemBuilder: (context, index) {
                                final item = _selectedItems[index];
                                return ListTile(
                                  title: Text(item['name'], style: TextStyle(color: textColor)),
                                  subtitle: Text('Precio: ${item['price']}', style: TextStyle(color: Colors.grey)),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.grey),
                                    onPressed: () {
                                      setState(() {
                                        _selectedItems.removeAt(index);
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total:', style: TextStyle(color: textColor)),
                              Text(
                                'COP ${_selectedItems.fold<double>(0.0, (sum, item) => sum + getPrice(item)).toStringAsFixed(2)}',
                                style: TextStyle(color: textColor),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _selectedItems.isNotEmpty ? _createSale : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor, // Color del botón
                              foregroundColor: Colors.white, // Color del texto
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Bordes redondeados
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            ),
                            child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Crear Venta'),
                          ),
                        ],
                      ),
                    ),
                  if (_isSalesVisible)
                    Expanded(
                      child: Column(
                        children: [
                          if (_sales.isNotEmpty)
                            ListTile(
                              title: Text('Total del día', style: TextStyle(color: textColor)),
                              subtitle: Text(
                                'COP ${calculateTotalDailySales(_sales).toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _sales.length,
                              itemBuilder: (context, index) {
                                final sale = _sales[index];
                                final formattedDateTime =
                                    sale['timestamp'] != null
                                        ? formatDateTime(DateTime.parse(sale['timestamp']))
                                        : 'Fecha desconocida';
                                return ListTile(
                                  title: Text(sale['item'] ?? 'Plato desconocido', style: TextStyle(color: textColor)),
                                  subtitle: Text(
                                    'Usuario: ${sale['username'] ?? 'Usuario desconocido'}, '
                                    'Cantidad: ${sale['quantity'] ?? 0}, '
                                    'Precio: ${(sale['price'] ?? 0.0).toStringAsFixed(2)}, '
                                    'Total: ${(sale['total_price'] ?? 0.0).toStringAsFixed(2)}, '
                                    'Fecha: $formattedDateTime',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _closeSales,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor, // Color del botón
                              foregroundColor: Colors.white, // Color del texto
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Bordes redondeados
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            ),
                            child: Text('Cerrar Ventas'),
                          ),
                        ],
                      ),
                    ),
                  if (!_isSearching && _selectedItems.isEmpty && !_isSalesVisible)
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _fetchSales,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor, // Color del botón
                                  foregroundColor: Colors.white, // Color del texto
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Bordes redondeados
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                ),
                                child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Ver Ventas'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _logout,
        child: Icon(Icons.exit_to_app, color: Colors.white),
        tooltip: 'Cerrar Sesión',
        backgroundColor: primaryColor, // Cambia el color del botón flotante
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}