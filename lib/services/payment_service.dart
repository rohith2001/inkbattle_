// import 'dart:developer';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:inkbattle_frontend/config/environment.dart';
// import 'package:inkbattle_frontend/repositories/user_repository.dart';
// import 'package:flutter/material.dart';

// class PaymentService {
//   static final PaymentService _instance = PaymentService._internal();
//   factory PaymentService() => _instance;
//   PaymentService._internal();

//   final UserRepository _userRepository = UserRepository();
//   late Razorpay _razorpay;
//   Function(int coins)? onPaymentSuccess;
//   Function()? onPaymentError;
//   BuildContext? _context;

//   bool _isInitialized = false;

//   void initialize() {
//     if (!_isInitialized) {
//       _razorpay = Razorpay();
//       _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//       _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//       _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//       _isInitialized = true;
//       log('Razorpay initialized');
//     }
//   }

//   void dispose() {
//     if (_isInitialized) {
//       _razorpay.clear();
//       _isInitialized = false;
//     }
//   }

//   Future<void> initiatePayment({
//     required BuildContext context,
//     Function(int coins)? onSuccess,
//     Function()? onError,
//   }) async {
//     _context = context;
//     onPaymentSuccess = onSuccess;
//     onPaymentError = onError;

//     // Ensure Razorpay is initialized
//     if (!_isInitialized) {
//       initialize();
//     }

//     try {
//       final amount = Environment.paymentAmount; // Amount in rupees (1000)
//       final amountInPaise = amount * 100; // Convert to paise
//       final keyId = Environment.razorpayKeyId;
      
//       // Validate key
//       if (keyId.isEmpty) {
//         throw Exception('Razorpay key is empty. Please check .env file.');
//       }
      
//       log('Initiating payment: Amount=${amountInPaise}paise (₹$amount), Key=${keyId.substring(0, 10)}...');
//       log('Coins to award: ${Environment.coinsOnPayment}');

//       var options = {
//         'key': keyId,
//         'amount': amountInPaise,
//         'name': 'Ink Battle',
//         'description': 'Buy ${Environment.coinsOnPayment} Coins',
//         'prefill': {
//           'contact': '',
//           'email': '',
//         },
//         'external': {
//           'wallets': ['paytm']
//         }
//       };

//       log('Opening Razorpay payment dialog...');
//       // Use Future.microtask to ensure this runs on the UI thread
//       await Future.microtask(() {
//         _razorpay.open(options);
//       });
//       log('Razorpay.open() called successfully');
//     } catch (e, stackTrace) {
//       log('Error initiating payment: $e');
//       log('Stack trace: $stackTrace');
//       if (_context != null && _context!.mounted) {
//         ScaffoldMessenger.of(_context!).showSnackBar(
//           SnackBar(
//             content: Text('Payment initiation failed: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//       // Call error callback to reset processing state
//       onPaymentError?.call();
//     }
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     log('Payment Success: ${response.paymentId}');
    
//     // Verify payment with backend and add coins
//     _verifyPaymentAndAddCoins(
//       paymentId: response.paymentId ?? '',
//       orderId: response.orderId ?? '',
//       signature: response.signature ?? '',
//     );
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     log('Payment Error: ${response.code} - ${response.message}');
//     if (_context != null && _context!.mounted) {
//       ScaffoldMessenger.of(_context!).showSnackBar(
//         SnackBar(
//           content: Text('Payment failed: ${response.message ?? 'Unknown error'}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//     // Call error callback
//     onPaymentError?.call();
//     // Reset callbacks
//     onPaymentSuccess = null;
//     onPaymentError = null;
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     log('External Wallet: ${response.walletName}');
//     if (_context != null && _context!.mounted) {
//       ScaffoldMessenger.of(_context!).showSnackBar(
//         SnackBar(
//           content: Text('External wallet selected: ${response.walletName}'),
//         ),
//       );
//     }
//   }

//   Future<void> _verifyPaymentAndAddCoins({
//     required String paymentId,
//     required String orderId,
//     required String signature,
//   }) async {
//     try {
//       // Call backend to verify payment and add coins
//       final result = await _userRepository.addCoins(
//         amount: Environment.coinsOnPayment,
//         reason: 'razorpay_payment',
//       );

//       result.fold(
//         (failure) {
//           log('Failed to add coins: ${failure.message}');
//           if (_context != null && _context!.mounted) {
//             ScaffoldMessenger.of(_context!).showSnackBar(
//               SnackBar(
//                 content: Text('Payment successful but failed to add coins: ${failure.message}'),
//                 backgroundColor: Colors.orange,
//               ),
//             );
//           }
//           // Reset callbacks
//           onPaymentError?.call();
//           onPaymentSuccess = null;
//           onPaymentError = null;
//         },
//         (user) {
//           log('Coins added successfully: ${Environment.coinsOnPayment}');
          
//           // Just call the success callback, let the caller handle the animation
//           onPaymentSuccess?.call(Environment.coinsOnPayment);
          
//           // Reset callbacks
//           onPaymentSuccess = null;
//           onPaymentError = null;
//         },
//       );
//     } catch (e) {
//       log('Error verifying payment: $e');
//       if (_context != null && _context!.mounted) {
//         ScaffoldMessenger.of(_context!).showSnackBar(
//           SnackBar(
//             content: Text('Error processing payment: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//       // Reset callbacks on error
//       onPaymentError?.call();
//       onPaymentSuccess = null;
//       onPaymentError = null;
//     }
//   }
// }

