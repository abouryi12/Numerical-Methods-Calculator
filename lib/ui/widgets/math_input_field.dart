import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../core/expression_parser.dart';
import '../theme/app_theme.dart';

/// Math expression input field with live LaTeX preview.
class MathInputField extends StatefulWidget {
  final String? initialExpression;
  final ValueChanged<String> onChanged;
  final String? errorText;

  const MathInputField({
    super.key,
    this.initialExpression,
    required this.onChanged,
    this.errorText,
  });

  @override
  State<MathInputField> createState() => _MathInputFieldState();
}

class _MathInputFieldState extends State<MathInputField> {
  late final TextEditingController _controller;
  final _parser = ExpressionParser();
  String _latex = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialExpression ?? '');
    _updateLatex(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateLatex(String expr) {
    try {
      _latex = _parser.toLatex(expr);
    } catch (_) {
      _latex = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label.
        Text('FUNCTION', style: labelStyle),
        const SizedBox(height: kSpace2),

        // Input field.
        TextField(
          controller: _controller,
          style: monoStyle(fontSize: kTextBase, color: kTextPrimary),
          cursorColor: kAccentBlue,
          decoration: InputDecoration(
            hintText: 'e.g. x^3 - 2*x + 1',
            errorText: widget.errorText,
          ),
          onChanged: (value) {
            setState(() => _updateLatex(value));
            widget.onChanged(value);
          },
        ),
        const SizedBox(height: kSpace3),

        // Preview label.
        Text('PREVIEW', style: labelStyle),
        const SizedBox(height: kSpace2),

        // LaTeX preview pane.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(kSpace3),
          decoration: BoxDecoration(
            color: kBgBase,
            borderRadius: BorderRadius.circular(kRadiusSM),
            border: Border.all(color: kBgBorder, width: 1),
          ),
          constraints: const BoxConstraints(minHeight: 48),
          child: _latex.isEmpty
              ? Text(
                  '—',
                  style: monoStyle(
                    fontSize: kTextLG,
                    color: kTextMuted,
                  ),
                )
              : _buildMathPreview(),
        ),
      ],
    );
  }

  Widget _buildMathPreview() {
    try {
      return Math.tex(
        _latex,
        textStyle: const TextStyle(
          fontSize: kTextLG,
          color: kTextPrimary,
        ),
      );
    } catch (_) {
      // Fallback to plain text if LaTeX fails.
      return Text(
        _controller.text,
        style: monoStyle(fontSize: kTextLG, color: kTextPrimary),
      );
    }
  }
}
