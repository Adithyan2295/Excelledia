import 'package:excelledia/api/apiModel.dart';
import 'package:excelledia/model/model.dart';
import 'package:excelledia/model/singleton.dart';
import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:photo_view/photo_view.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool ifDataLoading = false;
  bool photoViewCheck = false;
  String photoViewUrl = "";
  int contentLength = 0;
  String value;

  TextEditingController _controller = TextEditingController();

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
        Column(
          children: [
            searchbarwithButton(),
            listView(),
          ],
        ),
        contentLength == 0 ? searchText() : Container(),
        photoView(),
        loadingIndicator(),
      ],
    );
  }

  Widget searchText() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        "Enter the search keyword",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }

//loading indicator
  Widget loadingIndicator() {
    return Visibility(
      visible: ifDataLoading,
      child: Container(
        color: Colors.blueGrey.shade900,
        child: Center(
          child: CircularProgressIndicator(valueColor:AlwaysStoppedAnimation<Color>(Colors.white),),
        ),
      ),
    );
  }

// search bar with button
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
                controller: _controller,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 10),
                  // prefixIcon: Icon(Icons.search,color: Colors.white,),
                  hintText: "Search",
                ),
                onChanged: (value) {
                  this.value = value;
                },
                onSubmitted: (value) {
                  onSubmitted();
                },
              ),
            ),
            IconButton(
              icon: Icon(contentLength == 0 ? Icons.search : Icons.cancel),
              onPressed: () {
                contentLength == 0 ? onSubmitted() : clearSearch();
              },
            ),
          ],
        ),
      ),
    );
  }

//main list view
  Widget listView() {
    return Expanded(
      child: Visibility(
        child: Container(
          color: Colors.blueGrey.shade900,
          child: LazyLoadScrollView(
            onEndOfPage: () {
              print("end of page");
              contentCounter();
            },
            scrollOffset: MediaQuery.of(context).size.height.toInt() - 20,
            child: ListView.builder(
              itemCount: contentLength,
              scrollDirection: Axis.vertical,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    setState(() {
                      photoViewCheck = true;
                      photoViewUrl = Singleton
                          .singleton.imageResults.hits[index].webformatUrl;
                    });
                  },
                  child: Container(
                    height: 200,
                    margin:
                        EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
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
                            child: CircularProgressIndicator(valueColor:AlwaysStoppedAnimation<Color>(Colors.white),),
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

//Photo view on Tapping Image
  photoView() {
    return Visibility(
      visible: photoViewCheck,
      child: Stack(
        children: [
          Container(
              child: PhotoView(
            backgroundDecoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
            ),
            imageProvider: NetworkImage(
              photoViewUrl,
            ),
          )),
          closeButton()
        ],
      ),
    );
  }

//Close button to close photo view
  closeButton() {
    return Align(
      alignment: AlignmentDirectional.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        child: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: 50,
          ),
          onPressed: () {
            setState(() {
              photoViewCheck = false;
              photoViewUrl = "";
            });
          },
        ),
      ),
    );
  }

//Api call to get image
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

  void onSubmitted() {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      ifDataLoading = true;
      getData(value);
    });
  }

  void clearSearch() {
    setState(() {
      FocusScope.of(context).requestFocus(FocusNode());
      contentLength = 0;
      photoViewCheck = false;
      photoViewUrl = "";
      _controller.clear();
    });
  }

//lazy loading counter
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
