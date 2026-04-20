import { Schema, model, Document } from 'mongoose';

export interface IAppConfig extends Document {
    maintenanceMode: boolean;
    maintenanceMessage?: string;
    minAppVersion: string;
    latestAppVersion: string;
    forceUpdate: boolean;
    socialLinks: {
        instagram?: string;
        telegram?: string;
        whatsapp?: string;
        youtube?: string;
    };
    supportEmail: string;
    privacyPolicyUrl: string;
    termsConditionsUrl: string;
    primaryColor: string;
    featureFlags: Record<string, boolean>;
    createdAt: Date;
    updatedAt: Date;
}

const appConfigSchema = new Schema<IAppConfig>(
    {
        maintenanceMode: { type: Boolean, default: false },
        maintenanceMessage: { type: String, default: 'We are currently under maintenance. Please check back later.' },
        minAppVersion: { type: String, default: '1.0.0' },
        latestAppVersion: { type: String, default: '1.0.0' },
        forceUpdate: { type: Boolean, default: false },
        socialLinks: {
            instagram: { type: String },
            telegram: { type: String },
            whatsapp: { type: String },
            youtube: { type: String },
        },
        supportEmail: { type: String, required: true, default: 'support@examease.com' },
        privacyPolicyUrl: { type: String, default: '' },
        termsConditionsUrl: { type: String, default: '' },
        primaryColor: { type: String, default: '#1E88E5' },
        featureFlags: { type: Schema.Types.Mixed, default: {} },
    },
    {
        timestamps: true,
    }
);

export const AppConfig = model<IAppConfig>('AppConfig', appConfigSchema);
