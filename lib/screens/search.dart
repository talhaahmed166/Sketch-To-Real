// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_unnecessary_containers
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sketch_to_real/config/collection_names.dart';
import 'package:sketch_to_real/models/user_model.dart';
import 'package:sketch_to_real/screens/profile.dart';
import 'package:sketch_to_real/tools/loading.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  Future<QuerySnapshot>? searchResultsFuture;
  TextEditingController searchController = TextEditingController();
  handleSearch(String query) {
    Future<QuerySnapshot> users =
        userRef.where("username", isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  Container buildNoContent() {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 350.0 : 180.0,
            ),
            Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  //fontWeight: FontWeight.w600,
                  //fontStyle: FontStyle.italic,
                  fontSize: orientation == Orientation.portrait ? 60.0 : 40.0,
                  fontFamily: 'Signatra',
                  wordSpacing: 10.0),
            )
          ],
        ),
      ),
    );
  }

  AppBar buildSearchField(context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
            hintText: "Search",
            filled: false,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: clearSearch(),
            )),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  buildSearchResult() {
    return FutureBuilder<QuerySnapshot>(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingIndicator();
        }
        List<UserResult> searchResults = [];
        for (var doc in snapshot.data!.docs) {
          AppUserModel user = AppUserModel.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        }
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: buildSearchField(context),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResult(),
    );
  }
}

showProfile(BuildContext context, {required String profileId}) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Profile(
                profileId: profileId,
              )));
}

class UserResult extends StatelessWidget {
  final AppUserModel user;
  const UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.userId!),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: user.photoUrl! != ""
                    ? CachedNetworkImageProvider(user.photoUrl!)
                    : null,
                backgroundColor: Colors.grey,
              ),
              title: Text(
                user.userName!,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.userName!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const Divider(
            color: Colors.white54,
            thickness: 1.0,
            height: 2.0,
          )
        ],
      ),
    );
  }
}
