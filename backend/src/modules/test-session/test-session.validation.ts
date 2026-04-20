import { z } from 'zod';

export const startSessionSchema = z.object({
    body: z.object({
        mockTestId: z.string().min(1, 'Mock Test ID is required'),
    }),
});

export const submitSessionSchema = z.object({
    body: z.object({
        answers: z.array(
            z.object({
                questionId: z.string().min(1, 'Question ID is required'),
                selectedOptionIndex: z.number().min(0),
                timeTakenSeconds: z.number().min(0),
            })
        ),
    }),
});
