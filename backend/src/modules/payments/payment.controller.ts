import type { Request, Response, NextFunction } from 'express';
import { PaymentService } from './payment.service.js';
import { Module } from '../modules/module.model.js';
import { sendResponse, sendError } from '../../utils/response.util.js';
import type { AuthRequest } from '../../middleware/auth.middleware.js';

export class PaymentController {
    static async createOrder(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const { moduleId } = req.body;
            const userId = req.user!.userId;

            const module = await Module.findById(moduleId);
            if (!module) return sendError(res, 404, 'Module not found');

            const amount = module.discountPrice || module.price;
            if (amount <= 0) {
                // Handle free module purchase directly if needed
                return sendError(res, 400, 'This module is free. Access it directly.');
            }

            const order = await PaymentService.createOrder(userId, moduleId, amount);
            return sendResponse(res, 201, true, 'Order created successfully', order);
        } catch (error) {
            next(error);
        }
    }

    static async verifyPayment(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const { orderId, paymentId, signature } = req.body;
            const success = await PaymentService.verifyPayment(orderId, paymentId, signature);
            if (success) {
                return sendResponse(res, 200, true, 'Payment verified successfully');
            } else {
                return sendError(res, 400, 'Invalid payment signature');
            }
        } catch (error) {
            next(error);
        }
    }

    static async handleWebhook(req: Request, res: Response, next: NextFunction) {
        try {
            const signature = req.headers['x-razorpay-signature'] as string;
            const payload = JSON.stringify(req.body);

            const isValid = PaymentService.verifyWebhookSignature(payload, signature);
            if (!isValid) {
                return res.status(400).send('Invalid signature');
            }

            const event = req.body.event;
            const { order_id, id: payment_id, error_description } = req.body.payload.payment.entity;

            if (event === 'payment.captured') {
                await PaymentService.handlePaymentSuccess(order_id, payment_id);
            } else if (event === 'payment.failed') {
                await PaymentService.handlePaymentFailure(order_id, error_description || 'Unknown error');
            }

            return res.status(200).json({ status: 'ok' });
        } catch (error) {
            next(error);
        }
    }
    static async getAllPayments(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            // Fetch all payments with populated user and module data (to make it complete for admin panel)
            const payments = await PaymentService.getAllPayments();
            return sendResponse(res, 200, true, 'Payments fetched successfully', payments);
        } catch (error) {
            next(error);
        }
    }
}
