import 'package:flutter/material.dart';
import '../../data/db/app_db.dart';
import '../../services/session_service.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/session/session_card.dart';

class SessionPreviewPage extends StatefulWidget {
  final AppDb db;
  const SessionPreviewPage({super.key, required this.db});

  @override
  State<SessionPreviewPage> createState() => _SessionPreviewPageState();
}

class _SessionPreviewPageState extends State<SessionPreviewPage> {
  late final SessionService _sessionService;
  SessionInfo? _currentSession;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _sessionService = SessionService(widget.db);
    _loadSession();
  }

  Future<void> _loadSession() async {
    setState(() => _isLoading = true);
    try {
      final session = await _sessionService.getRandomSessionInfo(
        exerciseCount: 4,
      );
      if (mounted) {
        setState(() {
          _currentSession = session;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[SESSION_PREVIEW] Erreur: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleNextPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redirection vers la séance...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        title: const Text('Aperçu de la séance'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.gold),
                  )
                  : _currentSession == null
                  ? const Center(
                    child: Text(
                      'Impossible de charger la séance',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                  : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: SessionCard(
                            sessionInfo: _currentSession!,
                            onNextPressed: _handleNextPressed,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: _loadSession,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.gold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh, color: AppTheme.gold),
                              SizedBox(width: 8),
                              Text(
                                'Nouvelle séance',
                                style: TextStyle(
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
