library coinbase;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
//  new Coinbase().accounts().then((s) => print(s['accounts'][0]['name']));
//  new Coinbase().sell(0.001).then((s) => print(s.toString()));
}

class Coinbase {
//  final String token = '82afb75fd4be127df024deb2be2827c7d2c81a7fd107ffa0cd532fa3d28ed69b';
  final String root = 'https://api.sandbox.coinbase.com/v1';
  final String token;
  
  Coinbase(String token);
  
  Future<Map> accounts() {
    return get('/accounts');
  }
  
  Future<Map> buy(Map body) {
    return post('/buys', body); 
  }
  
  Future<Map> sell(Map body) {
    return post('/sells', body);
  }
  
  Future<Map> get(String path) {
    String url = "${root}${path}?access_token=${token}";
    print(url);
    return http.get(url).then((response) => JSON.decode(response.body));
  }
  
  Future<Map> post(String path, Map body) {
    String postBody = JSON.encode(body);
    String url = "${root}${path}?access_token=${token}";
    return http.post(url, body: postBody).then((response) => JSON.decode(response.body));
  }
}