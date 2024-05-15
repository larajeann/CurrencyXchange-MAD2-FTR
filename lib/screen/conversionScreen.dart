import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class CurrencyConverterPage extends StatefulWidget {
  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  Map<String, dynamic>? _exchangeRates;
  String _fromCurrency = 'USD';
  String _toCurrency = 'PHP';
  double _amount = 0;
  String? rate;
  var input = TextEditingController();
 late Box<String> _favoriteCurrenciesBox;
 
  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
    //_favoriteCurrenciesBox.clear();
    _favoriteCurrenciesBox = Hive.box<String>('favorite_currencies');
   // print(_favoriteCurrenciesBox.toString());
  }

  Future<void> fetchExchangeRates() async {
    final response = await http.get(Uri.parse(
        'https://api.exchangerate-api.com/v4/latest/$_fromCurrency'));
    if (response.statusCode == 200) {
      setState(() {
        _exchangeRates = json.decode(response.body)['rates'];
      });
    } else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Conversion Service is not available at this moment.')));
  }
  }
void toggleFavoriteCurrency(String fromCurrency, String toCurrency) {
  final key = '$fromCurrency-$toCurrency';
  setState(() {
    if (_favoriteCurrenciesBox.containsKey(key)) {
      _favoriteCurrenciesBox.delete(key);
    } else {
      _favoriteCurrenciesBox.put(key, key);
    }
  });
}


  Widget buildStarIcon(String fromCurrency, String toCurrency) {
  final key = '$fromCurrency-$toCurrency';
  return _favoriteCurrenciesBox.containsKey(key)
      ? Icon(Icons.star, color: Colors.green)
      : Icon(Icons.star_border);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CurrencyXchange',   style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.green[400],
      ),
      body: _exchangeRates == null ? Center(child: CircularProgressIndicator())
           : Padding(padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                     TextField(
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(labelText: 'Amount',  border: OutlineInputBorder(),),
                        controller: input ,
                        onChanged: (value) {
                          setState(() {
                            _amount = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                    const SizedBox(height: 15.0),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Base Currency',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: _fromCurrency,
                                   items: _exchangeRates!.keys.map<DropdownMenuItem<String>>(
                                  (currency) => DropdownMenuItem<String>
                                  (
                                   value: currency,
                                   child: Text(currency),
                                  ),
                                  ).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      _fromCurrency = value!;
                                        rate = null;
                                       fetchExchangeRates();
                                    });
                                  },
                                ),
                        ),
                         const SizedBox(width: 8.0),
                         Expanded(
                              child:  DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Target Currency',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: _toCurrency,
                                   items: _exchangeRates!.keys.map<DropdownMenuItem<String>>(
                                  (currency) => DropdownMenuItem<String>
                                  (
                                   value: currency,
                                   child: Text(currency),
                                  ),
                                  ).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      _toCurrency = value!;
                                        rate = null;
                                       fetchExchangeRates();
                                    });
                                  },
                                ),
                         ),    
                        const SizedBox(width: 5.0),
                        ElevatedButton(
                          onPressed: () {
                            toggleFavoriteCurrency(_fromCurrency, _toCurrency);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildStarIcon(_fromCurrency, _toCurrency),
                              const Text('Favorite', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 8),),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    Row( mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text( '  Exchange Rate:  1 $_fromCurrency = ${(1 * _exchangeRates![_toCurrency]).toStringAsFixed(3)} $_toCurrency'.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),),
                      ],
                    ), const SizedBox(height: 10.0),
                     Column(
                       children: [
                         Row(
                           children: [
                                  Expanded(
                                    child: Container(   
                                      padding: const EdgeInsets.all(10), 
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                        color: Colors.greenAccent, 
                                        width: 1.5, 
                                      ),
                                      borderRadius: BorderRadius.circular(5.0), 
                                      ),
                                      child: Text('RATE: ${rate ?? ''}  $_toCurrency',
                                        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                           ],
                         ),
                          const SizedBox(height: 20.0),
                          ElevatedButton( 
                            onPressed: _exchangeRates != null? 
                                (){
                                    setState(() {
                                      error();
                                      rate = (_amount * _exchangeRates![_toCurrency]).toStringAsFixed(3);
                                    });
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                              backgroundColor: Colors.green[800],
                              minimumSize: const Size(double.infinity, 60),
                              elevation: 3,
                            ), 
                            child: const Text( 'CONVERT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),  ),
                           
                          ),
                          const SizedBox(height: 15.0),
                           Text( 'Favorites '.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18,  color: Colors.black87), ),
                        const SizedBox(height: 5.0),
                       ],
                     ),
                     ValueListenableBuilder(
                      valueListenable: _favoriteCurrenciesBox.listenable(),
                      builder: (context, _favoriteCurrenciesBox, _) {
                        return ListView.builder(
                      shrinkWrap: true,
                      itemCount: _favoriteCurrenciesBox.length,
                      itemBuilder: (context, index) {
                        final key = _favoriteCurrenciesBox.keyAt(index)!;
                        final currencies = key.split('-');
                        final fromCurrency = currencies[0];
                        final toCurrency = currencies[1];
                       //print(currencies[0].toString());
                      return Card(
                            elevation: 2, 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0), 
                            ),
                            child: ListTile(
                              title: Text('$fromCurrency-$toCurrency'),
                              onTap: () {
                                setState(() {
                                  _fromCurrency = fromCurrency;
                                  _toCurrency = toCurrency;
                                });
                                fetchExchangeRates();
                              },
                            ),
                          );
                      },
                    );
                   } 
                   ),
                  ],
                ),
              ),
            ),
    );
  } 
void showAlert(String errorMassage) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Oops!'),
        content: Text(errorMassage),
        actions: [
          TextButton(
            onPressed: ()=>  Navigator.pop(context),
            child: const Text('OK')),
        ],
      ),
    );
}
void error(){
    var errorMassage = '';
       if(input.text == ''){
       errorMassage='Please input an amount.';
       showAlert(errorMassage);
       return;
       }
        var value = double.tryParse(input.text);
        if(value!<=0){
          errorMassage='Amount Should be Greater than Zero.';
          showAlert(errorMassage);
          input.clear();
          _amount=0;
          return;
        }
  }
 

}
