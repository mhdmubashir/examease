import { Question, type IQuestion } from './question.model.js';

export class QuestionService {
    static async createQuestion(data: Partial<IQuestion>) {
        return await Question.create(data);
    }

    static async bulkCreateQuestions(questions: Partial<IQuestion>[]) {
        return await Question.insertMany(questions);
    }

    static async getQuestionsByTest(mockTestId: string) {
        return await Question.find({ mockTestId }).sort({ createdAt: 1 });
    }

    static async updateQuestion(id: string, data: Partial<IQuestion>) {
        return await Question.findByIdAndUpdate(id, data, { new: true });
    }

    static async deleteQuestion(id: string) {
        return await Question.findByIdAndDelete(id);
    }
}
