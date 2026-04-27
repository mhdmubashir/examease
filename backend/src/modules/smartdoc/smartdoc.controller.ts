import type { Request, Response } from 'express';
import { SmartDocService } from './smartdoc.service.js';

export class SmartDocController {
    static async generatePdf(req: Request, res: Response): Promise<void> {
        try {
            const files = req.files as Express.Multer.File[];
            const { textInput, customFileName } = req.body;

            const text = await SmartDocService.extractText(files, textInput);

            const doc = await SmartDocService.generatePdfStream(text);

            const fileName = customFileName ? 
                (customFileName.endsWith('.pdf') ? customFileName : `${customFileName}.pdf`) : 
                'smartdoc_output.pdf';

            res.setHeader('Content-Type', 'application/pdf');
            res.setHeader('Content-Disposition', `inline; filename="${fileName}"`);

            doc.pipe(res);
            doc.end();
            
        } catch (error: any) {
            console.error('SmartDoc Generation Error:', error);
            res.status(500).json({ success: false, message: 'Failed to generate PDF', error: error.message });
        }
    }
}
