import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

//essa biblioteca vai permitir fazer requisições e não ter que ficar esperando essas requisições
import 'dart:async';
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance/quotations?key=394163bc';

void main() async {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
                return Container(
                  color: Colors.green,
                );
              }
          }
        },
      ),
    );
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
