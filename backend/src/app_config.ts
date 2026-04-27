import dotenv from 'dotenv';
dotenv.config();

export const isProduction = process.env.IS_PRODUCTION === 'true';

const _apiBaseURLDev = process.env.DEV_API_URL || "https://api.examease.com/v1";
const _apiBaseURLProd = process.env.PROD_API_URL || "https://api.examease.com/v1";


//mongo
const _mongoDevURL = process.env.DEV_MONGODB_URI || 'mongodb://localhost:27017/examease';
const _mongoProdURL = process.env.PROD_MONGODB_URI || 'mongodb://localhost:27017/examease';

//redis
const _redisDevURL = process.env.DEV_REDIS_URL || 'redis://localhost:6379';
const _redisProdURL = process.env.PROD_REDIS_URL || 'redis://localhost:6379';

//secret key
const appDevAppSecretKey = process.env.DEV_SECRET_KEY || "dev_sec";
const appSecretKey = process.env.PROD_SECRET_KEY || "prod_sec";

//s3 bucket
const _devS3Bucket = process.env.DEV_AWS_S3_BUCKET || "examease-videos-dev";
const _prodS3Bucket = process.env.PROD_AWS_S3_BUCKET || "examease-videos-prod";

export const appVersion = "1.0.0";
export const apiVersion = "v1";

export class AppConfig {
    static get apiUrl() {
        return isProduction ? _apiBaseURLProd : _apiBaseURLDev;
    }

    static get mongoUrl() {
        return isProduction ? _mongoProdURL : _mongoDevURL;
    }

    static get redisUrl() {
        return isProduction ? _redisProdURL : _redisDevURL;
    }

    static get apiKey() {
        return isProduction ? appSecretKey : appDevAppSecretKey;
    }

    static get s3Bucket() {
        return isProduction ? _prodS3Bucket : _devS3Bucket;
    }
}
