import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import 'package:snapkeep/src/core/constants/paths.dart';
import 'package:snapkeep/src/core/services/thumbnail/video_thumbnail.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';

part 'status_state.dart';

@lazySingleton
class StatusCubit extends Cubit<StatusState> {
  StatusCubit() : super(StatusInitial());

  void store({required Status status}) async {
    try {
      final PermissionStatus permissionStatus =
          await Permission.storage.request();

      if (permissionStatus.isGranted) {
        final Directory directory = Directory(kStoredWhatsAppPath);

        if (!(await directory.exists())) {
          await directory.create(recursive: true);
        }

        final file = File(status.path);

        if (await file.exists()) {
          final String newFilePath =
              '${directory.path}/${file.uri.pathSegments.last}';

          await file.copy(newFilePath);

          emit(const StatusActionSuccess(success: true));
        } else {
          emit(
            const StatusActionFailure(message: 'Source file not found.'),
          );
        }
      }

      emit(
        const StatusActionFailure(message: 'Write permission denied.'),
      );
    } catch (e) {
      emit(
        StatusActionFailure(message: e.toString()),
      );
    }
  }

  void share({required Status status}) async {
    try {
      final File file = File(status.path);

      if (await file.exists()) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
          ),
        );
      } else {
        emit(
          const StatusActionFailure(message: 'Source file not found.'),
        );
      }
    } catch (e) {
      emit(
        StatusActionFailure(message: e.toString()),
      );
    }
  }

  Future<String> thumbnail({required String path}) async {
    String? thumbnailPath = await VideoThumbnail.videoThumbnailPath(
      videoPath: path,
    );

    return thumbnailPath ?? '';
  }

  void destroy({required String path}) async {
    try {
      final File fileToDelete = File(path);

      if (await fileToDelete.exists()) {
        await fileToDelete.delete(recursive: true);
        emit(const StatusActionSuccess(success: true));
      } else {
        emit(
          const StatusActionFailure(message: 'Source file not found.'),
        );
      }
    } catch (e) {
      emit(
        StatusActionFailure(message: e.toString()),
      );
    }
  }

  Future<bool> isStored({required String path}) async {
    try {
      final Directory directory = Directory(kStoredWhatsAppPath);
      final File file = File(path);
      final String fileName = file.uri.pathSegments.last;
      final String storedFilePath = '${directory.path}/$fileName';
      final File storedFile = File(storedFilePath);

      return await storedFile.exists();
    } catch (e) {
      return false;
    }
  }
}
