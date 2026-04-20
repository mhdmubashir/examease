import type { Request, Response, NextFunction } from 'express';
import { ModuleService } from './module.service.js';
import { sendResponse, sendError } from '../../utils/response.util.js';

export class ModuleController {
    static async createModule(req: Request, res: Response, next: NextFunction) {
        try {
            const module = await ModuleService.createModule(req.body);
            return sendResponse(res, 201, true, 'Module created successfully', module);
        } catch (error) {
            next(error);
        }
    }

    static async getModulesByExam(req: Request, res: Response, next: NextFunction) {
        try {
            const { examId } = req.params;
            const modules = await ModuleService.getModulesByExam(examId as string, { isActive: true });
            return sendResponse(res, 200, true, 'Modules fetched successfully', modules);
        } catch (error) {
            next(error);
        }
    }

    static async getModuleById(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const module = await ModuleService.getModuleById(id as string);
            if (!module) return sendError(res, 404, 'Module not found');
            return sendResponse(res, 200, true, 'Module fetched successfully', module);
        } catch (error) {
            next(error);
        }
    }

    static async getAllModules(req: Request, res: Response, next: NextFunction) {
        try {
            const { page, limit, perPage, search, examId, accessType, isActive } = req.query;
            const effectiveLimit = perPage || limit;
            const { data, ...pagination } = await ModuleService.getAllModules({
                page,
                limit: effectiveLimit,
                search,
                examId,
                accessType,
                isActive
            });
            return sendResponse(res, 200, true, 'All modules fetched successfully', data, pagination);
        } catch (error) {
            next(error);
        }
    }

    static async updateModule(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const module = await ModuleService.updateModule(id as string, req.body);
            if (!module) return sendError(res, 404, 'Module not found');
            return sendResponse(res, 200, true, 'Module updated successfully', module);
        } catch (error) {
            next(error);
        }
    }
}
