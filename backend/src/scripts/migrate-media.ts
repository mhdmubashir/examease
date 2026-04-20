import '../config/env.js';
import mongoose from 'mongoose';
import { Ad } from '../modules/ads/ad.model.js';
import { Content } from '../modules/contents/content.model.js';
import logger from '../utils/logger.js';

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/examease';

const migrate = async () => {
    try {
        await mongoose.connect(MONGODB_URI);
        logger.info('Connected to MongoDB for migration');

        // 1. Migrate Ads
        const ads = await Ad.find({ imageUrl: { $exists: true } });
        logger.info(`Found ${ads.length} ads to migrate`);

        for (const ad of ads as any[]) {
            const imageUrl = ad.imageUrl;
            if (imageUrl) {
                // Extract filename from URL if possible
                const name = imageUrl.split('/').pop() || 'banner.jpg';
                const mime = name.endsWith('.png') ? 'image/png' : 'image/jpeg';
                // For documentId, use the filename or a UUID
                const documentId = name.split('-')[0] || 'legacy-ad';

                ad.image = {
                    documentId,
                    name,
                    mime,
                    url: imageUrl,
                };
                
                // Remove old field
                ad.imageUrl = undefined;
                await ad.save();
                logger.info(`Migrated ad: ${ad.title}`);
            }
        }

        // 2. Migrate Contents
        const contents = await Content.find({ 'data.s3Key': { $exists: true } });
        logger.info(`Found ${contents.length} contents to migrate`);

        for (const content of contents as any[]) {
            const data = content.data;
            if (data && data.s3Key && !data.media) {
                // Current structure: { s3Key, presignedUrl, originalFileName, mimeType, ... }
                // Desired structure: { documentId, name, mime, url }
                
                const mediaObject = {
                    documentId: data.s3Key,
                    name: data.originalFileName || data.name || 'document.pdf',
                    mime: data.mimeType || data.mime || 'application/octet-stream',
                    url: data.presignedUrl || data.fileUrl || data.url || '',
                };

                // Move existing fields into standardized structure
                content.data = {
                    ...data,
                    media: mediaObject,
                };

                // Optionally clean up old flat fields in data if desired
                // delete content.data.s3Key;
                // delete content.data.presignedUrl;
                
                await content.save();
                logger.info(`Migrated content: ${content.title}`);
            }
        }

        logger.info('Migration completed successfully');
        process.exit(0);
    } catch (error) {
        logger.error({ err: error }, 'Migration failed');
        process.exit(1);
    }
};

migrate();
