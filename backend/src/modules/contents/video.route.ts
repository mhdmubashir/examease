import { Router } from 'express';
import multer from 'multer';
import { VideoController } from './video.controller.js';
import { authenticate, authorize } from '../../middleware/auth.middleware.js';
import { UserRole } from '../../constants/enums.js';

/**
 * Video Routes
 *
 * POST   /api/v1/videos/upload           — Admin uploads a video to S3
 * GET    /api/v1/videos/stream/:contentId — Authenticated user gets presigned stream URL
 * DELETE /api/v1/videos/:contentId        — Admin deletes a video from S3
 */

const router = Router();

// Multer config — store in memory buffer (uploaded directly to S3)
const maxSizeMB = parseInt(process.env.VIDEO_MAX_SIZE_MB || '500', 10);
const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: maxSizeMB * 1024 * 1024,
    },
});

// All routes require authentication
router.use(authenticate);

// User route — get presigned stream URL
router.get('/stream/:contentId', VideoController.getStreamUrl);

// Admin-only routes
router.post(
    '/upload',
    authorize(UserRole.ADMIN),
    upload.single('video'),
    VideoController.uploadVideo
);

router.delete(
    '/:contentId',
    authorize(UserRole.ADMIN),
    VideoController.deleteVideo
);

export const videoRoutes = router;
