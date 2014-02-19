library FSETree;
import 'dart:convert';

class FSETree {
  String treeName = "";
  FSETree parent;
  List<String> files = new List<String>();
  Map<String, FSETree> directory = new Map<String, FSETree>();
  FSETree (this.treeName, [this.parent]) {
    
  }
  
  FSETree.fromJson (dynamic json) {
    Map<String, dynamic> dir;
    if (json is String) {
      json = JSON.decode(json);
    }
    this.treeName = json["treeName"];
    this.files = json["files"];
    dir = json["directories"];
    if (dir != null) {
      dir.forEach((String directoryName, dynamic contents) { 
        directory[directoryName] = new FSETree.fromJson(contents)..parent = this;        
      });
    }
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