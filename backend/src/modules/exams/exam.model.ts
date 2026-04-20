import { Schema, model, Document } from 'mongoose';

export interface IExam extends Document {
    title: string;
    slug: string;
    description: string;
    icon: string;
    bannerImage: string;
    themeColor: string;
    isActive: boolean;
    orderIndex: number;
    metadata: Record<string, any>;
    createdAt: Date;
    updatedAt: Date;
}

const examSchema = new Schema<IExam>(
    {
        title: { type: String, required: true },
        slug: { type: String, required: true, unique: true, index: true },
        description: { type: String, required: true },
        icon: { type: String, required: true },
        bannerImage: { type: String, required: true },
        themeColor: { type: String, required: true },
        isActive: { type: Boolean, default: true, index: true },
        orderIndex: { type: Number, default: 0 },
        metadata: { type: Schema.Types.Mixed, default: {} },
    },
    {
        timestamps: true,
    }
);

export const Exam = model<IExam>('Exam', examSchema);
