part of deskovka_server;

void load(){
  File file = new File(PATH_TO_RESOURCES);
  file.readAsString().then((String text){
    Map resources = JSON.decode(text);
    setInitialJson(resources);
  });
}