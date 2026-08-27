import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../core/analytics/analytics.dart';
import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../models/cv.dart';
import '../state/cv_provider.dart';
import 'common/glass_card.dart';
import 'common/reveal.dart';
import 'common/section_shell.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv == null) return const SizedBox.shrink();

    return SectionShell(
      index: '05',
      label: 'CONTACT',
      title: 'Get in touch',
      subtitle: 'The fastest way to reach me',
      child: Column(
        children: [
          Reveal(child: _CtaBand(cv: cv)),
          const SizedBox(height: AppSpace.md),
          Reveal(delay: AppMotion.stagger, child: _ContactForm(email: cv.email)),
        ],
      ),
    );
  }
}

class _CtaBand extends StatelessWidget {
  final CV cv;

  const _CtaBand({required this.cv});

  static String _whatsappNumber(String phone) => phone.replaceAll(RegExp(r'[^0-9]'), '');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: p.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: p.gradient.first.withValues(alpha: 0.32),
            blurRadius: 38,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Let's build something together",
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            'Open to interesting mobile work and collaborations.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.86)),
          ),
          const SizedBox(height: AppSpace.lg),
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            alignment: WrapAlignment.center,
            children: [
              _CtaButton(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                filled: true,
                onPressed: () {
                  trackEvent('contact_email_click', params: {'method': 'mailto'});
                  launchUrlString('mailto:${cv.email}');
                },
              ),
              _CtaButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'WhatsApp',
                onPressed: () {
                  trackEvent('contact_whatsapp_click', params: {'method': 'wa.me'});
                  launchUrlString(
                    'https://wa.me/${_whatsappNumber(cv.phone)}',
                    webOnlyWindowName: '_blank',
                  );
                },
              ),
              _CtaButton(
                icon: Icons.business_center_rounded,
                label: 'LinkedIn',
                onPressed: () {
                  trackEvent('outbound_click', params: {'network': 'linkedin'});
                  launchUrlString(cv.linkedin, webOnlyWindowName: '_blank');
                },
              ),
              _CtaButton(
                icon: Icons.code_rounded,
                label: 'GitHub',
                onPressed: () {
                  trackEvent('outbound_click', params: {'network': 'github'});
                  launchUrlString(cv.github, webOnlyWindowName: '_blank');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onPressed;

  const _CtaButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (filled) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: p.brand),
        icon: Icon(icon, size: 18),
        label: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _ContactForm extends StatefulWidget {
  final String email;

  const _ContactForm({required this.email});

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _send() {
    if (!_formKey.currentState!.validate()) return;

    final subject = Uri.encodeComponent('Contact from ${_nameCtrl.text}');
    final body = Uri.encodeComponent(
      'From: ${_nameCtrl.text} <${_emailCtrl.text}>\n\n${_messageCtrl.text}',
    );
    trackEvent('contact_form_send', params: {'method': 'mailto'});
    launchUrlString('mailto:${widget.email}?subject=$subject&body=$body');

    _nameCtrl.clear();
    _emailCtrl.clear();
    _messageCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening email client…')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send me a message', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpace.lg),
            _Field(
              controller: _nameCtrl,
              label: 'Your name',
              icon: Icons.person_outline_rounded,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter your name' : null,
            ),
            const SizedBox(height: AppSpace.md),
            _Field(
              controller: _emailCtrl,
              label: 'Your email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your email';
                if (!value.contains('@')) return 'Please enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: AppSpace.md),
            _Field(
              controller: _messageCtrl,
              label: 'Your message',
              icon: Icons.message_outlined,
              maxLines: 4,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter a message' : null,
            ),
            const SizedBox(height: AppSpace.lg),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _send,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Send message'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}
