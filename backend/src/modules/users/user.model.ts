import { Schema, model, Document } from 'mongoose';
import { UserRole } from '../../constants/enums.js';

export interface IUser extends Document {
    name: string;
    email: string;
    phone: string;
    passwordHash?: string; // Optional for Google users
    googleId?: string;     // Unique ID from Google
    isVerified: boolean;   // Whether account is OTP verified
    otp?: string;          // 4-digit verification code
    otpExpiresAt?: Date;   // OTP expiration time
    role: UserRole;
    purchasedItems: Schema.Types.ObjectId[];
    subscription: {
        planId: Schema.Types.ObjectId;
        expiryDate: Date;
        isActive: boolean;
    };
    isBlocked: boolean;
    lastLoginAt: Date;
    createdAt: Date;
    updatedAt: Date;
}

const userSchema = new Schema<IUser>(
    {
        name: { type: String, required: true },
        email: { type: String, required: true, unique: true, index: true },
        phone: { type: String },
        passwordHash: { type: String, select: false },
        googleId: { type: String, unique: true, sparse: true, index: true },
        isVerified: { type: Boolean, default: false },
        otp: { type: String },
        otpExpiresAt: { type: Date },
        role: {
            type: String,
            enum: Object.values(UserRole),
            default: UserRole.USER,
            index: true,
        },
        purchasedItems: [{ type: Schema.Types.ObjectId, ref: 'Module' }],
        subscription: {
            planId: { type: Schema.Types.ObjectId, ref: 'SubscriptionPlan' },
            expiryDate: { type: Date },
            isActive: { type: Boolean, default: false },
        },
        isBlocked: { type: Boolean, default: false },
        lastLoginAt: { type: Date },
    },
    {
        timestamps: true,
    }
);

export const User = model<IUser>('User', userSchema);
