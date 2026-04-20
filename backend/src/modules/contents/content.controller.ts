import type { Request, Response, NextFunction } from 'express';
import { ContentService } from './content.service.js';
import { sendResponse, sendError } from '../../utils/response.util.js';

export class ContentController {
    static async createContent(req: Request, res: Response, next: NextFunction) {
        try {
            const content = await ContentService.createContent(req.body);
            return sendResponse(res, 201, true, 'Content created successfully', content);
        } catch (error) {
            next(error);
        }
    }

    static async getContentsByModule(req: Request, res: Response, next: NextFunction) {
        try {
            const { moduleId } = req.params;
            const contents = await ContentService.getContentsByModule(moduleId as string, { isActive: true });
            return sendResponse(res, 200, true, 'Contents fetched successfully', contents);
        } catch (error) {
            next(error);
        }
    }

    static async getContentById(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const content = await ContentService.getContentById(id as string);
            if (!content) return sendError(res, 404, 'Content not found');
            return sendResponse(res, 200, true, 'Content fetched successfully', content);
        } catch (error) {
            next(error);
        }
    }

    static async getAllContents(req: Request, res: Response, next: NextFunction) {
        try {
            const { page, limit, perPage, search, moduleId, contentType } = req.query;
            const effectiveLimit = perPage || limit;
            const { data, ...pagination } = await ContentService.getAllContents({
                page,
                limit: effectiveLimit,
                search,
                moduleId,
                contentType
            });
            return sendResponse(res, 200, true, 'All contents fetched successfully', data, pagination);
        } catch (error) {
            next(error);
        }
    }

    static async updateContent(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const content = await ContentService.updateContent(id as string, req.body);
            if (!content) return sendError(res, 404, 'Content not found');
            return sendResponse(res, 200, true, 'Content updated successfully', content);
        } catch (error) {
            next(error);
        }
    }

    static async deleteContent(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const result = await ContentService.deleteContent(id as string);
            if (!result) return sendError(res, 404, 'Content not found');
            return sendResponse(res, 200, true, 'Content deleted successfully');
        } catch (error) {
            next(error);
        }
    }
}
