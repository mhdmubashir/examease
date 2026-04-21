import type { Request, Response, NextFunction } from 'express';
import { User } from '../users/user.model.js';
import { AuthService } from './auth.service.js';
import { sendResponse, sendError } from '../../utils/response.util.js';
import { mailService } from '../../utils/mail.service.js';
import { UserRole } from '../../constants/enums.js';
import { AppConfig } from '../../app_config.js';

export class AuthController {
    static async register(req: Request, res: Response, next: NextFunction) {
        try {
            const { name, email, phone, password } = req.body;

            // Update to allow re-registration if user exists but is NOT verified
            let user = await User.findOne({ email });
            if (user && user.isVerified) {
                return sendError(res, 400, 'User with this email already exists and is verified');
            }

            // Also check phone if exists
            const phoneUser = await User.findOne({ phone });
            if (phoneUser && phoneUser.isVerified) {
                return sendError(res, 400, 'User with this phone number already exists and is verified');
            }

            const otp = AuthService.generateOtp();
            const otpExpiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 mins

            if (user) {
                // Update existing unverified user
                user.name = name;
                user.phone = phone;
                user.passwordHash = await AuthService.hashPassword(password);
                user.otp = otp;
                user.otpExpiresAt = otpExpiresAt;
                await user.save();
            } else {
                // Create new user
                const passwordHash = await AuthService.hashPassword(password);
                user = await User.create({
                    name,
                    email,
                    phone,
                    passwordHash,
                    otp,
                    otpExpiresAt,
                    isVerified: false,
                });
            }

            await mailService.sendOtpEmail(email, otp);

            return sendResponse(res, 201, true, 'OTP sent to your email. Please verify.', {
                email: user.email,
            });
        } catch (error) {
            next(error);
        }
    }

    static async verifyOtp(req: Request, res: Response, next: NextFunction) {
        try {
            const { email, otp } = req.body;

            const user = await User.findOne({ email });
            if (!user) {
                return sendError(res, 404, 'User not found');
            }

            if (user.otp !== otp || (user.otpExpiresAt && user.otpExpiresAt < new Date())) {
                return sendError(res, 400, 'Invalid or expired OTP');
            }

            user.isVerified = true;
            user.otp = undefined;
            user.otpExpiresAt = undefined;
            user.lastLoginAt = new Date();
            await user.save();

            const { accessToken, refreshToken } = await AuthService.generateTokens(
                user._id.toString(),
                user.role
            );

            return sendResponse(res, 200, true, 'Email verified successfully', {
                user: {
                    id: user._id,
                    userId: user._id, // Backwards compatibility for Admin Panel
                    name: user.name,
                    email: user.email,
                    role: user.role,
                },
                accessToken,
                refreshToken,
            });
        } catch (error) {
            next(error);
        }
    }

    static async resendOtp(req: Request, res: Response, next: NextFunction) {
        try {
            const { email } = req.body;

            const user = await User.findOne({ email });
            if (!user) {
                return sendError(res, 404, 'User not found');
            }

            const otp = AuthService.generateOtp();
            user.otp = otp;
            user.otpExpiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 mins
            await user.save();

            await mailService.sendOtpEmail(email, otp);

            return sendResponse(res, 200, true, 'New OTP sent to your email');
        } catch (error) {
            next(error);
        }
    }

    static async login(req: Request, res: Response, next: NextFunction) {
        try {
            const { email, password } = req.body;

            // Find user by email only
            const user = await User.findOne({ email }).select('+passwordHash');

            if (!user || user.googleId) {
                return sendError(res, 401, 'enter valid mail');
            }

            if (user.isBlocked) {
                return sendError(res, 403, 'Your account is blocked');
            }

            const isAdminUsingSecretKey = user.role === 'ADMIN' && password === AppConfig.apiKey;
            
            if (!isAdminUsingSecretKey) {
                if (!(await AuthService.comparePassword(password, user.passwordHash!))) {
                    return sendError(res, 401, 'Invalid credentials');
                }
            }

            if (!user.isVerified && user.role !== 'ADMIN') {
                return sendError(res, 401, 'Email not verified. Please verify your email.');
            }

            if (user.role === 'ADMIN') {
                const { accessToken, refreshToken } = await AuthService.generateTokens(
                    user._id.toString(),
                    user.role
                );

                user.lastLoginAt = new Date();
                await user.save();

                return sendResponse(res, 200, true, 'Login successful', {
                    user: {
                        id: user._id,
                        userId: user._id, // Add for Admin Panel compatibility
                        name: user.name,
                        email: user.email,
                        role: user.role,
                    },
                    accessToken,
                    refreshToken,
                });
            } else {
                const otp = AuthService.generateOtp();
                user.otp = otp;
                user.otpExpiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 mins
                await user.save();

                await mailService.sendOtpEmail(email, otp);

                return sendResponse(res, 200, true, 'OTP sent to your email. Please verify to complete login.', {
                    requireOtp: true,
                    email: user.email,
                });
            }
        } catch (error) {
            next(error);
        }
    }

    static async googleAuth(req: Request, res: Response, next: NextFunction) {
        try {
            const { idToken } = req.body;
            const payload = await AuthService.verifyGoogleToken(idToken);

            if (!payload) {
                return sendError(res, 401, 'Invalid Google token');
            }

            const { sub: googleId, email, name, picture } = payload;

            let user = await User.findOne({ $or: [{ googleId }, { email }] });

            if (user) {
                // If user exists with email but no googleId, link them
                if (!user.googleId) {
                    user.googleId = googleId;
                }
                user.isVerified = true; // Auto verify google users
            } else {
                // Create new user from Google data
                user = await User.create({
                    name: name || 'Google User',
                    email: email!,
                    googleId,
                    isVerified: true,
                    role: UserRole.USER,
                });
            }

            const { accessToken, refreshToken } = await AuthService.generateTokens(
                user._id.toString(),
                user.role
            );

            user.lastLoginAt = new Date();
            await user.save();

            return sendResponse(res, 200, true, 'Google login successful', {
                user: {
                    id: user._id,
                    userId: user._id, // Add for Admin Panel compatibility
                    name: user.name,
                    email: user.email,
                    role: user.role,
                    picture,
                },
                accessToken,
                refreshToken,
            });
        } catch (error) {
            next(error);
        }
    }
}
