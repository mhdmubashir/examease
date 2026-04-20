import nodemailer from 'nodemailer';
import logger from './logger.js';

class MailService {
    private transporter;

    constructor() {
        // Configure using environment variables
        // If not provided, it will log the OTP to console (useful for development)
        const host = process.env.SMTP_HOST || '';
        const port = parseInt(process.env.SMTP_PORT || '587');
        const user = process.env.SMTP_USER || '';
        const pass = process.env.SMTP_PASS || '';

        if (host && user && pass) {
            this.transporter = nodemailer.createTransport({
                host,
                port,
                secure: port === 465,
                auth: { user, pass },
            });
            logger.info('MailService: Configured with SMTP');
        } else {
            logger.warn('MailService: No SMTP config found. Emails will be logged to console.');
        }
    }

    async sendOtpEmail(email: string, otp: string) {
        const mailOptions = {
            from: `"ExamEase Support" <${process.env.SMTP_USER || 'no-reply@examease.com'}>`,
            to: email,
            subject: 'Your ExamEase Verification Code',
            html: `
                <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
                    <h2 style="color: #3b82f6;">Welcome to ExamEase!</h2>
                    <p>To complete your registration, please use the following 4-digit verification code:</p>
                    <div style="font-size: 32px; font-weight: bold; color: #1e3a8a; letter-spacing: 5px; margin: 20px 0;">
                        ${otp}
                    </div>
                    <p style="color: #666;">This code is valid for 10 minutes. If you did not request this code, please ignore this email.</p>
                    <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;" />
                    <p style="font-size: 12px; color: #aaa;">&copy; 2026 ExamEase. All rights reserved.</p>
                </div>
            `,
        };

        if (this.transporter) {
            try {
                await this.transporter.sendMail(mailOptions);
                logger.info(`OTP Email sent to ${email}`);
            } catch (error) {
                logger.error({ err: error }, `Failed to send OTP email to ${email}`);
                throw new Error('Failed to send verification email');
            }
        } else {
            console.log('\n-----------------------------------------');
            console.log(`| [DEBUG] Verification Code for ${email}: ${otp} |`);
            console.log('-----------------------------------------\n');
            logger.info(`[DEVSIM] OTP Code: ${otp} logged to console for ${email}`);
        }
    }
}

export const mailService = new MailService();
