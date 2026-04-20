import { TestSession, type ITestSession } from './test-session.model.js';
import { TestSessionStatus } from '../../constants/enums.js';
import { Question } from '../questions/question.model.js';
import { Types } from 'mongoose';

export class TestSessionService {
    static async startSession(userId: string, mockTestId: string) {
        // Schema index handles uniqueness of active sessions
        return await TestSession.create({
            userId,
            mockTestId,
            status: TestSessionStatus.ONGOING,
        });
    }

    static async submitSession(
        sessionId: string,
        userId: string,
        answers: { questionId: string; selectedOptionIndex: number; timeTakenSeconds: number }[]
    ) {
        const session = await TestSession.findOne({ _id: sessionId, userId, status: TestSessionStatus.ONGOING });
        if (!session) throw new Error('Active session not found');

        const questions = await Question.find({ mockTestId: session.mockTestId });
        const questionMap = new Map(questions.map(q => [q._id.toString(), q]));

        let totalScore = 0;
        let correctCount = 0;
        let totalTime = 0;

        const processedAnswers = answers.map(ans => {
            const question = questionMap.get(ans.questionId);
            if (!question) return null;

            const isCorrect = question.options[ans.selectedOptionIndex]?.isCorrect || false;
            if (isCorrect) {
                totalScore += question.marks;
                correctCount++;
            } else {
                totalScore -= question.negativeMarks;
            }
            totalTime += ans.timeTakenSeconds;

            return {
                questionId: ans.questionId,
                selectedOptionIndex: ans.selectedOptionIndex,
                isCorrect,
                timeTakenSeconds: ans.timeTakenSeconds,
            };
        }).filter(Boolean) as any[];

        session.answers = processedAnswers;
        session.score = totalScore;
        session.accuracy = processedAnswers.length > 0 ? (correctCount / processedAnswers.length) * 100 : 0;
        session.timeTaken = totalTime;
        session.status = TestSessionStatus.COMPLETED;
        session.submittedAt = new Date();

        // Calculate rank
        const higherScores = await TestSession.countDocuments({
            mockTestId: session.mockTestId,
            score: { $gt: totalScore },
            status: TestSessionStatus.COMPLETED,
        });
        session.rank = higherScores + 1;

        return await session.save();
    }

    static async getSession(sessionId: string, userId: string) {
        return await TestSession.findOne({ _id: sessionId, userId }).populate('answers.questionId');
    }

    static async getUserSessions(userId: string) {
        return await TestSession.find({ userId }).sort({ createdAt: -1 });
    }
}
