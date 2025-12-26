import "package:flutter/services.dart";
import "package:injectable/injectable.dart";

@Injectable()
class MacOSSecurityScopedService {
  static const _channel = MethodChannel("opengit.security_scoped");

  Future<Uint8List> createBookmark(String path) async {
    final data = await _channel.invokeMethod<Uint8List>(
      "createBookmark",
      path,
    );
    return data!;
  }

  Future<String> resolveBookmark(Uint8List data) async {
    return await _channel.invokeMethod<String>(
          "resolveBookmark",
          data,
        ) ??
        "";
  }

  Future<void> stopAccess(String path) async {
    await _channel.invokeMethod("stopAccess", path);
  }
}
