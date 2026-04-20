import 'dotenv/config';
import mongoose from 'mongoose';
import { Payment } from './src/modules/payments/payment.model.js';
import { sendResponse } from './src/utils/response.util.js';

async function testFormat() {
    await mongoose.connect(process.env.MONGODB_URI || "mongodb://localhost:27017/examease");
    const payments = await Payment.find().limit(2);
    
    // Simulate express response
    const mockRes: any = {
        status(code: number) { this.code = code; return this; },
        json(payload: any) { this.payload = payload; return this; }
    };

    sendResponse(mockRes, 200, true, 'Fetched', payments);
    console.log(JSON.stringify(mockRes.payload, null, 2));
    process.exit(0);
}

testFormat();
