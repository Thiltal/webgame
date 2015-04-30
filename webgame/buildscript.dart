import 'dart:io';
import 'dart:async';

void main(List<String> args) {
  File js = new File("web/app.js");
  File js2 = new File("web/app.js.map");
  File js3 = new File("web/app.precompiled.js");
  Future.wait([js.exists().then((exist) {
      if (exist) {
        js.delete();
      }
    }), js2.exists().then((exist) {
      if (exist) {
        js2.delete();
      }
    }), js3.exists().then((exist) {
      if (exist) {
        js3.delete();
      }
    })]).then((result){
    Process.run(
        "dart2js.bat",
        [
            "--out=web/app.js",
            "--minify",
            "--trust-type-annotations",
            "--trust-primitives",
            "web/main.dart"]).then((ProcessResult result) {
      print("done"+result.stdout);
    });    
  });

}
