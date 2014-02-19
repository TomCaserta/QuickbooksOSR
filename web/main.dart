import 'dart:html';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:angular/angular.dart';


import 'dart/utils/fse_tree.dart';

Logger log = new Logger("QuickbooksOSR");
void main() {
  log.onRecord.listen((LogRecord r) { 
    print("[${new DateFormat("hh:mm:ss").format(r.time)}][${r.level}][${r.loggerName != "" ? r.loggerName : "ROOT"}]: ${r.message}");
  });
  log.info("Retreiving directory contents...");
  HttpRequest http = new HttpRequest();
  http.open("GET", "fileList.json");
  http.send();
  http.onReadyStateChange.listen((ProgressEvent ev) { 
    if (http.readyState == 4) {
      FSETree rootDir = new FSETree.fromJson(http.responseText);
      log.info("Got root directory contents");
      
    }
  });
}

class QuickbooksOsrModule extends Module {
  QuickbooksOsrModule () {
    
  }
}