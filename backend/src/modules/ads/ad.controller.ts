import type { Request, Response, NextFunction } from 'express';
import { AdService } from './ad.service.js';
import { sendResponse, sendError } from '../../utils/response.util.js';
import { AdPlacement } from '../../constants/enums.js';
import { s3Service } from '../../utils/s3.service.js';
import path from 'path';
import { randomUUID } from 'crypto';
import type { AuthRequest } from '../../middleware/auth.middleware.js';
import logger from '../../utils/logger.js';
import { buildMediaObject } from '../../utils/media.util.js';

export class AdController {
    static async uploadImage(req: AuthRequest, res: Response, next: NextFunction) {
        try {
            const file = req.file;
            const { adName } = req.body; // Optional ad name to use in key

            if (!file) {
                return sendError(res, 400, 'No image file provided. Use field name "image".');
            }

            // Validate MIME type
            const ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
            if (!ALLOWED_IMAGE_TYPES.includes(file.mimetype)) {
                return sendError(res, 400, 'Invalid file type. Allowed: jpg, png, webp, gif');
            }

            // Generate structured S3 key — stored in /images/
            const ext = path.extname(file.originalname) || '.jpg';
            const identifier = adName ? adName.toLowerCase().replace(/[^a-z0-9]/g, '-') : randomUUID();
            const s3Key = `images/${identifier}-${Date.now()}${ext}`;

            // Upload to S3
            await s3Service.uploadFile(file.buffer, s3Key, file.mimetype);

            // Generate presigned URL (Ads need to be visible for a while, but S3 V4 limits to 7 days)
            const presignedUrl = await s3Service.getPresignedUrl(s3Key, 604800); // 7 days (max allowed)

            // Generate standardized media object
            const media = buildMediaObject(s3Key, presignedUrl, file.originalname, file.mimetype);

            return sendResponse(res, 201, true, 'Ad image uploaded successfully', media);
        } catch (error) {
            logger.error({ err: error }, 'Ad image upload failed');
            next(error);
        }
    }

    static async createAd(req: Request, res: Response, next: NextFunction) {

        try {
            const ad = await AdService.createAd(req.body);
            return sendResponse(res, 201, true, 'Ad created successfully', ad);
        } catch (error) {
            next(error);
        }
    }

    static async getActiveAds(req: Request, res: Response, next: NextFunction) {
        try {
            const { placement } = req.params;
            const ads = await AdService.getActiveAdsByPlacement(placement as AdPlacement);
            return sendResponse(res, 200, true, 'Active ads fetched successfully', ads);
        } catch (error) {
            next(error);
        }
    }

    static async getAllAds(req: Request, res: Response, next: NextFunction) {
        try {
            const ads = await AdService.getAllAds();
            return sendResponse(res, 200, true, 'All ads fetched successfully', ads);
        } catch (error) {
            next(error);
        }
    }

    static async updateAd(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const ad = await AdService.updateAd(id as string, req.body);
            if (!ad) return sendError(res, 404, 'Ad not found');
            return sendResponse(res, 200, true, 'Ad updated successfully', ad);
        } catch (error) {
            next(error);
        }
    }

    static async deleteAd(req: Request, res: Response, next: NextFunction) {
        try {
            const { id } = req.params;
            const result = await AdService.deleteAd(id as string);
            if (!result) return sendError(res, 404, 'Ad not found');
            return sendResponse(res, 200, true, 'Ad deleted successfully');
        } catch (error) {
            next(error);
        }
    }
}
