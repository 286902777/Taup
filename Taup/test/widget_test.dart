import 'package:flutter_test/flutter_test.dart';

import 'package:taup/tool/config_tool.dart';

void main() {
  group('ConfigTool.formatFileSize', () {
    test('formats byte ranges', () {
      expect(ConfigTool.formatFileSize(0), '0 B');
      expect(ConfigTool.formatFileSize(512), '512 B');
      expect(ConfigTool.formatFileSize(1536), '1.50 KB');
      expect(ConfigTool.formatFileSize(2 * 1024 * 1024), '2.00 MB');
      expect(ConfigTool.formatFileSize(3 * 1024 * 1024 * 1024), '3.00 GB');
    });
  });
}
