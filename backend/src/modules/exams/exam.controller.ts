import type { Request, Response, NextFunction } from 'express';
import { ExamService } from './exam.service.js';
import { sendResponse, sendError } from '../../utils/response.util.js';

export class ExamController {
    static async createExam(req: Request, res: Response, next: NextFunction) {
        try {
            const exam = await ExamService.createExam(req.body);
            return sendResponse(res, 201, true, 'Exam created successfully', exam);
        } catch (error) {
            next(error);
        }
    }

    static async getActiveExams(req: Request, res: Response, next: NextFunction) {
        try {
            const { page, limit, perPage, search } = req.query;
            const effectiveLimit = perPage || limit;
            const { data, ...pagination } = await ExamService.getAllExams({ isActive: true, page, limit: effectiveLimit, search });
            return sendResponse(res, 200, true, 'Active exams fetched successfully', data, pagination);
        } catch (error) {
            next(error);
        }
    }

    static async getAllExams(req: Request, res: Response, next: NextFunction) {
        try {
            const { page, limit, perPage, search, isActive } = req.query;
            const effectiveLimit = perPage || limit;
            const { data, ...pagination } = await ExamService.getAllExams({ page, limit: effectiveLimit, search, isActive });
            return sendResponse(res, 200, true, 'All exams fetched successfully', data, pagination);
        } catch (error) {
            next(error);
        }
    }

    static async updateExam(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const exam = await ExamService.updateExam(id as string, req.body);
            if (!exam) return sendError(res, 404, 'Exam not found');
            return sendResponse(res, 200, true, 'Exam updated successfully', exam);
        } catch (error) {
            next(error);
        }
    }
}
