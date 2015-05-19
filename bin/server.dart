// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'coinbase.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:http/http.dart' as http;
import 'package:redstone/server.dart' as app;

void main() {
  app.setupConsoleLog();
  app.start(port: 8081);
}

@app.Interceptor(r'/.*')
interceptor() {
  app.chain.next(() {
    app.response = app.response.change(headers: {
      "Access-Control-Allow-Origin": "*"
    });
  });
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
    return accessToken;
  });
}

@app.Route('/buys', methods: const [app.POST])
buys(@app.QueryParam("accessToken") String token, @app.Body(app.JSON) Map json) {
  print("hello there!");
  return "{}";
//  new Coinbase(token).buy(json).then((response) {
//    print("buy!");
//    print(response);
//  });
}