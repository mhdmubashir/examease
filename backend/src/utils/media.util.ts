/**
 * Standard Media Structure for Examease Project
 */
export interface IMedia {
    documentId: string; // The S3 key or unique identifier
    name: string;       // Original filename
    mime: string;       // MIME type (e.g., application/pdf)
    url: string;        // Public or presigned URL
}

/**
 * Builds a standardized Media object.
 */
export const buildMediaObject = (
    s3Key: string,
    url: string,
    originalFileName: string,
    mimeType: string
): IMedia => {
    return {
        documentId: s3Key,
        name: originalFileName,
        mime: mimeType,
        url: url,
    };
};
