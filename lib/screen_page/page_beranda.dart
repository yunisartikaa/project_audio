import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../model/model_audio.dart';
import 'package:http/http.dart' as http;
// Import the new favorites page

class PageHome extends StatefulWidget {
  @override
  _PageHomeState createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  late Future<ModelAudio> futureAudio;
  final AudioPlayer audioPlayer = AudioPlayer();
  String? currentlyPlayingId;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Set<String> favoriteIds = {};

  @override
  void initState() {
    super.initState();
    futureAudio = fetchAudio();
  }

  Future<ModelAudio> fetchAudio() async {
    final response = await http.get(Uri.parse('http://192.168.43.97/audiodb/audioDB/audio.php'));

    if (response.statusCode == 200) {
      return modelAudioFromJson(response.body);
    } else {
      throw Exception('Failed to load audio');
    }
  }

  void playAudio(String id, String url) async {
    if (currentlyPlayingId == id) {
      await audioPlayer.stop();
      setState(() {
        currentlyPlayingId = null;
      });
    } else {
      await audioPlayer.play((url));
      setState(() {
        currentlyPlayingId = id;
      });
    }
  }

  void toggleFavorite(String id) {
    setState(() {
      if (favoriteIds.contains(id)) {
        favoriteIds.remove(id);
      } else {
        favoriteIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<ModelAudio>(
          future: futureAudio,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return buildPage(snapshot.data!);
            } else if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            }

            // By default, show a loading spinner.
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget buildPage(ModelAudio data) {
    List<Datum> filteredData = data.data
        .where((audio) => audio.judul.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Albums', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('View All', style: TextStyle(color: Colors.orange)),
              ],
            ),
          ),
          Container(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                return AlbumCard(album: filteredData[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('For you', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('View All', style: TextStyle(color: Colors.orange)),
              ],
            ),
          ),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Image.network('http://192.168.43.97/audiodb/audioDB/gambar/${filteredData[index].gambar}'),
                  title: Text(
                    filteredData[index].judul.length > 10
                        ? filteredData[index].judul.substring(0, 10) + '...'
                        : filteredData[index].judul,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          currentlyPlayingId == filteredData[index].id ? Icons.pause : Icons.play_arrow,
                        ),
                        onPressed: () {
                          playAudio(filteredData[index].id, 'http://192.168.43.97/audiodb/audioDB/audio/${filteredData[index].fileAudio}');
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          favoriteIds.contains(filteredData[index].id) ? Icons.favorite : Icons.favorite_border,
                          color: favoriteIds.contains(filteredData[index].id) ? Colors.green : null,
                        ),
                        onPressed: () {
                          toggleFavorite(filteredData[index].id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 16), // Add some space at the bottom to avoid bottom overflow
        ],
      ),
    );
  }
}

class AlbumCard extends StatelessWidget {
  final Datum album;

  AlbumCard({required this.album});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage('http://192.168.43.97/audiodb/audioDB/gambar/${album.gambar}'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            album.judul.length > 10 ? album.judul.substring(0, 10) + '...' : album.judul,
            style: TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}