import 'dart:io';
import 'dart:convert';

void main () {
  print(getDirectoryContents("../web")); 
  File generator = new File("../web/fileList.json");
  generator.openSync(mode: FileMode.WRITE);
  generator.writeAsStringSync(JSON.encode(getDirectoryContents("../web")));
    
}


FSETree getDirectoryContents (String dirName) {

  Directory dir = new Directory(dirName);
  List<String> contents = new List<String>();
  FSETree rootTree = new FSETree ("root");
  if (dir.existsSync()) {
    List<FileSystemEntity> fse = dir.listSync(recursive: true, followLinks: false);
    Map origMap = new Map<String, Map<String, dynamic>>();
    fse.forEach((FileSystemEntity entity)  { 
      if (!(entity is Link)) {
      List<String> splitStr = entity.path.substring(dirName.length + 1).replaceAll("\\", "/").split("/");
      FSETree currT = rootTree;
      for (int x = 0; x < splitStr.length; x++) {
        if (x+1 == splitStr.length && entity is File) {
          // its a file name
          currT.files.add(splitStr[x]);          
        }
        else {
          currT = currT.getChild(splitStr[x]);
        }
      }
      
      contents.add(entity.path.substring(dirName.length).replaceAll("\\", "/"));
      }
    });
  }  
  
  return rootTree;
}

class FSETree {
  
  
  String treeName = "";
  FSETree parent;
  List<String> files = new List<String>();
  Map<String, FSETree> directory = new Map<String, FSETree>();
  FSETree (this.treeName, [this.parent]) {
    
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