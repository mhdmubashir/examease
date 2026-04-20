import { type Request, type Response, type NextFunction } from 'express';
import { AnalyticsService } from './analytics.service.js';
import { sendResponse } from '../../utils/response.util.js';

export class AnalyticsController {
    static async getDashboardStats(req: Request, res: Response, next: NextFunction) {
        try {
            const stats = await AnalyticsService.getDashboardStats();
            return sendResponse(res, 200, true, 'Dashboard stats fetched successfully', stats);
        } catch (error) {
            next(error);
        }
    }

    static async getRevenueStats(req: Request, res: Response, next: NextFunction) {
        try {
            const stats = await AnalyticsService.getRevenueStats();
            return sendResponse(res, 200, true, 'Revenue stats fetched successfully', stats);
        } catch (error) {
            next(error);
        }
    }
}
