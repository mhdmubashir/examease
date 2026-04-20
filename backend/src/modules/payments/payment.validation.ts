import { z } from 'zod';

export const createOrderSchema = z.object({
    body: z.object({
        moduleId: z.string().min(1, 'Module ID is required'),
    }),
});
