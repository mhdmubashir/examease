import type { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { UserRole } from '../constants/enums.js';
import { sendError } from '../utils/response.util.js';

export interface AuthRequest extends Request {
    user?: {
        userId: string;
        role: UserRole;
    };
}

export const authenticate = (req: AuthRequest, res: Response, next: NextFunction) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return sendError(res, 401, 'Unauthorized');
    }

    const token = authHeader.split(' ')[1];
    try {
        const decoded = jwt.verify(token!, process.env.JWT_SECRET as string) as any;
        req.user = decoded;
        next();
    } catch (error) {
        return sendError(res, 401, 'Invalid or expired token');
    }
};

export const authorize = (...roles: UserRole[]) => {
    return (req: AuthRequest, res: Response, next: NextFunction) => {
        if (!req.user || !roles.includes(req.user.role)) {
            return sendError(res, 403, 'Forbidden');
        }
        next();
    };
};
