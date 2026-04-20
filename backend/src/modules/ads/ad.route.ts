import { Router } from 'express';
import { AdController } from './ad.controller.js';
import { validateRequest } from '../../middleware/validate.middleware.js';
import { createAdSchema, updateAdSchema } from './ad.validation.js';
import { authenticate, authorize } from '../../middleware/auth.middleware.js';
import { UserRole } from '../../constants/enums.js';
import multer from 'multer';

const router = Router();
const upload = multer({ storage: multer.memoryStorage() });

// Public routes
router.get('/active/:placement', AdController.getActiveAds);

// Admin routes (Protected)
router.use(authenticate, authorize(UserRole.ADMIN));

router.post('/upload', upload.single('image'), AdController.uploadImage);
router.post('/', validateRequest(createAdSchema), AdController.createAd);
router.get('/all', AdController.getAllAds);
router.patch('/:id', validateRequest(updateAdSchema), AdController.updateAd);
router.delete('/:id', AdController.deleteAd);

export const adRoutes = router;
