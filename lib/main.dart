import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

//essa biblioteca vai permitir fazer requisições e não ter que ficar esperando essas requisições
import 'dart:async';
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance/quotations?key=394163bc';

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double? dolar;
  double? euro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('\$ Conversor \$'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      //futureBuilder - enquanto estiver obtendo os dados vou exibir na tela uma msg de carregamento
      //vai construir a tela dependendo do que tiver no future (getData no nosso caso)
      body: FutureBuilder<Map>(
        future: getData(),
        //snapshot é uma fotografia momentânea dos dados do servidor
        builder: (context, snapshot) {
          //vamos usar o switch no snapshot para ver o estado da conexão
          switch (snapshot.connectionState) {
            //caso não esteja conectado ou esperando uma conexão, retorna o texto centralizado abaixo
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text('Carregando dados...',
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center),
              );
            //caso tenha erro ele retorna o texto abaixo
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erro ao carregar dados :(',
                      style: TextStyle(color: Colors.amber, fontSize: 25),
                      textAlign: TextAlign.center),
                );
              } else {
                dolar = snapshot.data!['results']['currencies']['USD']['buy'];
                euro = snapshot.data!['results']['currencies']['EUR']['buy'];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextField('Reais', 'R\$', realController, _realChanged),
                      Divider(),
                      buildTextField('Dólares', 'US\$', dolarController, _dolarChanged),
                      Divider(),
                      buildTextField('Euros', '€', euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
  //funções que vão verificar as mudanças que fazemos nos campos das moedas
  void _realChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar!).toStringAsFixed(2);
    euroController.text = (real/euro!).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar!).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar! / euro!).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro!).toStringAsFixed(2);
    dolarController.text = (euro * this.euro! / dolar!).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = '';
    dolarController.text = '';
    euroController.text = '';
  }
}

//função que retorna um mapa no futuro, por ser uma função que vai vir do futuro precisamos do async
Future<Map> getData() async {
  //fazemos uma requisição e o http.get retorna um futuro
  //como espero um dado futuro preciso do await para esperar esse dado chegar e ser alocado no response
  http.Response response = await http.get(Uri.parse(request));

  //pega um arquivo json e tranforma num mapa
  return json.decode(response.body);
}

//função que vai criar meu campo de text utilizando a label e o prefix e retorna o widget
Widget buildTextField(String label, String prefix, TextEditingController c, Function(String) f) {
  return TextField(
    onChanged: f,
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    keyboardType: TextInputType.number,
  );
}



