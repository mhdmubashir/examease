import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import { OAuth2Client } from 'google-auth-library';
import { User } from '../users/user.model.js';
import { UserRole } from '../../constants/enums.js';

const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

export class AuthService {
    static async generateTokens(userId: string, role: UserRole) {
        const accessToken = jwt.sign(
            { userId, role },
            process.env.JWT_SECRET as string,
            { expiresIn: (process.env.JWT_EXPIRE as any) || '1d' }
        );

        const refreshToken = jwt.sign(
            { userId },
            process.env.JWT_REFRESH_SECRET as string,
            { expiresIn: (process.env.JWT_REFRESH_EXPIRE as any) || '7d' }
        );

        return { accessToken, refreshToken };
    }

    static async hashPassword(password: string) {
        return await bcrypt.hash(password, 10);
    }

    static async comparePassword(password: string, hash: string) {
        return await bcrypt.compare(password, hash);
    }

    static generateOtp(): string {
        return Math.floor(1000 + Math.random() * 9000).toString();
    }

    static async verifyGoogleToken(idToken: string) {
        try {
            const ticket = await googleClient.verifyIdToken({
                idToken,
                audience: (process.env.GOOGLE_CLIENT_ID as string) || '',
            });
            return ticket.getPayload();
        } catch (error) {
            return null;
        }
    }
}
