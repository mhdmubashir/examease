import { z } from 'zod';

export const updateAppConfigSchema = z.object({
    body: z.object({
        maintenanceMode: z.boolean().optional(),
        maintenanceMessage: z.string().optional(),
        minAppVersion: z.string().optional(),
        latestAppVersion: z.string().optional(),
        forceUpdate: z.boolean().optional(),
        socialLinks: z.object({
            instagram: z.string().url().optional(),
            telegram: z.string().url().optional(),
            whatsapp: z.string().url().optional(),
            youtube: z.string().url().optional(),
        }).optional(),
        supportEmail: z.string().email().optional(),
        privacyPolicyUrl: z.string().url().optional(),
        termsConditionsUrl: z.string().url().optional(),
        primaryColor: z.string().regex(/^#[0-9A-F]{6}$/i).optional(),
        featureFlags: z.record(z.string(), z.boolean()).optional(),
    }),
});
