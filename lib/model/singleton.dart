

import 'package:excelledia/model/model.dart';

class Singleton {
    static final Singleton singleton = Singleton._internal();
    

  factory Singleton() {
    return singleton;
  }
  ImageResults imageResults;
  Singleton._internal();
}