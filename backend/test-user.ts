import 'dotenv/config';
import mongoose from 'mongoose';
import { User } from './src/modules/users/user.model.js';
import { sendResponse } from './src/utils/response.util.js';

async function testFormat() {
    await mongoose.connect(process.env.MONGODB_URI || "mongodb://localhost:27017/examease");
    const users = await User.find().limit(2);
    
    // Simulate express response
    const mockRes: any = {
        status(code: number) { this.code = code; return this; },
        json(payload: any) { this.payload = payload; return this; }
    };

    sendResponse(mockRes, 200, true, 'Fetched', users);
    console.log(JSON.stringify(mockRes.payload, null, 2));
    process.exit(0);
}

testFormat();
