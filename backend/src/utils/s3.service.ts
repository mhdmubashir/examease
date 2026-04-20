import {
    S3Client,
    PutObjectCommand,
    DeleteObjectCommand,
    GetObjectCommand,
    HeadObjectCommand,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import logger from './logger.js';
import { AppConfig } from '../app_config.js';

/**
 * S3 Service — Handles all interactions with AWS S3 for video storage.
 *
 * Architecture decisions:
 * - Presigned URLs for authenticated access (no public bucket)
 * - S3 keys follow: videos/{contentId}/{uuid}.{ext}
 * - URL expiry defaults to 1 hour (configurable via env)
 * - Centralized service prevents scattered S3 logic
 */

class S3Service {
    private client: S3Client;
    private bucket: string;
    private presignedExpiry: number;

    constructor() {
        this.bucket = AppConfig.s3Bucket;
        this.presignedExpiry = parseInt(process.env.AWS_S3_PRESIGNED_EXPIRY || '3600', 10);

        this.client = new S3Client({
            region: process.env.AWS_REGION || 'ap-south-1',
            credentials: {
                accessKeyId: process.env.AWS_ACCESS_KEY_ID || '',
                secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || '',
            },
        });

        logger.info(`S3 Service initialized [bucket=${this.bucket}, region=${process.env.AWS_REGION}]`);
    }

    /**
     * Upload a file buffer to S3 with a specific key.
     * @param buffer - The file buffer
     * @param key - S3 object key (e.g., "docs/uuid.pdf" or "images/ad-123.jpg")
     * @param mimeType - MIME type of the file
     * @returns The S3 key of the uploaded object
     */
    async uploadFile(buffer: Buffer, key: string, mimeType: string): Promise<string> {
        const command = new PutObjectCommand({
            Bucket: this.bucket,
            Key: key,
            Body: buffer,
            ContentType: mimeType,
        });

        await this.client.send(command);
        logger.info(`File uploaded to S3: ${key}`);
        return key;
    }

    /**
     * Upload a video file buffer to S3.
     * @deprecated Use uploadFile instead
     */
    async uploadVideo(buffer: Buffer, key: string, mimeType: string): Promise<string> {
        return this.uploadFile(buffer, key, mimeType);
    }

    /**
     * Generate a time-limited presigned URL for authenticated access.
     * @param key - S3 object key
     * @param expiresIn - URL expiry in seconds (default from env)
     * @returns Presigned URL string
     */
    async getPresignedUrl(key: string, expiresIn?: number): Promise<string> {
        const command = new GetObjectCommand({
            Bucket: this.bucket,
            Key: key,
        });

        const url = await getSignedUrl(this.client, command, {
            expiresIn: expiresIn || this.presignedExpiry,
        });

        return url;
    }

    /**
     * Check if an object exists in S3.
     * @param key - S3 object key
     * @returns true if object exists
     */
    async objectExists(key: string): Promise<boolean> {
        try {
            await this.client.send(new HeadObjectCommand({
                Bucket: this.bucket,
                Key: key,
            }));
            return true;
        } catch {
            return false;
        }
    }

    /**
     * Delete a file from S3.
     * @param key - S3 object key
     */
    async deleteFile(key: string): Promise<void> {
        const command = new DeleteObjectCommand({
            Bucket: this.bucket,
            Key: key,
        });

        await this.client.send(command);
        logger.info(`File deleted from S3: ${key}`);
    }

    /**
     * Delete a video from S3.
     * @deprecated Use deleteFile instead
     */
    async deleteVideo(key: string): Promise<void> {
        return this.deleteFile(key);
    }

    /**
     * Get the default presigned URL expiry in seconds.
     */
    getDefaultExpiry(): number {
        return this.presignedExpiry;
    }
}

// Singleton export
export const s3Service = new S3Service();
