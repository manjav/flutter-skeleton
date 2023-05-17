// import 'dart:io';
// import 'dart:typed_data';
// import 'package:path_provider/path_provider.dart';

// // void writeBytesToFile1(String filePath, List<int> byteData) async {
// //   File file = File(filePath);
// //   // String directoryPath = root.path + '/bozzetto_camera';
// //   file.writeAsBytesSync(byteData, flush: true);
// //   print('Bytes successfully written to the file: $filePath');
// // }

// // Example usage
// Future<File?> writeBytesToFile(List<int> byteData, String path) async {
//   try {
//     Directory appDocDir = await getApplicationDocumentsDirectory();
//     String filePath = '${appDocDir.path}/$path';

//     File file = File(filePath);
//     await file.writeAsBytes(byteData);

//     print('Bytes successfully written to the file: $filePath');
//     return file;
//   } catch (e) {
//     // throw "Save failed $e";
//     return null;
//   }
// }

// Future<Uint8List?> readFromFile(String path) async {
//   Directory appDocDir = await getApplicationDocumentsDirectory();

//   try {
//     File file = File('${appDocDir.path}/$path');
//     bool fileExists = await file.exists();

//     if (fileExists) {
//       Uint8List fileContent = await file.readAsBytes();
//       return fileContent;
//     } else {
//       throw const FileSystemException('File not found');
//     }
//   } catch (e) {
//     print('An error occurred while reading the file: $e');
//     return null;
//   }
// }
