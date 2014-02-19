import 'dart:html';
import 'dart:convert';
import 'package:angular/angular.dart';

void main() {
  print("Requesting");
  HttpRequest http = new HttpRequest();
  http.open("GET", "fileList.json");
  http.send();
  http.onReadyStateChange.listen((ProgressEvent ev) { 
    if (http.readyState == 4) {
      print(http.responseText);
    }
    else print(http.readyState);
  });
}



class FSETree {
  String treeName = "";
  FSETree parent;
  List<String> files = new List<String>();
  Map<String, FSETree> directory = new Map<String, FSETree>();
  FSETree (this.treeName, [this.parent]) {
    
  }
  
  FSETree.fromJson (String json) {
    
  }
  
  FSETree getChild (String childName) {
    if (directory.containsKey(childName)) {
      return directory[childName];
    }
    else {
      FSETree tempTree = new FSETree(childName, this);
      directory[childName]  = tempTree;
      return tempTree;
    }
  }
  String toString () {
    return toJson().toString();
  }
  Map toJson() { 
    return { "treeName": treeName, "files": files, "directories": directory }; 
  }
}