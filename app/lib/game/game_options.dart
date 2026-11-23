const List<int> binairoBoardSizes = [6, 8, 10, 12];

const List<int> sudokuBoardSizes = [4, 6, 9];

String formatElapsedTime(Duration elapsed) {
  final minutes = elapsed.inMinutes;
  final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
