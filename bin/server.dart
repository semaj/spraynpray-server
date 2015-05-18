// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'coinbase.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:http/http.dart' as http;
import 'package:redstone/server.dart' as app;

Coinbase coinbase;

void main() {
  app.setupConsoleLog();
  app.start(port: 8081);
}

@app.Interceptor(r'/.*')
interceptor() {
  app.response = app.response.change(headers: {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Key,Sign"
  });

  if (app.request.method == "OPTIONS") {
    app.chain.interrupt();
  } else {
    app.chain.next(() => app.response.change(
        headers: {"Access-Control-Allow-Origin": "*"}));
  }
}


@app.Route('/token', methods: const [app.POST])
token(@app.QueryParam("code") String code, @app.QueryParam("redirect_uri") String redirectUri, @app.QueryParam("client_id") String identifier, @app.QueryParam("client_secret") String secret)  {
//  print(code);
//  print(redirectUri);
//  print(identifier);
//  print(secret);
  String uri = "https://sandbox.coinbase.com/oauth/token?grant_type=authorization_code&code=${code}&redirect_uri=${redirectUri}&client_id=${identifier}&client_secret=${secret}";
  return http.post(uri).then((response) {
    String accessToken = JSON.decode(response.body)['access_token'];
    print(accessToken);
    coinbase = new Coinbase(accessToken);
    return accessToken;
  });
}

@app.Route('/buys', methods: const [app.POST])
buys(@app.Body(app.JSON) Map json) {
  coinbase.buy(json).then((response) {
    print("buy!");
    print(response);
  });
}


@app.Route('/cryptsy/api/v2/:action', methods: const [app.POST, app.PUT, app.GET, app.DELETE])
cryptsy() {
  String path = app.request.requestedUri.pathSegments.sublist(1).join('/');
  Map<String, String> headers = {
    'Sign': app.request.headers['Sign'],
    'Key': app.request.headers['Key'] 
    };
  
  String url = app.request.requestedUri.replace(scheme: 'https',
                                         host: "api.cryptsy.com",
                                         port: 443,
                                         path: path).toString();

  switch(app.request.method){
    case 'GET':
      return http.get(url, headers: headers).then((response) {
          print(response.body);
          return response; 
        });
    case 'PUT':
      return http.put(url, 
          headers: headers, 
          body: app.request.body).then((response) {
          print(response.body);
          return response;
        });
    case 'POST':
      return http.post(url, headers: headers, 
          body: app.request.body).then((response) {
          print(response.body);
          return response;
        });
    case 'DELETE':
      return http.delete(url, headers: headers).then((response) {
          print(response.body);
          return response;
        });
  }
}


