import { Router } from 'express';
import { ExamController } from './exam.controller.js';
import { validateRequest } from '../../middleware/validate.middleware.js';
import { createExamSchema, updateExamSchema } from './exam.validation.js';
import { authenticate, authorize } from '../../middleware/auth.middleware.js';
import { UserRole } from '../../constants/enums.js';

const router = Router();

// Public routes
router.get('/', ExamController.getActiveExams);
router.get('/active', ExamController.getActiveExams);

// Admin routes (Protected)
router.use(authenticate, authorize(UserRole.ADMIN));

router.post('/', validateRequest(createExamSchema), ExamController.createExam);
router.get('/all', ExamController.getAllExams);
router.patch('/:id', validateRequest(updateExamSchema), ExamController.updateExam);

export const examRoutes = router;
