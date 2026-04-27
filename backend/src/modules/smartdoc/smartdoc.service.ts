// @ts-ignore
import pdfParse from 'pdf-parse/lib/pdf-parse.js';
import Tesseract from 'tesseract.js';
import PDFDocument from 'pdfkit';
import path from 'path';
import fs from 'fs';

export class SmartDocService {
    static async extractText(files: Express.Multer.File[], textInput?: string): Promise<string> {
        let extractedText = '';

        if (files && files.length > 0) {
            for (const file of files) {
                if (file.mimetype === 'application/pdf') {
                    try {
                        const data = await pdfParse(file.buffer);
                        extractedText += data.text + '\n\n';
                    } catch (err) {
                        console.error('PDF Parse Error:', err);
                    }
                } else if (file.mimetype.startsWith('image/')) {
                    try {
                        const { data: { text } } = await Tesseract.recognize(
                            file.buffer,
                            'eng+mal',
                        );
                        extractedText += text + '\n\n';
                    } catch (err) {
                        console.error('Tesseract Error:', err);
                    }
                }
            }
        }

        if (textInput) {
            extractedText += textInput + '\n\n';
        }

        return extractedText.trim();
    }

    static async generatePdfStream(text: string): Promise<PDFKit.PDFDocument> {
        // A4: 595.28 x 841.89
        // 1 inch margin: 72 points
        const doc = new PDFDocument({
            size: 'A4',
            margins: { top: 72, bottom: 72, left: 72, right: 72 },
            autoFirstPage: false,
            bufferPages: true
        });

        const regularFontPath = path.resolve(process.cwd(), 'assets', 'AnekMalayalam-Regular.ttf');
        const boldFontPath = path.resolve(process.cwd(), 'assets', 'AnekMalayalam-Bold.ttf');
        const hasRegularFont = fs.existsSync(regularFontPath);
        const hasBoldFont = fs.existsSync(boldFontPath);

        if (hasRegularFont) doc.registerFont('Malayalam-Regular', regularFontPath);
        if (hasBoldFont) doc.registerFont('Malayalam-Bold', boldFontPath);

        const regularFont = hasRegularFont ? 'Malayalam-Regular' : 'Times-Roman';
        const boldFont = hasBoldFont ? 'Malayalam-Bold' : 'Times-Bold';

        const logoPath = path.resolve(process.cwd(), 'assets', 'examease_logo.png');
        const hasLogo = fs.existsSync(logoPath);

        // Add first page and then set initial state
        doc.addPage();
        doc.font(regularFont).fontSize(12).fillColor('black').opacity(1);

        const lines = text.split('\n');

        for (let line of lines) {
            line = line.trim();
            if (!line) {
                doc.moveDown();
                continue;
            }

            if (line.startsWith('#') || (/^[A-Z\s]+$/.test(line) && line.length > 3 && line.length < 50)) {
                // Heading
                const cleanHeading = line.replace(/^#+\s*/, '');
                doc.font(boldFont)
                    .fontSize(14)
                    .text(cleanHeading, { align: 'center' });
                doc.moveDown(0.5);
            } else {
                // Body
                doc.font(regularFont)
                    .fontSize(12)
                    .text(line, {
                        align: 'justify',
                        lineGap: 6 // ~1.5 spacing
                    });
            }
        }

        // Post-process pages for decorations (Watermark, Border, Footer)
        const range = doc.bufferedPageRange();
        const totalPages = range.count;
        const timestamp = new Date().toLocaleString('en-US', {
            year: 'numeric', month: 'short', day: 'numeric',
            hour: '2-digit', minute: '2-digit', hour12: true
        });

        for (let i = range.start; i < range.start + range.count; i++) {
            doc.switchToPage(i);

            // 1. Draw Watermark
            if (hasLogo) {
                doc.save();
                doc.opacity(0.1);
                const logoWidth = 300;
                doc.image(logoPath, (doc.page.width - logoWidth) / 2, (doc.page.height - logoWidth) / 2, { width: logoWidth });
                doc.restore();
            } else {
                doc.save();
                doc.fillColor('#e0e0e0');
                doc.fontSize(60);
                doc.opacity(0.3);
                const watermarkText = 'EXAMEASE';
                const textWidth = doc.widthOfString(watermarkText);
                doc.rotate(-45, { origin: [doc.page.width / 2, doc.page.height / 2] });
                doc.text(watermarkText,
                    (doc.page.width - textWidth) / 2,
                    (doc.page.height / 2) - 30,
                    { lineBreak: false }
                );
                doc.restore();
            }

            // 2. Draw Black Border (at 0.5 inch / 36pt from edge)
            // This leaves 0.5 inch padding between border and content (since content starts at 72pt)
            doc.save();
            doc.rect(36, 36, doc.page.width - 72, doc.page.height - 72)
                .lineWidth(1)
                .strokeColor('black')
                .stroke();
            doc.restore();

            // 3. Footer (Generated on, Copyright, Page Numbers)
            // Positioned at bottom inside the 0.5" border, in the padding area
            const footerY = doc.page.height - 58;
            doc.save();
            doc.font(regularFont).fontSize(8).fillColor('#333333');

            // Left: Timestamp & Copyright
            doc.text(`Generated on: ${timestamp} | © examease.in`, 72, footerY, {
                lineBreak: false
            });

            // Right: Page Numbering
            if (totalPages > 1) {
                const pageText = `Page ${i + 1} of ${totalPages}`;
                doc.text(pageText, 72, footerY, {
                    align: 'right',
                    width: doc.page.width - 144,
                    lineBreak: false
                });
            }
            doc.restore();
        }

        return doc;
    }
}
