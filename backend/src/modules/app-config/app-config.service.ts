import { AppConfig, type IAppConfig } from './app-config.model.js';

export class AppConfigService {
    /**
     * Get the global config. 
     * Always returns a single document, creating one if it doesn't exist.
     */
    static async getConfig() {
        let config = await AppConfig.findOne();
        if (!config) {
            config = await AppConfig.create({});
        }
        return config;
    }

    static async updateConfig(data: Partial<IAppConfig>) {
        let config = await AppConfig.findOne();
        if (!config) {
            return await AppConfig.create(data);
        }
        return await AppConfig.findByIdAndUpdate(config._id, data, { new: true });
    }
}
