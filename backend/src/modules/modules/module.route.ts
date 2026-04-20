import { Router } from 'express';
import { ModuleController } from './module.controller.js';
import { validateRequest } from '../../middleware/validate.middleware.js';
import { createModuleSchema, updateModuleSchema } from './module.validation.js';
import { authenticate, authorize } from '../../middleware/auth.middleware.js';
import { UserRole } from '../../constants/enums.js';

const router = Router();

// Public routes
router.get('/exam/:examId', ModuleController.getModulesByExam);
router.get('/all', ModuleController.getAllModules);
router.get('/:id', ModuleController.getModuleById);

// Admin routes (Protected)
router.post('/', authenticate, authorize(UserRole.ADMIN), validateRequest(createModuleSchema), ModuleController.createModule);
router.patch('/:id', authenticate, authorize(UserRole.ADMIN), validateRequest(updateModuleSchema), ModuleController.updateModule);

export const moduleRoutes = router;
