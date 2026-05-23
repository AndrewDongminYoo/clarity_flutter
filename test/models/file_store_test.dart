// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:clarity_flutter/src/models/file_store.dart';
import 'package:clarity_flutter/src/utils/file_utils.dart';

void main() {
  late Directory tempDir;
  late FileStore fileStore;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('clarity_test_');
    fileStore = FileStore(tempDir, 'test_store');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('FileStore.fileExists', () {
    test('returns false for non-existent file', () async {
      expect(await fileStore.fileExists('nonexistent.txt'), isFalse);
    });

    test('returns true for existing file', () async {
      await fileStore.writeToFile('test.txt', 'content', WriteMode.overwrite);
      expect(await fileStore.fileExists('test.txt'), isTrue);
    });
  });

  group('FileStore.writeToFile and readFileToString', () {
    test('writes and reads file content', () async {
      await fileStore.writeToFile('test.txt', 'Hello World', WriteMode.overwrite);
      final content = await fileStore.readFileToString('test.txt');
      expect(content, 'Hello World');
    });

    test('overwrites existing file in overwrite mode', () async {
      await fileStore.writeToFile('test.txt', 'First', WriteMode.overwrite);
      await fileStore.writeToFile('test.txt', 'Second', WriteMode.overwrite);
      final content = await fileStore.readFileToString('test.txt');
      expect(content, 'Second');
    });

    test('appends to existing file in append mode', () async {
      await fileStore.writeToFile('test.txt', 'First', WriteMode.overwrite);
      await fileStore.writeToFile('test.txt', ' Second', WriteMode.append);
      final content = await fileStore.readFileToString('test.txt');
      expect(content, 'First Second');
    });
  });

  group('FileStore.writeToFileBytes and readFileToByteArray', () {
    test('writes and reads byte array', () async {
      final bytes = [72, 101, 108, 108, 111]; // "Hello"
      await fileStore.writeToFileBytes('test.bin', bytes, WriteMode.overwrite);
      final readBytes = await fileStore.readFileToByteArray('test.bin');
      expect(readBytes, bytes);
    });
  });

  group('FileStore.writeToFileSync', () {
    test('writes file synchronously', () {
      fileStore.writeToFileSync('sync.txt', 'Sync content', WriteMode.overwrite);
      final content = File(FileUtils.concat([fileStore.fullDirectory, 'sync.txt'])).readAsStringSync();
      expect(content, 'Sync content');
    });
  });

  group('FileStore.deleteFile', () {
    test('deletes existing file', () async {
      await fileStore.writeToFile('delete.txt', 'content', WriteMode.overwrite);
      await fileStore.deleteFile('delete.txt');
      expect(await fileStore.fileExists('delete.txt'), isFalse);
    });
  });

  group('FileStore.getAllFilesRecursively', () {
    test('returns all files in directory tree', () async {
      await fileStore.writeToFile('file1.txt', 'content1', WriteMode.overwrite);
      await fileStore.writeToFile('sub/file2.txt', 'content2', WriteMode.overwrite);

      final files = await fileStore.getAllFilesRecursively();
      expect(files.length, 2);
      expect(files.every((f) => f is File), isTrue);
    });

    test('returns empty list when directory does not exist', () async {
      final emptyStore = FileStore(tempDir, 'nonexistent');
      final files = await emptyStore.getAllFilesRecursively();
      expect(files, isEmpty);
    });
  });

  group('FileStore.deleteFilesModifiedBeforeTimestampRecursively', () {
    test('deletes old files and keeps recent files', () async {
      // Create "old" file
      await fileStore.writeToFile('old.txt', 'old', WriteMode.overwrite);

      // Set old file's modification time to the past (1 hour ago)
      final oldFilePath = FileUtils.concat([fileStore.fullDirectory, 'old.txt']);
      final oldFile = File(oldFilePath);
      final pastTime = DateTime.now().subtract(const Duration(hours: 1));
      await oldFile.setLastModified(pastTime);

      // Set cutoff time to 30 minutes ago
      final cutoffTime = DateTime.now().subtract(const Duration(minutes: 30)).millisecondsSinceEpoch;

      // Create "new" file (current time, after cutoff)
      await fileStore.writeToFile('new.txt', 'new', WriteMode.overwrite);

      await fileStore.deleteFilesModifiedBeforeTimestampRecursively(cutoffTime);

      expect(await fileStore.fileExists('old.txt'), isFalse);
      expect(await fileStore.fileExists('new.txt'), isTrue);
    });

    test('keeps all files when cutoff is in the past', () async {
      await fileStore.writeToFile('file1.txt', 'content1', WriteMode.overwrite);
      await fileStore.writeToFile('file2.txt', 'content2', WriteMode.overwrite);

      // Set cutoff time to 1 hour ago (all files are newer)
      final cutoffTime = DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch;

      await fileStore.deleteFilesModifiedBeforeTimestampRecursively(cutoffTime);

      expect(await fileStore.fileExists('file1.txt'), isTrue);
      expect(await fileStore.fileExists('file2.txt'), isTrue);
    });

    test('deletes all files when cutoff is in the future', () async {
      await fileStore.writeToFile('file1.txt', 'content1', WriteMode.overwrite);
      await fileStore.writeToFile('file2.txt', 'content2', WriteMode.overwrite);

      // Set cutoff time to 1 hour in the future (all files are older)
      final cutoffTime = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch;

      await fileStore.deleteFilesModifiedBeforeTimestampRecursively(cutoffTime);

      expect(await fileStore.fileExists('file1.txt'), isFalse);
      expect(await fileStore.fileExists('file2.txt'), isFalse);
    });

    test('handles files in subdirectories', () async {
      await fileStore.writeToFile('root.txt', 'root', WriteMode.overwrite);
      await fileStore.writeToFile('sub/nested.txt', 'nested', WriteMode.overwrite);

      // Set both files to the past
      final rootPath = FileUtils.concat([fileStore.fullDirectory, 'root.txt']);
      final nestedPath = FileUtils.concat([fileStore.fullDirectory, 'sub', 'nested.txt']);
      final pastTime = DateTime.now().subtract(const Duration(hours: 1));
      await File(rootPath).setLastModified(pastTime);
      await File(nestedPath).setLastModified(pastTime);

      final cutoffTime = DateTime.now().subtract(const Duration(minutes: 30)).millisecondsSinceEpoch;

      await fileStore.deleteFilesModifiedBeforeTimestampRecursively(cutoffTime);

      expect(await fileStore.fileExists('root.txt'), isFalse);
      expect(await fileStore.fileExists('sub/nested.txt'), isFalse);
    });
  });
}
