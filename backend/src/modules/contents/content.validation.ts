import { z } from 'zod';
import { ContentType } from '../../constants/enums.js';

// Base content schema
const baseContentBody = {
    moduleId: z.string().min(1, 'Module ID is required'),
    title: z.string().min(1, 'Title is required'),
    description: z.string().min(1, 'Description is required'),
    isActive: z.boolean().optional(),
    orderIndex: z.number().optional(),
    tags: z.array(z.string()).optional(),
};

// Data schemas for specific content types
const mockTestDataSchema = z.object({
    durationMinutes: z.number().min(1),
    totalMarks: z.number().min(0),
    negativeMark: z.number().min(0),
    questionCount: z.number().min(0),
    shuffleQuestions: z.boolean().optional(),
    showResultImmediately: z.boolean().optional(),
});

export const createContentSchema = z.discriminatedUnion('contentType', [
    z.object({
        contentType: z.literal(ContentType.MOCK_TEST),
        ...baseContentBody,
        data: mockTestDataSchema,
    }),
    z.object({
        contentType: z.literal(ContentType.PDF),
        ...baseContentBody,
        data: z.object({
            fileUrl: z.string().url().optional(),
            s3Key: z.string().min(1).optional(),
            media: z.any().optional(),
            pageCount: z.number().optional(),
        }).refine(data => data.fileUrl || data.s3Key || data.media, {
            message: "Either fileUrl, s3Key or media object is required",
        }),
    }),
    z.object({
        contentType: z.literal(ContentType.VIDEO),
        ...baseContentBody,
        data: z.object({
            s3Key: z.string().min(1, 'S3 key is required').optional(),
            media: z.any().optional(),
            originalFileName: z.string().optional(),
            fileSize: z.number().optional(),
            mimeType: z.string().optional(),
            durationSeconds: z.number().optional(),
        }).refine(data => data.s3Key || data.media, {
            message: "Either s3Key or media object is required",
        }),
    }),
    z.object({
        contentType: z.literal(ContentType.NOTE),
        ...baseContentBody,
        data: z.object({
            content: z.string(),
        }),
    }),
    z.object({
        contentType: z.literal(ContentType.PRACTICE_SET),
        ...baseContentBody,
        data: z.object({
            questionCount: z.number(),
        }),
    }),
]);

export const updateContentSchema = z.object({
    body: z.object({
        title: z.string().optional(),
        description: z.string().optional(),
        data: z.record(z.string(), z.any()).optional(),
        isActive: z.boolean().optional(),
        orderIndex: z.number().optional(),
        tags: z.array(z.string()).optional(),
    }),
});

// Since Zod discriminatedUnion works on a single object, we need to wrap it for middleware
export const createContentMiddlewareSchema = z.object({
    body: createContentSchema,
});
