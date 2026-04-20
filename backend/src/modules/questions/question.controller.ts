import type { Request, Response, NextFunction } from 'express';
import { QuestionService } from './question.service.js';
import { sendResponse, sendError } from '../../utils/response.util.js';

export class QuestionController {
    static async createQuestion(req: Request, res: Response, next: NextFunction) {
        try {
            const question = await QuestionService.createQuestion(req.body);
            return sendResponse(res, 201, true, 'Question created successfully', question);
        } catch (error) {
            next(error);
        }
    }

    static async bulkCreateQuestions(req: Request, res: Response, next: NextFunction) {
        try {
            const questions = await QuestionService.bulkCreateQuestions(req.body);
            return sendResponse(res, 201, true, `Successfully uploaded ${questions.length} questions`, questions);
        } catch (error) {
            next(error);
        }
    }

    static async getQuestionsByTest(req: Request, res: Response, next: NextFunction) {
        try {
            const { mockTestId } = req.params;
            const questions = await QuestionService.getQuestionsByTest(mockTestId as string);
            return sendResponse(res, 200, true, 'Questions fetched successfully', questions);
        } catch (error) {
            next(error);
        }
    }

    static async updateQuestion(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const question = await QuestionService.updateQuestion(id as string, req.body);
            if (!question) return sendError(res, 404, 'Question not found');
            return sendResponse(res, 200, true, 'Question updated successfully', question);
        } catch (error) {
            next(error);
        }
    }

    static async deleteQuestion(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const result = await QuestionService.deleteQuestion(id as string);
            if (!result) return sendError(res, 404, 'Question not found');
            return sendResponse(res, 200, true, 'Question deleted successfully');
        } catch (error) {
            next(error);
        }
    }
}
