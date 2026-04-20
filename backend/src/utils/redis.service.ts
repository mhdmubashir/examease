import RedisImport from 'ioredis';
import logger from './logger.js';

const Redis = (RedisImport as any).default || RedisImport;
type RedisType = any; // fallback type

/**
 * Redis Service — Centralized caching layer.
 *
 * Design decisions:
 * - Graceful degradation: if Redis is down, operations silently fail
 *   and the app continues without cache (no crash)
 * - Key namespace: "examease:{entity}:{id}" for easy management
 * - TTL-based expiry for automatic cache invalidation
 * - JSON serialization/deserialization built-in
 */

class RedisService {
    private client: RedisType | null = null;
    private isConnected: boolean = false;

    /**
     * Initialize Redis connection.
     * Call this once at server startup.
     */
    async connect(): Promise<void> {
        const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';

        try {
            this.client = new Redis(redisUrl, {
                maxRetriesPerRequest: 3,
                retryStrategy(times: number) {
                    if (times > 3) {
                        logger.warn('Redis: Max retries reached, giving up reconnection');
                        return null; // Stop retrying
                    }
                    return Math.min(times * 200, 2000);
                },
                lazyConnect: true,
            });

            this.client.on('connect', () => {
                this.isConnected = true;
                logger.info('Redis connected successfully');
            });

            this.client.on('error', (err: any) => {
                this.isConnected = false;
                logger.warn({ err: err.message }, 'Redis connection error (operating without cache)');
            });

            this.client.on('close', () => {
                this.isConnected = false;
                logger.warn('Redis connection closed');
            });

            await this.client.connect();
        } catch (error) {
            this.isConnected = false;
            logger.warn('Redis unavailable — running without cache');
        }
    }

    /**
     * Get a cached value by key.
     * @returns Parsed JSON value or null if not found/not connected
     */
    async get<T>(key: string): Promise<T | null> {
        if (!this.isConnected || !this.client) return null;

        try {
            const data = await this.client.get(key);
            if (!data) return null;
            return JSON.parse(data) as T;
        } catch (error) {
            logger.warn({ key }, 'Redis GET failed');
            return null;
        }
    }

    /**
     * Set a cached value with TTL.
     * @param key - Cache key
     * @param value - Value to cache (will be JSON-stringified)
     * @param ttlSeconds - Time-to-live in seconds
     */
    async set(key: string, value: unknown, ttlSeconds: number): Promise<void> {
        if (!this.isConnected || !this.client) return;

        try {
            await this.client.setex(key, ttlSeconds, JSON.stringify(value));
        } catch (error) {
            logger.warn({ key }, 'Redis SET failed');
        }
    }

    /**
     * Delete a cached value by key.
     */
    async del(key: string): Promise<void> {
        if (!this.isConnected || !this.client) return;

        try {
            await this.client.del(key);
        } catch (error) {
            logger.warn({ key }, 'Redis DEL failed');
        }
    }

    /**
     * Delete all keys matching a pattern.
     * Useful for cache invalidation (e.g., all keys for a module's contents).
     */
    async delPattern(pattern: string): Promise<void> {
        if (!this.isConnected || !this.client) return;

        try {
            const keys = await this.client.keys(pattern);
            if (keys.length > 0) {
                await this.client.del(...keys);
            }
        } catch (error) {
            logger.warn({ pattern }, 'Redis DEL pattern failed');
        }
    }

    /**
     * Check if Redis is currently connected.
     */
    getConnectionStatus(): boolean {
        return this.isConnected;
    }

    /**
     * Gracefully disconnect Redis.
     */
    async disconnect(): Promise<void> {
        if (this.client) {
            await this.client.quit();
            this.isConnected = false;
            logger.info('Redis disconnected');
        }
    }
}

// Cache key builders (centralized namespace management)
export const CacheKeys = {
    content: (id: string) => `examease:content:${id}`,
    contentsByModule: (moduleId: string, page: number) => `examease:contents:module:${moduleId}:page:${page}`,
    videoUrl: (contentId: string) => `examease:video:url:${contentId}`,
    allContentsPattern: () => 'examease:contents:*',
    contentPattern: (id: string) => `examease:content:${id}*`,
} as const;

// Singleton export
export const redisService = new RedisService();
