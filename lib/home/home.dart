import 'package:excelledia/api/apiModel.dart';
import 'package:excelledia/model/model.dart';
import 'package:excelledia/model/singleton.dart';
import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool ifDataLoading = false;
  int contentLength = 0;
  String value;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade900,
        title: Text("Demo App"),
      ),
      backgroundColor: Colors.blueGrey.shade900,
      body: body(),
    );
  }

// main body of the view
  Widget body() {
    return Stack(
      children: [
        Center(
          child: Text("Home"),
        ),
        Column(
          children: [
            searchbarwithButton(),
            listView(),
          ],
        ),
        loadingIndicator(),
      ],
    );
  }

  Widget loadingIndicator() {
    return Visibility(
      visible: ifDataLoading,
      child: Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget searchbarwithButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 10),
                  // prefixIcon: Icon(Icons.search,color: Colors.white,),
                  hintText: "Search",
                ),
                onChanged: (value) {
                  this.value = value;
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                setState(() {
                  ifDataLoading = true;
                  getData(value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget listView() {
    return Expanded(
      child: Visibility(
        child: Container(
          color: Colors.blueGrey.shade900,
          child: LazyLoadScrollView(
            onEndOfPage: () {
              print("end of page *******");
              contentCounter();
            },
            scrollOffset: MediaQuery.of(context).size.height.toInt() -20,
            child: ListView.builder(
              itemCount: contentLength,
              scrollDirection: Axis.vertical,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => DetailsPage(
                    //       content: Singleton.singleton.sortedList[key][index],
                    //     ),
                    //   ),
                    // );
                  },
                  child: Container(
                    height: 200,
                    margin: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                    child: Image.network(
                      Singleton.singleton.imageResults.hits[index].webformatUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void getData(String keyword) async {
    setState(() {
      ifDataLoading = true;
    });

    ApiModel apiModel = ApiModel();
    var getData = await apiModel.get(
        'https://pixabay.com/api/?key=25624959-6b5754ac0b492f2cae36197a8&q=$keyword&image_type=photo');
    print(keyword);
    if (getData != false) {
      Singleton.singleton.imageResults = imageResultsFromJson(getData.body);
      if (Singleton.singleton.imageResults.hits.length > 5) {
        contentLength = 5;
      } else {
        contentLength = Singleton.singleton.imageResults.hits.length;
      }
    } 
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        ifDataLoading = false;
      });
    });
  }

  void contentCounter() {
    int totalLength = Singleton.singleton.imageResults.hits.length;
    var temLength = contentLength + 5;
    if (temLength > totalLength) {
      contentLength = totalLength;
    } else {
      contentLength = temLength;
    }
    setState(() {});
  }
}
