import { Router } from 'express';
import { AnalyticsController } from './analytics.controller.js';
import { authenticate, authorize } from '../../middleware/auth.middleware.js';
import { UserRole } from '../../constants/enums.js';

const router = Router();

// Only Admins can access analytics
router.get('/dashboard', authenticate, authorize(UserRole.ADMIN), AnalyticsController.getDashboardStats);
router.get('/revenue', authenticate, authorize(UserRole.ADMIN), AnalyticsController.getRevenueStats);

export { router as analyticsRoutes };
