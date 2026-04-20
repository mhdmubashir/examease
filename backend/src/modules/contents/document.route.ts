import { Router } from 'express';
import multer from 'multer';
import { DocumentController } from './document.controller.js';
import { authenticate, authorize } from '../../middleware/auth.middleware.js';
import { UserRole } from '../../constants/enums.js';

/**
 * Document Routes
 *
 * POST   /api/v1/documents/upload           — Admin uploads a PDF to S3
 * DELETE /api/v1/documents/:contentId        — Admin deletes a PDF from S3
 */

const router = Router();

// Multer config — store in memory buffer
const maxSizeMB = parseInt(process.env.DOC_MAX_SIZE_MB || '50', 10);
const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: maxSizeMB * 1024 * 1024,
    },
});

// All routes require authentication
router.use(authenticate);

// Admin-only routes
router.post(
    '/upload',
    authorize(UserRole.ADMIN),
    upload.single('document'),
    DocumentController.uploadDocument
);

router.delete(
    '/:contentId',
    authorize(UserRole.ADMIN),
    DocumentController.deleteDocument
);

export const documentRoutes = router;
