import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../../../shared/widgets/feature_placeholder_page.dart';

class FilesPage extends StatelessWidget {
  const FilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FeaturePlaceholderPage(
      title: l10n.files,
      subtitle: l10n.filesSubtitle,
      icon: Icons.folder_outlined,
      actionLabel: l10n.addFile,
      sections: [l10n.images, l10n.pdfFiles, l10n.documents, l10n.audioVideo],
    );
  }
}
