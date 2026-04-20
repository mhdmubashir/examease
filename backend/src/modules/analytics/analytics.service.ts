import { User } from '../users/user.model.js';
import { Payment } from '../payments/payment.model.js';
import { Exam } from '../exams/exam.model.js';
import { TestSession } from '../test-session/test-session.model.js';
import { PaymentStatus } from '../../constants/enums.js';

export class AnalyticsService {
    static async getDashboardStats() {
        const [totalUsers, totalExams, totalRevenue, activeSessions] = await Promise.all([
            User.countDocuments({ role: 'USER' }),
            Exam.countDocuments({ isActive: true }),
            Payment.aggregate([
                { $match: { status: PaymentStatus.SUCCESS } },
                { $group: { _id: null, total: { $sum: '$amount' } } }
            ]),
            TestSession.countDocuments({ status: 'ONGOING' })
        ]);

        return {
            totalUsers,
            totalExams,
            totalRevenue: totalRevenue[0]?.total || 0,
            activeSessions
        };
    }

    static async getRevenueStats() {
        // Daily revenue for last 7 days
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

        const revenueData = await Payment.aggregate([
            {
                $match: {
                    status: PaymentStatus.SUCCESS,
                    createdAt: { $gte: sevenDaysAgo }
                }
            },
            {
                $group: {
                    _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
                    amount: { $sum: '$amount' }
                }
            },
            { $sort: { _id: 1 } }
        ]);

        return revenueData;
    }
}
