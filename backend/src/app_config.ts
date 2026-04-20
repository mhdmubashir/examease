import dotenv from 'dotenv';
dotenv.config();

export const isProduction = process.env.IS_PRODUCTION === 'true';

const _apiBaseURLDev = process.env.DEV_API_URL || "http://localhost:5050/api/v1";
const _apiBaseURLProd = process.env.PROD_API_URL || "https://api.examease.com/v1";

const appDevAppSecretKey = process.env.DEV_SECRET_KEY || "dev_sec";
const appSecretKey = process.env.PROD_SECRET_KEY || "prod_sec";

const _devS3Bucket = process.env.DEV_AWS_S3_BUCKET || "examease-videos-dev";
const _prodS3Bucket = process.env.PROD_AWS_S3_BUCKET || "examease-videos-prod";

export const appVersion = "1.0.0";
export const apiVersion = "v1";

export class AppConfig {
    static get apiUrl() {
        return isProduction ? _apiBaseURLProd : _apiBaseURLDev;
    }

    static get apiKey() {
        return isProduction ? appSecretKey : appDevAppSecretKey;
    }

    static get s3Bucket() {
        return isProduction ? _prodS3Bucket : _devS3Bucket;
    }
}
