import type { Request, Response, NextFunction } from 'express';
import logger from '../utils/logger.js';
import { sendError } from '../utils/response.util.js';

export const errorHandler = (
    err: any,
    req: Request,
    res: Response,
    next: NextFunction
) => {
    logger.error(err);

    const statusCode = err.statusCode || 500;
    const message = err.message || 'Internal Server Error';

    return sendError(res, statusCode, message, err.errors);
};
