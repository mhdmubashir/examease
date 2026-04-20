import { Schema, model, Document, Types } from 'mongoose';
import { AccessType } from '../../constants/enums.js';

export interface IModule extends Document {
    examId: Types.ObjectId;
    title: string;
    description: string;
    thumbnail: string;
    price: number;
    discountPrice: number;
    accessType: AccessType;
    isBundle: boolean;
    includedModules: Types.ObjectId[];
    validityDays: number;
    isActive: boolean;
    orderIndex: number;
    metadata: Record<string, any>;
    createdAt: Date;
    updatedAt: Date;
}

const moduleSchema = new Schema<IModule>(
    {
        examId: { type: Schema.Types.ObjectId, ref: 'Exam', required: true, index: true },
        title: { type: String, required: true },
        description: { type: String, required: true },
        thumbnail: { type: String, required: true },
        price: { type: Number, required: true, default: 0 },
        discountPrice: { type: Number, required: true, default: 0 },
        accessType: {
            type: String,
            enum: Object.values(AccessType),
            default: AccessType.FREE,
        },
        isBundle: { type: Boolean, default: false },
        includedModules: [{ type: Schema.Types.ObjectId, ref: 'Module' }],
        validityDays: { type: Number, default: 0 }, // 0 means lifetime
        isActive: { type: Boolean, default: true, index: true },
        orderIndex: { type: Number, default: 0 },
        metadata: { type: Schema.Types.Mixed, default: {} },
    },
    {
        timestamps: true,
    }
);

export const Module = model<IModule>('Module', moduleSchema);
