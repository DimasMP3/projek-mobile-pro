import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/app_routes.dart';
import '../../services/payment_service.dart';
import '../styles/colors.dart' as app_colors;

class PaymentWebViewPage extends StatefulWidget {
  const PaymentWebViewPage({super.key});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late WebViewController _controller;
  bool _isLoading = true;
  String? _orderId;
  Map<String, dynamic> _paymentData = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _paymentData = Map<String, dynamic>.from(args);
      _orderId = _paymentData['orderId'] as String?;
      final redirectUrl = _paymentData['redirectUrl'] as String?;

      if (redirectUrl != null) {
        _initWebView(redirectUrl);
      }
    }
  }

  void _initWebView(String url) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(app_colors.bg)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() => _isLoading = false);
            }
          },
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _checkPaymentResult(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void _checkPaymentResult(String url) {
    // Check for Midtrans callback URLs
    if (url.contains('transaction_status=settlement') ||
        url.contains('transaction_status=capture') ||
        url.contains('status_code=200')) {
      _handlePaymentSuccess();
    } else if (url.contains('transaction_status=pending')) {
      _handlePaymentPending();
    } else if (url.contains('transaction_status=deny') ||
               url.contains('transaction_status=cancel') ||
               url.contains('transaction_status=expire')) {
      _handlePaymentFailed();
    }
  }

  void _handlePaymentSuccess() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.paymentSuccess,
      arguments: {
        'orderId': _orderId,
        'status': 'success',
        ..._paymentData,
      },
    );
  }

  void _handlePaymentPending() {
    // Start polling for status
    _startPolling();
  }

  void _handlePaymentFailed() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.paymentSuccess,
      arguments: {
        'orderId': _orderId,
        'status': 'failed',
        ..._paymentData,
      },
    );
  }

  void _startPolling() async {
    if (_orderId == null) return;

    final paymentService = PaymentService();
    
    await for (final status in paymentService.pollStatus(_orderId!)) {
      if (!mounted) return;

      if (status.isPaid) {
        _handlePaymentSuccess();
        break;
      } else if (status.isFailed) {
        _handlePaymentFailed();
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final redirectUrl = _paymentData['redirectUrl'] as String?;

    return Scaffold(
      backgroundColor: app_colors.bg,
      appBar: AppBar(
        backgroundColor: app_colors.bg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => _showExitConfirmation(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: app_colors.glassWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: app_colors.glassBorder),
            ),
            child: Icon(
              Icons.close_rounded,
              color: app_colors.textPrimary,
              size: 18,
            ),
          ),
        ),
        title: Text(
          'Pembayaran',
          style: TextStyle(
            color: app_colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(app_colors.primary),
                ),
              ),
            ),
        ],
      ),
      body: redirectUrl == null
          ? _buildErrorState()
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(app_colors.primary),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Memuat halaman pembayaran...',
                          style: TextStyle(
                            color: app_colors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: app_colors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'URL pembayaran tidak tersedia',
            style: TextStyle(
              color: app_colors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: app_colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  Future<void> _showExitConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: app_colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Batalkan Pembayaran?',
          style: TextStyle(color: app_colors.textPrimary),
        ),
        content: Text(
          'Transaksi belum selesai. Yakin ingin keluar?',
          style: TextStyle(color: app_colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Tidak',
              style: TextStyle(color: app_colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Ya, Batalkan',
              style: TextStyle(color: app_colors.primary),
            ),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context);
    }
  }
}
