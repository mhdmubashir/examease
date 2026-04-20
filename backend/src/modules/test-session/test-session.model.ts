import { Schema, model, Document, Types } from 'mongoose';
import { TestSessionStatus } from '../../constants/enums.js';

export interface ITestSession extends Document {
    userId: Types.ObjectId;
    mockTestId: Types.ObjectId;
    status: TestSessionStatus;
    startedAt: Date;
    submittedAt?: Date;
    answers: {
        questionId: Types.ObjectId;
        selectedOptionIndex: number;
        isCorrect: boolean;
        timeTakenSeconds: number;
    }[];
    score: number;
    accuracy: number;
    timeTaken: number; // total time in seconds
    rank?: number;
    createdAt: Date;
    updatedAt: Date;
}

const testSessionSchema = new Schema<ITestSession>(
    {
        userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
        mockTestId: { type: Schema.Types.ObjectId, ref: 'Content', required: true, index: true },
        status: {
            type: String,
            enum: Object.values(TestSessionStatus),
            default: TestSessionStatus.ONGOING,
            index: true,
        },
        startedAt: { type: Date, default: Date.now },
        submittedAt: { type: Date },
        answers: [
            {
                questionId: { type: Schema.Types.ObjectId, ref: 'Question' },
                selectedOptionIndex: { type: Number },
                isCorrect: { type: Boolean },
                timeTakenSeconds: { type: Number },
            },
        ],
        score: { type: Number, default: 0 },
        accuracy: { type: Number, default: 0 },
        timeTaken: { type: Number, default: 0 },
        rank: { type: Number },
    },
    {
        timestamps: true,
    }
);

// Ensure only one active session per user per test
testSessionSchema.index({ userId: 1, mockTestId: 1, status: 1 }, {
    unique: true,
    partialFilterExpression: { status: TestSessionStatus.ONGOING }
});

export const TestSession = model<ITestSession>('TestSession', testSessionSchema);
