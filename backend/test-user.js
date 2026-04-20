var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
import 'dotenv/config';
import mongoose from 'mongoose';
import { User } from './src/modules/users/user.model.js';
import { sendResponse } from './src/utils/response.util.js';
function testFormat() {
    return __awaiter(this, void 0, void 0, function* () {
        yield mongoose.connect(process.env.MONGODB_URI || "mongodb://localhost:27017/examease");
        const users = yield User.find().limit(2);
        // Simulate express response
        const mockRes = {
            status(code) { this.code = code; return this; },
            json(payload) { this.payload = payload; return this; }
        };
        sendResponse(mockRes, 200, true, 'Fetched', users);
        console.log(JSON.stringify(mockRes.payload, null, 2));
        process.exit(0);
    });
}
testFormat();
//# sourceMappingURL=test-user.js.map