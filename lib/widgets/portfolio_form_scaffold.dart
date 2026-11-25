import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/draft_confirm_dialog.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Mixin pengelola status draf (dirty-state) dan konfirmasi keluar untuk
/// halaman formulir portofolio.
mixin FormDraftStateMixin<T extends StatefulWidget> on State<T> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _wasDirty = false;

  /// Mengembalikan `true` jika pengguna telah mengubah setidaknya satu isian.
  bool get isFormDirty;

  /// Menyelaraskan status draf saat nilai bidang formulir berubah.
  void syncDirtyState() {
    final dirty = isFormDirty;
    if (dirty != _wasDirty) {
      setState(() {
        _wasDirty = dirty;
      });
    }
  }

  /// Memperbarui state lokal sekaligus menyelaraskan flag dirty-state.
  void setFormState(VoidCallback fn) {
    setState(() {
      fn();
      _wasDirty = isFormDirty;
    });
  }

  /// Memvalidasi status draf sebelum navigasi keluar melalui drawer.
  Future<bool> confirmDiscardDraft() async {
    if (!isFormDirty) return true;
    return showDiscardDraftDialog(context);
  }

  /// Membangun kerangka standar halaman formulir lengkap dengan proteksi draf.
  Widget buildFormScaffold({
    required String title,
    Object? popResult,
    required List<Widget> children,
  }) {
    return PortfolioFormScaffold(
      title: title,
      formKey: formKey,
      isDirty: isFormDirty,
      popResult: popResult,
      onFormChanged: syncDirtyState,
      onWillNavigate: confirmDiscardDraft,
      children: children,
    );
  }
}

/// Kerangka tata letak standar untuk halaman formulir portofolio dengan
/// [FormDraftPopScope], [AppBar], [LeftDrawer], dan [Form] scrollable.
class PortfolioFormScaffold extends StatelessWidget {
  final String title;
  final GlobalKey<FormState> formKey;
  final bool isDirty;
  final Object? popResult;
  final VoidCallback onFormChanged;
  final Future<bool> Function() onWillNavigate;
  final List<Widget> children;

  const PortfolioFormScaffold({
    super.key,
    required this.title,
    required this.formKey,
    required this.isDirty,
    this.popResult,
    required this.onFormChanged,
    required this.onWillNavigate,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return FormDraftPopScope(
      isDirty: isDirty,
      popResult: popResult,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        drawer: LeftDrawer(onWillNavigate: onWillNavigate),
        body: Form(
          key: formKey,
          onChanged: onFormChanged,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
