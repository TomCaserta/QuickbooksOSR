library QuickbooksOSR;
@MirrorsUsed(targets: const [
                             'QuickbooksOsrModule',
                             'OsrState',
                             'QBCountryVersion',
                             'QBJsonReader',
                             'QBMessageSubscription',
                             'QBRequestsJsonReader'
                             ],override: '*')
import 'dart:mirrors';
import 'dart:html';
import 'dart:async';
import 'dart:js';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:angular/angular.dart';
import 'package:path/path.dart' as path;
import 'dart/utils/fse_tree.dart';

part 'dart/components/sidebar.dart';
part 'dart/controllers/message_view.dart';
part 'dart/qb_structures/country_version.dart';
part 'dart/qb_structures/json_attribute_tree.dart';
part 'dart/qb_structures/message_or_subscription.dart';
part 'dart/qb_structures/requests.dart';

Logger log = new Logger("QuickbooksOSR");
void main() {
  log.onRecord.listen((LogRecord r) { 
    print("[${new DateFormat("hh:mm:ss").format(r.time)}][${r.level}][${r.loggerName != "" ? r.loggerName : "ROOT"}]: ${r.message}");
  });
  ngBootstrap(module: new QuickbooksOsrModule());
}


quickbooksOsrRouteInitializer(Router router, ViewFactory views) {
  return views.configure({
       'view': ngRoute(
          path: 'view/:type/:sdkType/:maxSDKVersion/:countries',
          view: 'views/tableview.html'),
       'index': ngRoute (
           defaultRoute: true,
          path: "index",
          view: "views/index.html"
       )
  });
}

class QuickbooksOsrModule extends Module {
  
  QuickbooksOsrModule () {
    type(OsrState);
    type(SidebarComponent);
    type(MessageViewController);
    value(RouteInitializerFn, quickbooksOsrRouteInitializer);
    factory(NgRoutingUsePushState,
        (_) => new NgRoutingUsePushState.value(false));
  }
}


class OsrState {
  FSETree _rootTree;
  QBRequestsJsonReader _requestFile;
  
  Future<QBJsonReader> getQBJsonReader (String name) {
    List<QBJsonReader> retList = new List<QBJsonReader>();
    return this.simpleGet("osr_docs/json/$name.json").then((String response) { 
      return new QBJsonReader.fromJson(response);
    });
  }
  
  Future<QBRequestsJsonReader> getRequestsJsonReader () {
    if (_requestFile == null) {
      return this.simpleGet("osr_docs/json/requests.json").then((String response) { 
        _requestFile = new QBRequestsJsonReader(JSON.decode(response));
        return _requestFile;
      });
    }
    else {
      Completer c = new Completer();
      c.complete(_requestFile);
      return c.future;
    }
  }
  
  Future<FSETree> getDirectoryContents () {
   if (_rootTree == null) {
     return this.simpleGet( "fileList.json").then((String response)  {
       _rootTree = new FSETree.fromJson(response);
       return _rootTree;
     });
   }
   else {
     Completer c = new Completer();
     c.complete(_rootTree);
     return c.future;
   }
   
  }
  
  Future<String> simpleGet(String url) {
    log.info("Retreiving response from server for $url");
    Completer f = new Completer();
    HttpRequest http = new HttpRequest();
    http.open("GET", url);
    http.send();
    http.onReadyStateChange.listen((ProgressEvent ev) { 
      if (http.readyState == 4) {
        FSETree rootDir = new FSETree.fromJson(http.responseText);
        if (http.status == 200) {
          log.fine("Got response from server for $url");
          f.complete(http.responseText);
        }
        else {
          log.severe("Error retreiving $url: ${http.status}", new Exception("Could not retreive $url: ${http.status}"));
        }
      }
    });
    return f.future;
  }
  
  
}