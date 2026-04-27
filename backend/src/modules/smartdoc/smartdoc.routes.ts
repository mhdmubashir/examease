import { Router } from 'express';
import { SmartDocController } from './smartdoc.controller.js';
import { authenticate, authorize } from '../../middleware/auth.middleware.js';
import { UserRole } from '../../constants/enums.js';
import multer from 'multer';

const router = Router();
const upload = multer({ storage: multer.memoryStorage() });

// Admin route
router.use(authenticate, authorize(UserRole.ADMIN));

router.post('/generate', upload.array('files'), SmartDocController.generatePdf);

export const smartdocRoutes = router;
