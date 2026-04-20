import type { Request, Response, NextFunction } from 'express';
import { AppConfigService } from './app-config.service.js';
import { sendResponse } from '../../utils/response.util.js';

export class AppConfigController {
    static async getConfig(req: Request, res: Response, next: NextFunction) {
        try {
            const config = await AppConfigService.getConfig();
            return sendResponse(res, 200, true, 'App configuration fetched successfully', config);
        } catch (error) {
            next(error);
        }
    }

    static async updateConfig(req: Request, res: Response, next: NextFunction) {
        try {
            const config = await AppConfigService.updateConfig(req.body);
            return sendResponse(res, 200, true, 'App configuration updated successfully', config);
        } catch (error) {
            next(error);
        }
    }
}
