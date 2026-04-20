export enum UserRole {
    ADMIN = 'ADMIN',
    USER = 'USER',
}

export enum ContentType {
    MOCK_TEST = 'MOCK_TEST',
    PDF = 'PDF',
    NOTE = 'NOTE',
    VIDEO = 'VIDEO',
    PRACTICE_SET = 'PRACTICE_SET',
}

export enum AccessType {
    FREE = 'FREE',
    PAID = 'PAID',
}

export enum PaymentStatus {
    PENDING = 'PENDING',
    SUCCESS = 'SUCCESS',
    FAILED = 'FAILED',
    REFUNDED = 'REFUNDED',
}

export enum AdPlacement {
    HOME_TOP = 'HOME_TOP',
    HOME_MIDDLE = 'HOME_MIDDLE',
    EXAM_LIST = 'EXAM_LIST',
    BANNER_HOME = 'BANNER_HOME',
    BANNER_EXAM = 'BANNER_EXAM',
}

export enum TestSessionStatus {
    ONGOING = 'ONGOING',
    COMPLETED = 'COMPLETED',
    ABANDONED = 'ABANDONED',
}

export enum OrderStatus {
    PENDING = 'PENDING',
    COMPLETED = 'COMPLETED',
    CANCELLED = 'CANCELLED',
}
