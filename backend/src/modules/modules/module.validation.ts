import { z } from 'zod';
import { AccessType } from '../../constants/enums.js';

const baseModuleBodySchema = z.object({
    examId: z.string().min(1, 'Exam ID is required'),
    title: z.string().min(1, 'Title is required'),
    description: z.string().min(1, 'Description is required'),
    thumbnail: z.string().min(1, 'Thumbnail is required'),
    price: z.number().min(0),
    discountPrice: z.number().min(0),
    accessType: z.enum([AccessType.FREE, AccessType.PAID]),
    isBundle: z.boolean().optional(),
    includedModules: z.array(z.string()).optional(),
    validityDays: z.number().min(0).optional(),
    isActive: z.boolean().optional(),
    orderIndex: z.number().optional(),
    metadata: z.record(z.string(), z.any()).optional(),
});

export const createModuleSchema = z.object({
    body: baseModuleBodySchema.refine((data) => data.discountPrice <= data.price, {
        message: 'Discount price must be less than or equal to original price',
        path: ['discountPrice'],
    }),
});

export const updateModuleSchema = z.object({
    body: baseModuleBodySchema.partial(),
});
