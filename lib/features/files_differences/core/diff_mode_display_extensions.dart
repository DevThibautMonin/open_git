import 'package:open_git/features/files_differences/domain/enums/diff_mode_display.dart';

extension DiffModeDisplayExtensions on DiffModeDisplay {
  String get raw => name;

  static DiffModeDisplay fromRaw(String? raw) {
    return DiffModeDisplay.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => DiffModeDisplay.split,
    );
  }
}
