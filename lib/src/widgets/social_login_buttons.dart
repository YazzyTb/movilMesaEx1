import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onFacebookPressed;
  final VoidCallback? onApplePressed;

  const SocialLoginButtons({
    Key? key,
    this.onGooglePressed,
    this.onFacebookPressed,
    this.onApplePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                thickness: 1,
                color: colorScheme.onBackground.withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'O continúa con',
                style: theme.textTheme.bodySmall,
              ),
            ),
            Expanded(
              child: Divider(
                thickness: 1,
                color: colorScheme.onBackground.withOpacity(0.2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (onGooglePressed != null)
              _SocialButton(
                onPressed: onGooglePressed,
                icon: 'G',
                backgroundColor: isDark ? Colors.white10 : Colors.white,
                iconColor: Colors.red,
                tooltip: 'Continuar con Google',
              ),
            if (onFacebookPressed != null) ...[
              const SizedBox(width: 20),
              _SocialButton(
                onPressed: onFacebookPressed,
                icon: 'f',
                backgroundColor:
                    isDark ? Colors.indigo.shade900 : Colors.indigo.shade500,
                iconColor: Colors.white,
                tooltip: 'Continuar con Facebook',
              ),
            ],
            if (onApplePressed != null) ...[
              const SizedBox(width: 20),
              _SocialButton(
                onPressed: onApplePressed,
                icon: '',
                iconWidget: Icon(
                  Icons.apple,
                  color: isDark ? Colors.white : Colors.black,
                  size: 24,
                ),
                backgroundColor: isDark ? Colors.white10 : Colors.white,
                tooltip: 'Continuar con Apple',
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String icon;
  final Widget? iconWidget;
  final Color backgroundColor;
  final Color? iconColor;
  final String? tooltip;

  const _SocialButton({
    Key? key,
    this.onPressed,
    this.icon = '',
    this.iconWidget,
    required this.backgroundColor,
    this.iconColor,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buttonContent = iconWidget ??
        Text(
          icon,
          style: theme.textTheme.titleLarge?.copyWith(
            color: iconColor,
            fontWeight: FontWeight.bold,
          ),
        );

    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(child: buttonContent),
        ),
      ),
    );
  }
}
