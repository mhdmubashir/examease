import mongoose from 'mongoose';
import bcrypt from 'bcrypt';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
dotenv.config({ path: path.join(__dirname, 'src/config/.env') });

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/examease';

const userSchema = new mongoose.Schema({
    name: String,
    email: { type: String, unique: true },
    phone: String,
    passwordHash: String,
    role: String,
    isBlocked: Boolean,
}, { timestamps: true });

const User = mongoose.model('User', userSchema);

async function seed() {
    try {
        await mongoose.connect(MONGODB_URI);
        console.log('✅ Connected to MongoDB');

        const existing = await User.findOne({ email: 'mubashir@gmail.com' });
        if (existing) {
            console.log('⚠️  User already exists, updating role to ADMIN...');
            await User.updateOne({ email: 'mubashir@gmail.com' }, { role: 'ADMIN' });
            console.log('✅ Role updated to ADMIN');
        } else {
            const passwordHash = await bcrypt.hash('123456', 12);
            await User.create({
                name: 'Mubashir',
                email: 'mubashir@gmail.com',
                phone: '0000000000',
                passwordHash,
                role: 'ADMIN',
                isBlocked: false,
            });
            console.log('✅ Admin user created: mubashir@gmail.com / 123456');
        }

        await mongoose.disconnect();
        console.log('✅ Done.');
        process.exit(0);
    } catch (err) {
        console.error('❌ Error:', err);
        process.exit(1);
    }
}

seed();
