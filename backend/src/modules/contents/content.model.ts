import { Schema, model, Document, Types } from 'mongoose';
import { ContentType } from '../../constants/enums.js';

export interface IContent extends Document {
    moduleId: Types.ObjectId;
    contentType: ContentType;
    title: string;
    description: string;
    data: Record<string, any>;
    isActive: boolean;
    orderIndex: number;
    tags: string[];
    createdAt: Date;
    updatedAt: Date;
}

const contentSchema = new Schema<IContent>(
    {
        moduleId: { type: Schema.Types.ObjectId, ref: 'Module', required: true, index: true },
        contentType: {
            type: String,
            enum: Object.values(ContentType),
            required: true,
            index: true,
        },
        title: { type: String, required: true },
        description: { type: String, required: true },
        data: { type: Schema.Types.Mixed, default: {} },
        isActive: { type: Boolean, default: true, index: true },
        orderIndex: { type: Number, default: 0 },
        tags: [{ type: String }],
    },
    {
        timestamps: true,
    }
);

export const Content = model<IContent>('Content', contentSchema);
