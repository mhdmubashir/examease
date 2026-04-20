import { Router } from 'express';
import { AppConfigController } from './app-config.controller.js';
import { validateRequest } from '../../middleware/validate.middleware.js';
import { updateAppConfigSchema } from './app-config.validation.js';
import { authenticate, authorize } from '../../middleware/auth.middleware.js';
import { UserRole } from '../../constants/enums.js';

const router = Router();

// Public routes
router.get('/', AppConfigController.getConfig);

// Admin routes (Protected)
router.use(authenticate, authorize(UserRole.ADMIN));

router.patch('/', validateRequest(updateAppConfigSchema), AppConfigController.updateConfig);

export const appConfigRoutes = router;
