import { Schema, model, Document, Types } from 'mongoose';
import { PaymentStatus } from '../../constants/enums.js';

export interface IPayment extends Document {
    userId: Types.ObjectId;
    moduleId: Types.ObjectId;
    orderId: string; // Razorpay order ID
    paymentId?: string; // Razorpay payment ID (filled after success)
    amount: number;
    currency: string;
    status: PaymentStatus;
    failureReason?: string;
    metadata?: Record<string, any>;
    createdAt: Date;
    updatedAt: Date;
}

const paymentSchema = new Schema<IPayment>(
    {
        userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
        moduleId: { type: Schema.Types.ObjectId, ref: 'Module', required: true, index: true },
        orderId: { type: String, required: true, unique: true, index: true },
        paymentId: { type: String, index: true },
        amount: { type: Number, required: true },
        currency: { type: String, default: 'INR' },
        status: {
            type: String,
            enum: Object.values(PaymentStatus),
            default: PaymentStatus.PENDING,
            index: true,
        },
        failureReason: { type: String },
        metadata: { type: Schema.Types.Mixed },
    },
    {
        timestamps: true,
    }
);

export const Payment = model<IPayment>('Payment', paymentSchema);
