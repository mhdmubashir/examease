import { z } from 'zod';

export const createExamSchema = z.object({
    body: z.object({
        title: z.string().min(1, 'Title is required'),
        description: z.string().min(1, 'Description is required'),
        icon: z.string().min(1, 'Icon is required'),
        bannerImage: z.string().min(1, 'Banner image is required'),
        themeColor: z.string().min(1, 'Theme color is required'),
        isActive: z.boolean().optional(),
        orderIndex: z.number().optional(),
        metadata: z.record(z.string(), z.any()).optional(),
    }),
});

export const updateExamSchema = z.object({
    body: createExamSchema.shape.body.partial(),
});
