import { Schema, model, Document } from 'mongoose';
import { AdPlacement } from '../../constants/enums.js';

export interface IAd extends Document {
    title: string;
    image: {
        documentId: string;
        name: string;
        mime: string;
        url: string;
    };
    videoUrl?: string; // Optional for video ads
    clickUrl?: string; // Redirect URL
    placement: AdPlacement;
    startDate: Date;
    endDate: Date;
    isActive: boolean;
    orderIndex: number;
    metadata: Record<string, any>;
    createdAt: Date;
    updatedAt: Date;
}

const adSchema = new Schema<IAd>(
    {
        title: { type: String, required: true },
        image: {
            documentId: { type: String, required: true },
            name: { type: String, required: true },
            mime: { type: String, required: true },
            url: { type: String, required: true },
        },
        videoUrl: { type: String },
        clickUrl: { type: String },
        placement: {
            type: String,
            enum: Object.values(AdPlacement),
            required: true,
            index: true,
        },
        startDate: { type: Date, required: true, index: true },
        endDate: { type: Date, required: true, index: true },
        isActive: { type: Boolean, default: true, index: true },
        orderIndex: { type: Number, default: 0 },
        metadata: { type: Schema.Types.Mixed, default: {} },
    },
    {
        timestamps: true,
    }
);

export const Ad = model<IAd>('Ad', adSchema);
