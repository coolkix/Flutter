import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:giphy_picker/giphy_picker.dart';

void main() => runApp(MyApp());

const String apiKey = ''; // key for accessing gifs and stickers
const String gifBaseUrl = 'https://api.giphy.com/v1/gifs/';
const String stickerBaseUrl = 'https://api.giphy.com/v1/stickers/';

class MyApp extends StatelessWidget {
  // app initialization
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Demo(),
    );
  }
}

class Demo extends StatefulWidget {
  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  List<GiphyGif> _gifs = [];
  bool _isLoading = false;
  int _offset = 0;

  Future<void> _fetchGifs({required String searchQuery, int limit = 20}) async {
    // fetches Gifs based on search
    if (_isLoading) return; // prevents multiple api calls at the same time

    setState(() => _isLoading = true);

    try {
      // uses searched keyword and marks when fetched gifs hit the limit with the offset
      final url = Uri.parse(
        '${gifBaseUrl}search?api_key=$apiKey&q=$searchQuery&limit=$limit&offset=$_offset',
      );
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      setState(() {
        // updates fetched gifs
        _gifs.addAll((data['data'] as List)
            .map((gifData) => GiphyGif.fromJson(gifData))
            .toList());
        _offset += limit;
      });
    } finally {
      setState(() => _isLoading = false); // loading finished
    }
  }

  Future<List<String>> _fetchStickers() async {
    // only shows trending stickers
    final url = Uri.parse('${stickerBaseUrl}trending?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // if successful, show stickers, else error message
      final data = jsonDecode(response.body);
      return (data['data'] as List) // shows stickers as a list of strings
          .map((sticker) => sticker['images']['original']['url'] as String)
          .toList();
    } else {
      throw Exception('Failed to load stickers');
    }
  }

  Future<void> _openGifPicker() async {
    // using GiphyPicker, user can select a gif and view preview
    final gif = await GiphyPicker.pickGif(
      context: context,
      apiKey: apiKey,
      showPreviewPage: true,
    );
    if (gif != null) {
      // if a gif is selected, show only that gif
      setState(() {
        _gifs = [gif]; // set it as the only gif in list
        _offset = 0; // set offset to 0 so meanwhile no gifs are getting fetched
      });
      // fetch gifs based on keyword or default if null
      _fetchGifs(searchQuery: gif.title ?? "default");
    }
  }

  // column count function based on orientation
  int _getColumnCount(double width, Orientation orientation) {
    if (orientation == Orientation.portrait) {
      return width < 600 ? 2 : 3;
    } else {
      return width < 600 ? 3 : 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation =
        MediaQuery.of(context).orientation; // get current orientation
    final screenWidth = MediaQuery.of(context)
        .size
        .width; // get current screen width to adjust layout

    return Scaffold(
      // main screen layout
      appBar: AppBar(
        title: const Text('Trending Stickers',
            style: TextStyle(
              fontSize: 20,
            )),
        actions: [
          TextButton(
            // go to gifs section
            onPressed: () => _openGifPicker(),
            child: const Text('Search Gifs',
                style: TextStyle(
                  fontSize: 20,
                )),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: _buildStickerGrid(
                    screenWidth, orientation)), // display sticker grid
          ],
        ),
      ),
    );
  }

  Widget _buildStickerGrid(double screenWidth, Orientation orientation) {
    return FutureBuilder<List<String>>(
      // fetches and displays a list of stickers
      future: _fetchStickers(),
      builder: (context, snapshot) {
        // if still loading, show indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // if there was an error on fetching stickers, display error message
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No stickers found'));
        }

        final stickers =
            snapshot.data!; // on successful sticker fetch display stickers
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getColumnCount(screenWidth,
                orientation), // based on screen width and orientation, set number of columns
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: stickers.length, // number of items in grid
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // detailed view of selected sticker
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StickerDetailPage(
                      stickerUrl: stickers[
                          index], // pass the sticker URL to selected view
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: Image.network(
                    stickers[index], // the sticker image url
                    fit: BoxFit.cover, // so image fills the space
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                          child: Text('Failed to load sticker'));
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// detailed view of a sticker
class StickerDetailPage extends StatelessWidget {
  final String stickerUrl;

  StickerDetailPage({required this.stickerUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sticker Detail'),
      ),
      body: Center(
        child: InteractiveViewer(
          // zoom if needed
          child: Image.network(stickerUrl),
        ),
      ),
    );
  }
}
