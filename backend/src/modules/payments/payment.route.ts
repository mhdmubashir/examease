import { Router } from 'express';
import { PaymentController } from './payment.controller.js';
import { authenticate } from '../../middleware/auth.middleware.js';
import { validateRequest } from '../../middleware/validate.middleware.js';
import { createOrderSchema } from './payment.validation.js';

const router = Router();

// Order creation (Protected)
router.post('/create-order', authenticate, validateRequest(createOrderSchema), PaymentController.createOrder);

// Verify payment (Protected)
router.post('/verify-payment', authenticate, PaymentController.verifyPayment);

// Webhook (Public, Razorpay will call this)
router.post('/webhook', PaymentController.handleWebhook);
// Admin routes (Protected, ideally should have role check too)
router.get('/admin/all', authenticate, PaymentController.getAllPayments);

export const paymentRoutes = router;
