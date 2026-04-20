import { Router } from 'express';
import { UserController } from './user.controller.js';
import { authenticate, authorize } from '../../middleware/auth.middleware.js';
import { UserRole } from '../../constants/enums.js';

const router = Router();

router.get('/profile', authenticate, UserController.getProfile);

// All user management routes are admin only
router.use(authenticate, authorize(UserRole.ADMIN));

router.get('/all', UserController.getAllUsers);
router.get('/:id', UserController.getUserById);
router.patch('/:id/toggle-block', UserController.toggleBlockStatus);
router.patch('/:id/role', UserController.updateRole);

export { router as userRoutes };
