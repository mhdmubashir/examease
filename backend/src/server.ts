import './config/env.js'; // Must be first — loads .env before any other module
import mongoose from 'mongoose';
import app from './app.js';
import logger from './utils/logger.js';
import { redisService } from './utils/redis.service.js';
import { AppConfig } from './app_config.js';

const PORT = process.env.PORT || 5050;
const MONGODB_URI = AppConfig.mongoUrl;

const startServer = async () => {
    try {
        // Connect to MongoDB
        await mongoose.connect(MONGODB_URI);
        logger.info('Connected to MongoDB');

        // Connect to Redis (non-blocking — app works without it)
        await redisService.connect();
        logger.info(`Redis status: ${redisService.getConnectionStatus() ? 'connected' : 'unavailable (running without cache)'}`);

        app.listen(PORT, () => {
            logger.info(`Server is running on port ${PORT}`);
            // logger.debug(`API URL: 
            // localhost:${PORT}/`);


        });
    } catch (error) {
        logger.error({ err: error }, 'Error starting server');
        process.exit(1);
    }
};

// Graceful shutdown
process.on('SIGTERM', async () => {
    logger.info('SIGTERM received. Shutting down gracefully...');
    await redisService.disconnect();
    await mongoose.disconnect();
    process.exit(0);
});

process.on('SIGINT', async () => {
    logger.info('SIGINT received. Shutting down...');
    await redisService.disconnect();
    await mongoose.disconnect();
    process.exit(0);
});

startServer();
