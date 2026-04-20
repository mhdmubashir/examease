import type { Request, Response, NextFunction } from 'express';
import { User } from './user.model.js';
import { sendResponse, sendError } from '../../utils/response.util.js';

export class UserController {
    static async getProfile(req: Request & { user?: any }, res: Response, next: NextFunction) {
        try {
            const user = await User.findById(req.user.userId);
            if (!user) return sendError(res, 404, 'User not found');
            return sendResponse(res, 200, true, 'Profile fetched successfully', user);
        } catch (error) {
            next(error);
        }
    }

    static async getAllUsers(req: Request, res: Response, next: NextFunction) {
        try {
            const users = await User.find().sort({ createdAt: -1 });
            return sendResponse(res, 200, true, 'Users fetched successfully', users);
        } catch (error) {
            next(error);
        }
    }

    static async getUserById(req: Request, res: Response, next: NextFunction) {
        try {
            const user = await User.findById(req.params.id);
            if (!user) return sendError(res, 404, 'User not found');
            return sendResponse(res, 200, true, 'User fetched successfully', user);
        } catch (error) {
            next(error);
        }
    }

    static async toggleBlockStatus(req: Request, res: Response, next: NextFunction) {
        try {
            const user = await User.findById(req.params.id);
            if (!user) return sendError(res, 404, 'User not found');

            user.isBlocked = !user.isBlocked;
            await user.save();

            return sendResponse(res, 200, true, `User ${user.isBlocked ? 'blocked' : 'unblocked'} successfully`, user);
        } catch (error) {
            next(error);
        }
    }

    static async updateRole(req: Request, res: Response, next: NextFunction) {
        try {
            const { role } = req.body;
            const user = await User.findByIdAndUpdate(req.params.id, { role }, { new: true });
            if (!user) return sendError(res, 404, 'User not found');
            return sendResponse(res, 200, true, 'User role updated successfully', user);
        } catch (error) {
            next(error);
        }
    }
}
