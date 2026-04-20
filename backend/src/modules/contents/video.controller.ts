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
 * Video Controller — Handles video upload to S3 and presigned URL generation.
 *
 * Upload flow:
 * 1. Admin uploads video via multipart/form-data
 * 2. File is validated (type, size) by multer middleware
 * 3. File buffer is uploaded to S3 with structured key
 * 4. S3 key + initial presigned URL returned to admin
 *
 * Stream flow:
 * 1. Authenticated user requests video URL for a content item
 * 2. Content is fetched from DB, verified as VIDEO type
 * 3. Presigned URL is generated (cached in Redis for 50 min)
 * 4. URL returned to client for playback
 */

// Allowed video MIME types
const ALLOWED_VIDEO_TYPES = [
    'video/mp4',
    'video/quicktime',    // .mov
    'video/webm',
    'video/x-matroska',   // .mkv
    'video/x-msvideo',    // .avi
];

export class VideoController {
    /**
     * Upload a video file to S3.
     * Requires admin authentication.
     * Expects multipart/form-data with field name "video".
     */
    static async uploadVideo(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const file = req.file;

            if (!file) {
                return sendError(res, 400, 'No video file provided. Use field name "video".');
            }

            // Validate MIME type
            if (!ALLOWED_VIDEO_TYPES.includes(file.mimetype)) {
                return sendError(
                    res,
                    400,
                    `Invalid file type: ${file.mimetype}. Allowed: mp4, mov, webm, mkv, avi`
                );
            }

            // Validate file size
            const maxSizeMB = parseInt(process.env.VIDEO_MAX_SIZE_MB || '500', 10);
            const maxSizeBytes = maxSizeMB * 1024 * 1024;
            if (file.size > maxSizeBytes) {
                return sendError(
                    res,
                    400,
                    `File too large. Maximum size: ${maxSizeMB}MB`
                );
            }

            // Generate structured S3 key
            const ext = path.extname(file.originalname) || '.mp4';
            const uuid = randomUUID();
            const s3Key = `videos/${uuid}${ext}`;

            // Upload to S3
            await s3Service.uploadVideo(file.buffer, s3Key, file.mimetype);

            // Generate initial presigned URL for preview
            const presignedUrl = await s3Service.getPresignedUrl(s3Key);

            logger.info({
                s3Key,
                originalName: file.originalname,
                size: file.size,
                mimeType: file.mimetype,
                uploadedBy: req.user?.userId,
            }, 'Video uploaded successfully');

            // Generate standardized media object
            const media = buildMediaObject(s3Key, presignedUrl, file.originalname, file.mimetype);

            return sendResponse(res, 201, true, 'Video uploaded successfully', media);
        } catch (error) {
            logger.error({ err: error }, 'Video upload failed');
            next(error);
        }
    }

    /**
     * Get a presigned streaming URL for a video content item.
     * Requires user authentication (any role).
     * Uses Redis caching to avoid generating new URLs unnecessarily.
     */
    static async getStreamUrl(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const contentId = req.params.contentId as string;

            if (!contentId) {
                return sendError(res, 400, 'Content ID is required');
            }

            // Check Redis cache first (cached for 50 min, URL valid for 60 min)
            const cacheKey = CacheKeys.videoUrl(contentId);
            const cachedUrl = await redisService.get<string>(cacheKey);
            if (cachedUrl) {
                return sendResponse(res, 200, true, 'Video URL retrieved (cached)', {
                    streamUrl: cachedUrl,
                    cached: true,
                });
            }

            // Fetch content from DB
            const content = await ContentService.getContentById(contentId);
            if (!content) {
                return sendError(res, 404, 'Content not found');
            }

            if (content.contentType !== ContentType.VIDEO) {
                return sendError(res, 400, 'Content is not a video');
            }

            const s3Key = content.data?.s3Key;
            if (!s3Key) {
                return sendError(res, 404, 'Video file not found for this content');
            }

            // Verify the file exists in S3
            const exists = await s3Service.objectExists(s3Key);
            if (!exists) {
                return sendError(res, 404, 'Video file not found in storage');
            }

            // Generate presigned URL (valid for 60 min)
            const presignedUrl = await s3Service.getPresignedUrl(s3Key, 3600);

            // Cache for 50 minutes (10 min buffer before URL expires)
            await redisService.set(cacheKey, presignedUrl, 3000);

            return sendResponse(res, 200, true, 'Video URL generated', {
                streamUrl: presignedUrl,
                cached: false,
            });
        } catch (error) {
            logger.error({ err: error }, 'Failed to get video stream URL');
            next(error);
        }
    }

    /**
     * Delete a video from S3.
     * Called when admin deletes a video content item.
     */
    static async deleteVideo(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const contentId = req.params.contentId as string;

            const content = await ContentService.getContentById(contentId);
            if (!content) {
                return sendError(res, 404, 'Content not found');
            }

            if (content.contentType !== ContentType.VIDEO) {
                return sendError(res, 400, 'Content is not a video');
            }

            const s3Key = content.data?.s3Key;
            if (s3Key) {
                await s3Service.deleteVideo(s3Key);
                // Invalidate cache
                await redisService.del(CacheKeys.videoUrl(contentId));
            }

            return sendResponse(res, 200, true, 'Video deleted from storage');
        } catch (error) {
            logger.error({ err: error }, 'Failed to delete video');
            next(error);
        }
    }
}
