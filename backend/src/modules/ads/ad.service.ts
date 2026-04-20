import { Ad, type IAd } from './ad.model.js';
import { AdPlacement } from '../../constants/enums.js';

export class AdService {
    static async createAd(data: Partial<IAd>) {
        return await Ad.create(data);
    }

    static async getActiveAdsByPlacement(placement: AdPlacement) {
        const now = new Date();
        return await Ad.find({
            placement,
            isActive: true,
            startDate: { $lte: now },
            endDate: { $gte: now },
        }).sort({ orderIndex: 1, createdAt: -1 });
    }

    static async getAdById(id: string) {
        return await Ad.findById(id);
    }

    static async updateAd(id: string, data: Partial<IAd>) {
        return await Ad.findByIdAndUpdate(id, data, { new: true });
    }

    static async deleteAd(id: string) {
        return await Ad.findByIdAndDelete(id);
    }

    static async getAllAds(filter: any = {}) {
        return await Ad.find(filter).sort({ orderIndex: 1, createdAt: -1 });
    }
}
