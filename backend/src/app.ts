import './config/env.js';
import express, { type Application, type Request, type Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { errorHandler } from './middleware/error.middleware.js';
import { sendResponse } from './utils/response.util.js';
// Routes
import { authRoutes } from './modules/auth/auth.route.js';
import { userRoutes } from './modules/users/user.route.js';
import { examRoutes } from './modules/exams/exam.route.js';
import { moduleRoutes } from './modules/modules/module.route.js';
import { contentRoutes } from './modules/contents/content.route.js';
import { questionRoutes } from './modules/questions/question.route.js';
import { testSessionRoutes } from './modules/test-session/test-session.route.js';
import { paymentRoutes } from './modules/payments/payment.route.js';
import { adRoutes } from './modules/ads/ad.route.js';
import { appConfigRoutes } from './modules/app-config/app-config.route.js';
import { analyticsRoutes } from './modules/analytics/analytics.route.js';
import { videoRoutes } from './modules/contents/video.route.js';
import { documentRoutes } from './modules/contents/document.route.js';

const app: Application = express();

// Middleware — CORS must come BEFORE helmet to handle preflight first
app.use(cors({
    origin: (origin, callback) => callback(null, true), 
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'x-api-key', 'Accept', 'Origin', 'X-Requested-With'],
    optionsSuccessStatus: 200
}));

app.use(helmet());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));



app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/exams', examRoutes);
app.use('/api/v1/modules', moduleRoutes);
app.use('/api/v1/contents', contentRoutes);
app.use('/api/v1/questions', questionRoutes);
app.use('/api/v1/test-sessions', testSessionRoutes);
app.use('/api/v1/payments', paymentRoutes);
app.use('/api/v1/ads', adRoutes);
app.use('/api/v1/app-config', appConfigRoutes);
app.use('/api/v1/analytics', analyticsRoutes);
app.use('/api/v1/videos', videoRoutes);
app.use('/api/v1/documents', documentRoutes);

// Health check
app.get('/health', (req: Request, res: Response) => {
    return sendResponse(res, 200, true, 'Server is healthy');
});

// Error handling
app.use(errorHandler);

export default app;
