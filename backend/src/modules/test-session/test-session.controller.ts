import type { Response, NextFunction } from 'express';
import { TestSessionService } from './test-session.service.js';
import { sendResponse, sendError } from '../../utils/response.util.js';
import type { AuthRequest } from '../../middleware/auth.middleware.js';

export class TestSessionController {
    static async startSession(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const { mockTestId } = req.body;
            const userId = req.user!.userId;
            const session = await TestSessionService.startSession(userId, mockTestId);
            return sendResponse(res, 201, true, 'Session started successfully', session);
        } catch (error: any) {
            if (error.code === 11000) {
                return sendError(res, 400, 'You already have an active session for this test');
            }
            next(error);
        }
    }

    static async submitSession(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const userId = req.user!.userId;
            const { answers } = req.body;
            const session = await TestSessionService.submitSession(id as string, userId, answers);
            return sendResponse(res, 200, true, 'Test submitted successfully', session);
        } catch (error) {
            next(error);
        }
    }

    static async getSession(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const userId = req.user!.userId;
            const session = await TestSessionService.getSession(id as string, userId);
            if (!session) return sendError(res, 404, 'Session not found');
            return sendResponse(res, 200, true, 'Session fetched successfully', session);
        } catch (error) {
            next(error);
        }
    }

    static async getUserSessions(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const userId = req.user!.userId;
            const sessions = await TestSessionService.getUserSessions(userId);
            return sendResponse(res, 200, true, 'User sessions fetched successfully', sessions);
        } catch (error) {
            next(error);
        }
    }
}
