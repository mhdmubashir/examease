import { Module, type IModule } from './module.model.js';

export class ModuleService {
    static async createModule(data: Partial<IModule>) {
        return await Module.create(data);
    }

    static async getModulesByExam(examId: string, filter: any = {}) {
        return await Module.find({ examId, ...filter }).sort({ orderIndex: 1, createdAt: -1 });
    }

    static async getModuleById(id: string) {
        return await Module.findById(id).populate('includedModules');
    }

    static async updateModule(id: string, data: Partial<IModule>) {
        return await Module.findByIdAndUpdate(id, data, { new: true });
    }

    static async deleteModule(id: string) {
        return await Module.findByIdAndUpdate(id, { isActive: false }, { new: true });
    }

    static async getAllModules(query: any = {}) {
        const { page = 1, limit = 10, search, examId, accessType, isActive } = query;
        const filter: any = {};

        if (search) {
            filter.$or = [
                { title: { $regex: search, $options: 'i' } },
                { description: { $regex: search, $options: 'i' } }
            ];
        }

        if (examId && examId !== 'all' && examId !== 'undefined') {
            filter.examId = examId;
        }

        if (accessType && accessType !== 'all' && accessType !== 'undefined') {
            filter.accessType = accessType;
        }

        if (query.minPrice) {
            filter.price = { ...filter.price, $gte: Number(query.minPrice) };
        }
        if (query.maxPrice) {
            filter.price = { ...filter.price, $lte: Number(query.maxPrice) };
        }

        if (isActive !== undefined && isActive !== 'all') {
            filter.isActive = isActive === 'true' || isActive === true;
        }

        const skip = (Number(page) - 1) * Number(limit);
        const [data, total] = await Promise.all([
            Module.find(filter)
                .sort({ orderIndex: 1, createdAt: -1 })
                .skip(skip)
                .limit(Number(limit)),
            Module.countDocuments(filter)
        ]);

        return {
            data,
            total,
            page: Number(page),
            limit: Number(limit),
            totalPages: Math.ceil(total / Number(limit))
        };
    }
}
