# versions
flutter version = 3.27.3
Tools • Dart 3.6.1 • DevTools 2.40.2

# commands
project ran with "flutter run" on Chrome view
dependencies with "flutter pub get"
tests with "flutter test"

# what wasn't done
could have added unit tests like network test, grid view test, etc. Current unit tests simply test if gifs and stickers get fetched, and also if api key is valid.

grid functionality was added, but unsure if it works how it was intended. Both gifs and stickers can lead to a detailed view, but sticker view works with a separate class, while gif view works with GiphyPicker.

Trending stickers were made to appear on a limited amount to prevent api key limit rate threshold.

classes and separate functions could have been made in different files, but since i wasn't familiar with flutter, I made it in a single file. Unit tests are in different files.

As I didn't have much time on some days and also the api rate limit, I didn't focus on UI much, for that reason the UI lacks design. Main focus was on functionality.

Network availability made problems, which I couldn't manage to fix. Because of that it wasn't implemented.

The quality of gifs in search page, before clicking on them, had bad quality, but after selecting a gif it was good quality. 