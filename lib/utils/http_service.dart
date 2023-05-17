
// class ByteHTTP {
//   getByteData() async {
//     await Future.delayed(const Duration(seconds: 1));

//     Uint8List? localFileData = await _readFromFile("sample1");

//     if (localFileData != null) {
//       debugPrint("aaaaaaaaaaaaaa");
//       return true;
//     }
//     return _writeBytesToFile([1, 2, 3], "sample1");
//   }

//   Future<File?> _writeBytesToFile(List<int> byteData, String path) async {
//     try {
//       Directory appDocDir = await getApplicationDocumentsDirectory();
//       String filePath = '${appDocDir.path}/$path';

//       File file = File(filePath);
//       await file.writeAsBytes(byteData);

//       print('Bytes successfully written to the file: $filePath');
//       return file;
//     } catch (e) {
//       // throw "Save failed $e";
//       return null;
//     }
//   }

//   Future<Uint8List?> _readFromFile(String path) async {
//     Directory appDocDir = await getApplicationDocumentsDirectory();

//     try {
//       File file = File('${appDocDir.path}/$path');
//       bool fileExists = await file.exists();

//       if (fileExists) {
//         Uint8List fileContent = await file.readAsBytes();
//         return fileContent;
//       } else {
//         // throw const FileSystemException('File not found');
//         return null;
//       }
//     } catch (e) {
//       print('An error occurred while reading the file: $e');
//       return null;
//     }
//   }

  // Future<Uint8List?> _readFromFile(String path) async {
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
// }
