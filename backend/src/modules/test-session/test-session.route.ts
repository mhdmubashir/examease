import { Router } from 'express';
import { TestSessionController } from './test-session.controller.js';
import { validateRequest } from '../../middleware/validate.middleware.js';
import { startSessionSchema, submitSessionSchema } from './test-session.validation.js';
import { authenticate } from '../../middleware/auth.middleware.js';

const router = Router();

router.use(authenticate);

router.post('/start', validateRequest(startSessionSchema), TestSessionController.startSession);
router.post('/:id/submit', validateRequest(submitSessionSchema), TestSessionController.submitSession);
router.get('/my-sessions', TestSessionController.getUserSessions);
router.get('/:id', TestSessionController.getSession);

export const testSessionRoutes = router;
