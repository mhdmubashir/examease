import { Exam, type IExam } from './exam.model.js';

export class ExamService {
    static async createExam(data: Partial<IExam>) {
        const slug = data.title!
            .toLowerCase()
            .replace(/ /g, '-')
            .replace(/[^\w-]+/g, '');

        // Ensure slug uniqueness
        let finalSlug = slug;
        let count = 1;
        while (await Exam.findOne({ slug: finalSlug })) {
            finalSlug = `${slug}-${count}`;
            count++;
        }

        return await Exam.create({ ...data, slug: finalSlug });
    }

    static async getAllExams(query: any = {}) {
        const { page = 1, limit = 10, search, isActive } = query;
        const filter: any = {};

        if (search) {
            filter.$or = [
                { title: { $regex: search, $options: 'i' } },
                { description: { $regex: search, $options: 'i' } }
            ];
        }

        if (isActive !== undefined && isActive !== 'all') {
            filter.isActive = isActive === 'true' || isActive === true;
        }

        const skip = (Number(page) - 1) * Number(limit);
        const [data, total] = await Promise.all([
            Exam.find(filter)
                .sort({ orderIndex: 1, createdAt: -1 })
                .skip(skip)
                .limit(Number(limit)),
            Exam.countDocuments(filter)
        ]);

        return {
            data,
            total,
            page: Number(page),
            limit: Number(limit),
            totalPages: Math.ceil(total / Number(limit))
        };
    }

    static async getExamById(id: string) {
        return await Exam.findById(id);
    }

    static async updateExam(id: string, data: Partial<IExam>) {
        return await Exam.findByIdAndUpdate(id, data, { new: true });
    }

    static async deleteExam(id: string) {
        return await Exam.findByIdAndUpdate(id, { isActive: false }, { new: true });
    }
}
