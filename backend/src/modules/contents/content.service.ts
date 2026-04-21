import { Content, type IContent } from './content.model.js';
import { redisService, CacheKeys } from '../../utils/redis.service.js';
import logger from '../../utils/logger.js';

/**
 * Content Service — Business logic for content CRUD with Redis caching.
 *
 * Caching strategy:
 * - getContentById: cached for 5 minutes
 * - getContentsByModule: cached for 2 minutes
 * - create/update/delete: invalidate relevant cache keys
 * - Cache miss → DB query → populate cache
 */

export class ContentService {
    static async createContent(data: Partial<IContent>) {
        const content = await Content.create(data);
        // Invalidate module's content list cache
        await redisService.delPattern(CacheKeys.allContentsPattern());
        return content;
    }

    static async getContentsByModule(moduleId: string, filter: any = {}) {
        return await Content.find({ moduleId, ...filter }).sort({ orderIndex: 1, createdAt: 1 });
    }

    static async getContentById(id: string) {
        // Check cache first
        const cacheKey = CacheKeys.content(id);
        const cached = await redisService.get<IContent>(cacheKey);
        if (cached) {
            logger.info({ contentId: id }, 'Content cache HIT');
            return cached;
        }

        // Cache miss — query DB
        const content = await Content.findById(id);
        if (content) {
            await redisService.set(cacheKey, content.toJSON(), 300); // 5 min TTL
        }
        return content;
    }

    static async updateContent(id: string, data: Partial<IContent>) {
        const content = await Content.findByIdAndUpdate(id, data, { new: true });
        // Invalidate cache
        await redisService.del(CacheKeys.content(id));
        await redisService.del(CacheKeys.videoUrl(id));
        await redisService.delPattern(CacheKeys.allContentsPattern());
        return content;
    }

    static async deleteContent(id: string) {
        const result = await Content.findByIdAndDelete(id);
        // Invalidate cache
        await redisService.del(CacheKeys.content(id));
        await redisService.del(CacheKeys.videoUrl(id));
        await redisService.delPattern(CacheKeys.allContentsPattern());
        return result;
    }

    static async getAllContents(query: any = {}) {
        const { page = 1, limit = 10, search, moduleId, contentType } = query;
        const filter: any = {};

        if (search) {
            filter.$or = [
                { title: { $regex: search, $options: 'i' } },
                { description: { $regex: search, $options: 'i' } }
            ];
        }

        if (moduleId && moduleId !== 'all' && moduleId !== 'undefined') {
            filter.moduleId = moduleId;
        }

        if (contentType && contentType !== 'all') {
            filter.contentType = contentType;
        }

        // Try cache for non-search queries (search queries are too dynamic)
        if (!search) {
            const cacheKey = CacheKeys.contentsByModule(
                moduleId || 'all',
                Number(page),
                contentType
            );
            const cached = await redisService.get<any>(cacheKey);
            if (cached) {
                logger.info({ moduleId, page }, 'Contents list cache HIT');
                return cached;
            }
        }

        const skip = (Number(page) - 1) * Number(limit);
        const [data, total] = await Promise.all([
            Content.find(filter)
                .sort({ orderIndex: 1, createdAt: 1 })
                .skip(skip)
                .limit(Number(limit)),
            Content.countDocuments(filter)
        ]);

        const result = {
            data,
            total,
            page: Number(page),
            limit: Number(limit),
            totalPages: Math.ceil(total / Number(limit))
        };

        // Cache if not a search query (2 min TTL)
        if (!search) {
            const cacheKey = CacheKeys.contentsByModule(
                moduleId || 'all',
                Number(page),
                contentType
            );
            await redisService.set(cacheKey, result, 120);
        }

        return result;
    }
}
