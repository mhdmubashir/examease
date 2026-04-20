import type { Response } from 'express';

export const sendResponse = (
    res: Response,
    statusCode: number,
    status: boolean = true,
    message: string = "get successfully.",
    data: any = null,
    pagination: any = null
) => {
    let responseData = data;

    // If it's a list (array), always return the unified structure
    if (Array.isArray(data)) {
        responseData = {
            totalSize: pagination?.total ?? data.length,
            pageSize: pagination?.totalPages ?? 1,
            page: pagination?.page ?? 1,
            perPage: pagination?.limit ?? data.length,
            data: data
        };
    } else if (pagination) {
        // If pagination is provided but data is not an array (e.g. nested data case)
        responseData = {
            totalSize: pagination.total || 0,
            pageSize: pagination.totalPages || 1,
            page: pagination.page || 1,
            perPage: pagination.limit || 10,
            data: data || []
        };
    }

    return res.status(statusCode).json({
        status,
        data: responseData,
        title: "",
        message,
        error: ""
    });
};

export const sendError = (
    res: Response,
    statusCode: number,
    message: string,
    error: any = ""
) => {
    return res.status(statusCode).json({
        status: false,
        data: null,
        title: "Error",
        message,
        error: error ? (typeof error === 'string' ? error : JSON.stringify(error)) : ""
    });
};
