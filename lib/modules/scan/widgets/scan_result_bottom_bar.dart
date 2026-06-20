import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cacao_apps/modules/scan/controllers/save_scan_controller.dart';

class ScanResultBottomBar extends StatelessWidget {
  final SaveScanController saveController;
  final bool isNonCacao;
  final VoidCallback onSave;
  final VoidCallback onScanAgain;

  const ScanResultBottomBar({
    super.key,
    required this.saveController,
    required this.isNonCacao,
    required this.onSave,
    required this.onScanAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _SaveButton(saveController: saveController, isNonCacao: isNonCacao, onSave: onSave)),
          const SizedBox(width: 12),
          Expanded(flex: 4, child: _ScanAgainButton(onTap: onScanAgain)),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final SaveScanController saveController;
  final bool isNonCacao;
  final VoidCallback onSave;

  const _SaveButton({
    required this.saveController,
    required this.isNonCacao,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: saveController,
      builder: (context, _) {
        final disabled = saveController.isSaving || isNonCacao;
        final saved = saveController.isSaved;

        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: saved ? const Color(0xFF2D6A4F) : Colors.black.withAlpha(20),
              width: 1.5,
            ),
            backgroundColor: Colors.white,
            foregroundColor: saved ? const Color(0xFF2D6A4F) : Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: disabled || saved ? null : onSave,
          child: saveController.isSaving
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2D6A4F)),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      saved ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isNonCacao ? "N/A" : (saved ? "SAVED" : "SAVE"),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _ScanAgainButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ScanAgainButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A7C59), Color(0xFF2D6A4F)],
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: const Text(
          "SCAN AGAIN",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}