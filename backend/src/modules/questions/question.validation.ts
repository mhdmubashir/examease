import { z } from 'zod';

export const createQuestionSchema = z.object({
    body: z.object({
        mockTestId: z.string().min(1, 'Mock Test ID is required'),
        questionText: z.string().min(1, 'Question text is required'),
        questionImage: z.string().optional(),
        options: z.array(
            z.object({
                text: z.string().min(1, 'Option text is required'),
                image: z.string().optional(),
                isCorrect: z.boolean(),
            })
        ).min(2, 'At least 2 options are required'),
        explanation: z.string().optional(),
        marks: z.number().min(0).optional(),
        negativeMarks: z.number().min(0).optional(),
        difficultyLevel: z.enum(['EASY', 'MEDIUM', 'HARD']).optional(),
        tags: z.array(z.string()).optional(),
    }),
});

export const bulkQuestionSchema = z.object({
    body: z.array(createQuestionSchema.shape.body),
});

export const updateQuestionSchema = z.object({
    body: createQuestionSchema.shape.body.partial(),
});
