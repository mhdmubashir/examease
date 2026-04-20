import type { Response, NextFunction } from 'express';
import { randomUUID } from 'crypto';
import path from 'path';
import { s3Service } from '../../utils/s3.service.js';
import { redisService, CacheKeys } from '../../utils/redis.service.js';
import { ContentService } from './content.service.js';
import { ContentType } from '../../constants/enums.js';
import { sendResponse, sendError } from '../../utils/response.util.js';
import type { AuthRequest } from '../../middleware/auth.middleware.js';
import logger from '../../utils/logger.js';
import { buildMediaObject } from '../../utils/media.util.js';

/**
 * Document Controller — Handles PDF upload to S3 and presigned URL generation.
 */

const ALLOWED_DOC_TYPES = [
    'application/pdf',
];

export class DocumentController {
    /**
     * Upload a document file to S3.
     * Requires admin authentication.
     * Expects multipart/form-data with field name "document".
     */
    static async uploadDocument(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const file = req.file;

            if (!file) {
                return sendError(res, 400, 'No document file provided. Use field name "document".');
            }

            // Validate MIME type
            if (!ALLOWED_DOC_TYPES.includes(file.mimetype)) {
                return sendError(
                    res,
                    400,
                    `Invalid file type: ${file.mimetype}. Allowed: pdf`
                );
            }

            // Validate file size
            const maxSizeMB = parseInt(process.env.DOC_MAX_SIZE_MB || '50', 10);
            const maxSizeBytes = maxSizeMB * 1024 * 1024;
            if (file.size > maxSizeBytes) {
                return sendError(
                    res,
                    400,
                    `File too large. Maximum size: ${maxSizeMB}MB`
                );
            }

            // Generate structured S3 key — stored in /docs/ as requested
            const ext = path.extname(file.originalname) || '.pdf';
            const uuid = randomUUID();
            const s3Key = `docs/${uuid}${ext}`;

            // Upload to S3
            await s3Service.uploadFile(file.buffer, s3Key, file.mimetype);

            // Generate initial presigned URL for preview
            const presignedUrl = await s3Service.getPresignedUrl(s3Key);

            logger.info({
                s3Key,
                originalName: file.originalname,
                size: file.size,
                mimeType: file.mimetype,
                uploadedBy: req.user?.userId,
            }, 'Document uploaded successfully');

            // Generate standardized media object
            const media = buildMediaObject(s3Key, presignedUrl, file.originalname, file.mimetype);

            return sendResponse(res, 201, true, 'Document uploaded successfully', media);
        } catch (error) {
            logger.error({ err: error }, 'Document upload failed');
            next(error);
        }
    }

    /**
     * Delete a document from S3.
     */
    static async deleteDocument(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const contentId = req.params.contentId as string;

            const content = await ContentService.getContentById(contentId);
            if (!content) {
                return sendError(res, 404, 'Content not found');
            }

            if (content.contentType !== ContentType.PDF) {
                return sendError(res, 400, 'Content is not a document');
            }

            const s3Key = content.data?.s3Key;
            if (s3Key) {
                await s3Service.deleteFile(s3Key);
                // No specific cache for doc URLs yet, but following video pattern
            }

            return sendResponse(res, 200, true, 'Document deleted from storage');
        } catch (error) {
            logger.error({ err: error }, 'Failed to delete document');
            next(error);
        }
    }
}
