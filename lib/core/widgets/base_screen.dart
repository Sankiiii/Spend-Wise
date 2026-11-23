import 'package:material_ui/material_ui.dart';
import 'package:spend_wise/core/constants/app_spacing.dart';

/// A foundational wrapper widget that provides:
/// 1. Automatic keyboard dismissal on outside tap.
/// 2. Tablet / desktop max-width constraints.
/// 3. SafeArea protection against notches and home bars.
/// 4. Zero RenderFlex overflow scroll protection.
class BaseScreen extends StatelessWidget {
  const BaseScreen({
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.isScrollable = false,
    this.padding = AppSpacing.screenPadding,
    super.key,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final bool isScrollable;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: appBar,
        resizeToAvoidBottomInset: true,
        floatingActionButton: floatingActionButton,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Clamp to 600px max width for tablet & web responsiveness
              final maxWidth = constraints.maxWidth > 600
                  ? 600.0
                  : constraints.maxWidth;

              final content = Center(
                child: SizedBox(
                  width: maxWidth,
                  child: Padding(
                    padding: padding,
                    child: body,
                  ),
                ),
              );

              if (isScrollable) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: content,
                );
              }

              return content;
            },
          ),
        ),
      ),
    );
  }
}
