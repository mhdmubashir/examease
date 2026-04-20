import { z } from 'zod';
import { AdPlacement } from '../../constants/enums.js';

const baseAdBodySchema = z.object({
    title: z.string().min(1, 'Title is required'),
    image: z.object({
        documentId: z.string().min(1, 'documentId is required'),
        name: z.string().min(1, 'name is required'),
        mime: z.string().min(1, 'mime is required'),
        url: z.string().url('Invalid image URL'),
    }),
    videoUrl: z.string().url('Invalid video URL').optional(),
    clickUrl: z.string().url('Invalid redirect URL').optional(),
    placement: z.enum(Object.values(AdPlacement) as [string, ...string[]]),
    startDate: z.string().datetime(),
    endDate: z.string().datetime(),
    isActive: z.boolean().optional(),
    orderIndex: z.number().optional(),
    metadata: z.record(z.string(), z.any()).optional(),
});

export const createAdSchema = z.object({
    body: baseAdBodySchema.refine((data) => new Date(data.endDate) > new Date(data.startDate), {
        message: 'End date must be after start date',
        path: ['endDate'],
    }),
});

export const updateAdSchema = z.object({
    body: baseAdBodySchema.partial(),
});
