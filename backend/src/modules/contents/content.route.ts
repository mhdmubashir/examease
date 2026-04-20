import { Router } from 'express';
import { ContentController } from './content.controller.js';
import { validateRequest } from '../../middleware/validate.middleware.js';
import { createContentMiddlewareSchema, updateContentSchema } from './content.validation.js';
import { authenticate, authorize } from '../../middleware/auth.middleware.js';
import { UserRole } from '../../constants/enums.js';

const router = Router();

// Public routes
router.get('/module/:moduleId', ContentController.getContentsByModule);
router.get('/all', ContentController.getAllContents);

// Admin routes (Protected)
router.use(authenticate, authorize(UserRole.ADMIN));
router.post('/', validateRequest(createContentMiddlewareSchema), ContentController.createContent);
router.patch('/:id', validateRequest(updateContentSchema), ContentController.updateContent);
router.delete('/:id', ContentController.deleteContent);

// This must come LAST to avoid shadowing /all
router.get('/:id', ContentController.getContentById);

export const contentRoutes = router;
