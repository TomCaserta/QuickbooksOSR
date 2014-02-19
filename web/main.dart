import 'dart:html';
import 'dart:async';
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
  
  ngBootstrap(module: new QuickbooksOsrModule());
}


@NgComponent (
  selector: "sidebar",
  templateUrl: "./views/sidebar.html",
  publishAs: "sidebar",
  applyAuthorStyles: true
)
class SidebarController implements NgAttachAware {
  List<int> versions = [1,2,3,4,5,6,7,8,9,10,11,12,13];
  List<QBCountryVersion> countries = [
                                       new QBCountryVersion("USA", true),
                                       new QBCountryVersion("UK", false),
                                       new QBCountryVersion("CANADA", false)
                                       ];
                                                       
  bool _qbFC = false;
  bool _qbXML = true;
  List<String> requests;
  List<String> responses;
  bool isLoading = false;
  
  String version = "13";
    
  String get qbFC => _qbFC ? "on": "off";
  String get qbXML => _qbXML ? "on": "off";
  set qbFC (use) {
    _qbFC = use == "on";
  }

  set qbXML (use) {
    _qbXML = use == "on";
  }
  
  OsrState state;
 
  SidebarController(OsrState this.state) {
            
  }
  void attach () {
    refreshResults();
  }
  
  void refreshResults () {
    
  }
}

class QBCountryVersion {
  String country;
  bool use;
//  bool get use => _use;
//  set use (use) {
//    _use = use == "true";
//  }
  QBCountryVersion(this.country, this.use);
}

class QuickbooksOsrModule extends Module {
  
  QuickbooksOsrModule () {
    type(OsrState);
    type(SidebarController);
  }
}


class OsrState {
  Future<FSETree> getDirectoryContents () {
   Completer c = new Completer();
   log.info("Retreiving directory contents");
   HttpRequest http = new HttpRequest();
   http.open("GET", "fileList.json");
   http.send();
   http.onReadyStateChange.listen((ProgressEvent ev) { 
     if (http.readyState == 4) {
       FSETree rootDir = new FSETree.fromJson(http.responseText);
       log.info("Got root directory response");
       if (http.status == 200) {
         c.complete(new FSETree.fromJson(http.responseText));
       }
       else {
         log.severe("Error retreiving directory contents: ${http.status}", new Exception("Could not retreive directory contents: ${http.status}"));
       }
     }
   });
   return c.future;
  }

}