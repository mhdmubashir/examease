import { Router } from 'express';
import { QuestionController } from './question.controller.js';
import { validateRequest } from '../../middleware/validate.middleware.js';
import { createQuestionSchema, bulkQuestionSchema, updateQuestionSchema } from './question.validation.js';
import { authenticate, authorize } from '../../middleware/auth.middleware.js';
import { UserRole } from '../../constants/enums.js';

const router = Router();

// Admin routes (Protected)
// Public/Student routes (Authenticated)
router.get('/test/:mockTestId', authenticate, QuestionController.getQuestionsByTest);

// Admin routes (Protected)
router.post('/', authenticate, authorize(UserRole.ADMIN), validateRequest(createQuestionSchema), QuestionController.createQuestion);
router.post('/bulk', authenticate, authorize(UserRole.ADMIN), validateRequest(bulkQuestionSchema), QuestionController.bulkCreateQuestions);
router.patch('/:id', authenticate, authorize(UserRole.ADMIN), validateRequest(updateQuestionSchema), QuestionController.updateQuestion);
router.delete('/:id', authenticate, authorize(UserRole.ADMIN), QuestionController.deleteQuestion);

export const questionRoutes = router;
