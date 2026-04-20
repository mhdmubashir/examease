import Razorpay from 'razorpay';
import crypto from 'crypto';
import { Payment } from './payment.model.js';
import { User } from '../users/user.model.js';
import { PaymentStatus } from '../../constants/enums.js';
import logger from '../../utils/logger.js';
import mongoose from 'mongoose';

export class PaymentService {
    private static _razorpay: Razorpay | null = null;

    private static get razorpay(): Razorpay {
        if (!this._razorpay) {
            this._razorpay = new Razorpay({
                key_id: process.env.RAZORPAY_KEY_ID ?? '',
                key_secret: process.env.RAZORPAY_KEY_SECRET ?? '',
            });
        }
        return this._razorpay;
    }

    static async createOrder(userId: string, moduleId: string, amount: number) {
        const options = {
            amount: amount * 100, // razorpay expects in paise
            currency: 'INR',
            receipt: `receipt_${Date.now()}`,
        };

        const order = await this.razorpay.orders.create(options);

        await Payment.create({
            userId,
            moduleId,
            orderId: order.id,
            amount,
            status: PaymentStatus.PENDING,
        });

        return order;
    }

    static verifyWebhookSignature(payload: string, signature: string) {
        const secret = process.env.RAZORPAY_WEBHOOK_SECRET as string;
        const expectedSignature = crypto
            .createHmac('sha256', secret)
            .update(payload)
            .digest('hex');

        return expectedSignature === signature;
    }

    static verifySignature(orderId: string, paymentId: string, signature: string) {
        const secret = process.env.RAZORPAY_KEY_SECRET as string;
        const text = orderId + "|" + paymentId;
        const expectedSignature = crypto
            .createHmac('sha256', secret)
            .update(text)
            .digest('hex');

        return expectedSignature === signature;
    }

    static async verifyPayment(orderId: string, paymentId: string, signature: string) {
        const isValid = this.verifySignature(orderId, paymentId, signature);
        if (!isValid) return false;

        await this.handlePaymentSuccess(orderId, paymentId);
        return true;
    }

    static async handlePaymentSuccess(orderId: string, paymentId: string) {
        const session = await mongoose.startSession();
        session.startTransaction();

        try {
            const payment = await Payment.findOne({ orderId }).session(session);
            if (!payment) {
                logger.error(`Payment not found for orderId: ${orderId}`);
                await session.abortTransaction();
                return;
            }

            if (payment.status === PaymentStatus.SUCCESS) {
                await session.abortTransaction();
                return;
            }

            payment.status = PaymentStatus.SUCCESS;
            payment.paymentId = paymentId;
            await payment.save({ session });

            // Add module to user's purchased items
            await User.findByIdAndUpdate(payment.userId, {
                $addToSet: { purchasedItems: payment.moduleId },
            }, { session });

            await session.commitTransaction();
            logger.info(`Payment successful for user ${payment.userId}, module ${payment.moduleId}`);
        } catch (error) {
            await session.abortTransaction();
            logger.error(`Transaction failed for orderId ${orderId}: ${error}`);
            throw error;
        } finally {
            session.endSession();
        }
    }

    static async handlePaymentFailure(orderId: string, reason: string) {
        const payment = await Payment.findOne({ orderId });
        if (!payment) return;

        payment.status = PaymentStatus.FAILED;
        payment.failureReason = reason;
        await payment.save();

        logger.warn(`Payment failed for orderId: ${orderId}. Reason: ${reason}`);
    }

    static async getAllPayments() {
        return await Payment.find()
            .populate('userId', 'name email profilePic')
            .populate('moduleId', 'title price')
            .sort({ createdAt: -1 });
    }
}
