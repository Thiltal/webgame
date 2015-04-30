part of ui;

abstract class Widget{
  Template template;
  Element target;
  String path;
  Widget parentWidget;
  Map widgetLang;
  String get name => path.split("/").last;
  List<Widget> children = [];
  bool repaintRequested = true;
  bool keepPaintedState = false;
  void requestRepaint(){
    repaintRequested = true;
  }

  Widget(){
    if(path == null){
      throw new Exception("path in Widget must be defined");
    }
    template = findInMap(path, templates);
    var langCache = findInMap(path, lang);
    if(langCache is Map){
      widgetLang = langCache;
    }
  }

  Map out();

  void repaint([bool forceRepaint = false]){
    if(keepPaintedState){
      onNoRepaint();
      return;
    }
    if(repaintRequested || forceRepaint){
      repaintRequested = false;
      if(target==null){
        throw new StateError("Target is null in $this");
      }
      target.innerHtml = template.renderString(out());
      tideFunctionality();
      setChildrenTargets();
      for(Widget widget in children){
        widget.repaint(true);
      }
    }else{
      onNoRepaint();
      for(Widget widget in children){
        widget.repaint();
      }
    }
  }

  void setChildrenTargets();
  void tideFunctionality();

  void onNoRepaint(){}
  void destroy();

  Widget getChildByName(String name){
    for(Widget w in children){
      if(w.name==name){
        return w;
      }
    }
    return null;
  }
}