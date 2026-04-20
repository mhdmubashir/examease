import { Schema, model, Document, Types } from 'mongoose';

export interface IQuestion extends Document {
    mockTestId: Types.ObjectId;
    questionText: string;
    questionImage?: string;
    options: {
        text: string;
        image?: string;
        isCorrect: boolean;
    }[];
    explanation?: string;
    marks: number;
    negativeMarks: number;
    difficultyLevel: 'EASY' | 'MEDIUM' | 'HARD';
    tags: string[];
    createdAt: Date;
    updatedAt: Date;
}

const questionSchema = new Schema<IQuestion>(
    {
        mockTestId: { type: Schema.Types.ObjectId, ref: 'Content', required: true, index: true },
        questionText: { type: String, required: true },
        questionImage: { type: String },
        options: [
            {
                text: { type: String, required: true },
                image: { type: String },
                isCorrect: { type: Boolean, required: true },
            },
        ],
        explanation: { type: String },
        marks: { type: Number, required: true, default: 1 },
        negativeMarks: { type: Number, required: true, default: 0 },
        difficultyLevel: {
            type: String,
            enum: ['EASY', 'MEDIUM', 'HARD'],
            default: 'MEDIUM',
            index: true,
        },
        tags: [{ type: String }],
    },
    {
        timestamps: true,
    }
);

// Compound index for efficient test generation/filtering
questionSchema.index({ mockTestId: 1, difficultyLevel: 1 });

export const Question = model<IQuestion>('Question', questionSchema);
