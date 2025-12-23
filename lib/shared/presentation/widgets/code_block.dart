import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeBlock extends StatefulWidget {
  final String code;

  const CodeBlock(this.code, {super.key});

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  bool _copied = false;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: widget.code));

    setState(() => _copied = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 12, 40, 12),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            widget.code,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),

        Positioned(
          top: 8,
          right: 4,
          child: IconButton(
            tooltip: _copied ? "Copied" : "Copy to clipboard",
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Icon(
                _copied ? Icons.check : Icons.copy,
                key: ValueKey(_copied),
                size: 18,
                color: _copied ? Colors.greenAccent : Colors.white70,
              ),
            ),
            onPressed: _copied ? null : () => _copy(context),
          ),
        ),
      ],
    );
  }
}
