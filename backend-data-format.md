# ExamEase: Frontend Implementation Guide & API Documentation

This document is the definitive guide for integrating with the ExamEase backend. It contains detailed entity models, request/response schemas, and step-by-step logic for complex flows.

---

## 1. Global Standards

### 1.1 Base URL & Authentication
- **Development**: `http://localhost:5000/api/v1`
- **Production**: `https://api.examease.com/v1`
- **Headers**:
  - `Authorization`: `Bearer <accessToken>`
  - `Content-Type`: `application/json`

### 1.2 Response Wrappers

#### **Standard Object Response**
Used for single entity fetches (e.g., Get Profile).
```typescript
interface ApiResponse<T> {
  status: boolean;
  data: T;
  message: string;
}
```

#### **Paginated List Response**
Used for all collection fetches.
```typescript
interface ApiListResponse<T> {
  status: boolean;
  data: {
    totalSize: number; // Total items in DB
    pageSize: number;  // Total pages available
    page: number;      // Current page
    perPage: number;   // Items per page
    data: T[];         // Array of entities
  };
  message: string;
}
```

---

## 2. Common Entity Models (Interfaces)

```typescript
// Roles & Constants
enum UserRole { ADMIN = 'ADMIN', USER = 'USER' }
enum ContentType { PDF = 'PDF', VIDEO = 'VIDEO', MOCK_TEST = 'MOCK_TEST', NOTE = 'NOTE' }
enum AccessType { FREE = 'FREE', PAID = 'PAID' }
enum PaymentStatus { PENDING = 'PENDING', SUCCESS = 'SUCCESS', FAILED = 'FAILED' }

interface User {
  id: string;
  name: string;
  email: string;
  phone: string;
  role: UserRole;
  isBlocked: boolean;
  purchasedItems: string[]; // Array of Module IDs
  createdAt: string;
}

interface Exam {
  id: string;
  title: string;
  slug: string;
  description: string;
  icon: string;
  bannerImage: string;
  themeColor: string;
  isActive: boolean;
}

interface Module {
  id: string;
  examId: string;
  title: string;
  description: string;
  thumbnail: string;
  price: number;
  discountPrice: number;
  accessType: AccessType;
  isBundle: boolean;
  includedModules: string[];
  validityDays: number; // 0 = Lifetime
}

interface Content {
  id: string;
  moduleId: string;
  contentType: ContentType;
  title: string;
  description: string;
  data: any; // See Content Data section below
  orderIndex: number;
}
```

---

## 3. Module Deep-Dive

### 3.1 Authentication (`/auth`)

#### **User Registration**
- **Route**: `POST /auth/register`
- **Payload**:
  ```json
  { 
    "name": "string",
    "email": "string",
    "phone": "string", 
    "password": "string (min 6 chars)" 
  }
  ```
- **Response**: `ApiResponse<{ user: User, accessToken: string, refreshToken: string }>`

#### **User Login**
- **Route**: `POST /auth/login`
- **Payload**: `{ "email": "string", "password": "string" }`
- **Response**: `ApiResponse<{ user: User, accessToken: string, refreshToken: string }>`

---

### 3.2 Contents Engine (`/contents`)

#### **Fetch All Contents**
- **Route**: `GET /contents/all`
- **Query Params**:
  - `page`: number
  - `limit`: number
  - `search`: search string
  - `moduleId`: string (Required filter)
  - `contentType`: `PDF | VIDEO | MOCK_TEST | NOTE`
- **Response**: `ApiListResponse<Content>`

#### **Content Data Objects (`content.data`)**
The `data` field varies based on `contentType`:
- **PDF**: `{ "fileUrl": "url string" }`
- **VIDEO**: `{ "s3Key": "string" }` (Use `/videos/stream/:id` to get URL)
- **NOTE**: `{ "content": "markdown/html string" }`
- **MOCK_TEST**:
  ```json
  {
    "durationMinutes": 60,
    "totalMarks": 100,
    "negativeMark": 0.25,
    "questionCount": 50
  }
  ```

---

### 3.3 Payments Flow (`/payments`)

1. **Create Order**: `POST /payments/create-order` -> `{ "moduleId": "string" }`
   - Returns Razorpay `orderId` and `amount`.
2. **Verify Payment**: `POST /payments/verify-payment`
   - Payload:
     ```json
     {
       "orderId": "string",
       "paymentId": "string",
       "signature": "string"
     }
     ```

---

### 3.4 Mock Test Execution (`/test-sessions`)

1. **Start Session**: `POST /test-sessions/start` -> `{ "mockTestId": "string" }`
   - Returns a `sessionId` (String ID). Use this for submission.
2. **Submit Test**: `POST /test-sessions/:sessionId/submit`
   - **Payload**:
     ```json
     {
       "answers": [
         { "questionId": "string", "selectedOptionIndex": 0, "timeTakenSeconds": 10 }
       ]
     }
     ```
   - **Response**: `ApiResponse<{ score: number, accuracy: number, timeTaken: number }>`

---

### 3.5 Questions Module (`/questions`)

#### **Fetch Test Questions**
- **Route**: `GET /questions/test/:contentId`
- **Response**: `ApiResponse<Question[]>`

#### **Question Entity Model**
```typescript
interface Question {
  id: string;
  mockTestId: string;
  questionText: string;
  questionImage?: string;
  options: {
    text: string;
    image?: string;
    isCorrect: boolean;
  }[];
  explanation?: string;
  marks: number;
  negativeMarks: number;
  difficultyLevel: 'EASY' | 'MEDIUM' | 'HARD';
}
```

#### **Bulk Create Questions**
- **Route**: `POST /questions/bulk`
- **Payload**: `Question[]` (sans id)

---

## 4. Admin Management Reference

| Route | Method | Payload | Description |
| :--- | :--- | :--- | :--- |
| `/exams` | `POST` | `Exam` (sans id) | Create new exam category |
| `/modules` | `POST` | `Module` (sans id)| Create course module |
| `/contents` | `POST` | `Content` (sans id)| Upload content meta |
---

## 5. Advanced Features & Global Logic

### 5.1 Search & Filtering Syntax
Most collection endpoints (Exams, Modules, Contents, users) support dynamic querying.

- **Pagination**: `?page=1&limit=10`
- **Search**: `?search=term` (Matches title and description fields).
- **Status Filtering**: `?isActive=true` (Boolean).
- **Relational Filtering**:
  - `?moduleId=<id>` (Filter contents by module).
  - `?examId=<id>` (Filter modules by exam).
- **Price Filtering** (Modules only):
  - `?minPrice=100&maxPrice=1000`

### 5.2 Ads Module (`/ads`)
Used for displaying banners in the mobile app.

- **Route**: `GET /ads/active`
- **Entity Model**:
  ```typescript
  interface Ad {
    id: string;
    title: string;
    imageUrl: string;
    videoUrl?: string; // For video banners
    clickUrl?: string; // Redirect URL
    placement: 'HOME_BANNER' | 'MODULE_LIST';
    orderIndex: number;
  }
  ```

### 5.3 System Config (`/app-config`)
Dynamic flags for maintenance and versioning.

- **Route**: `GET /app-config`
- **Entity Model**:
  ```typescript
  interface AppConfig {
    maintenanceMode: boolean;
    androidVersion: string;
    iosVersion: string;
    forceUpdate: boolean;
    appMessages: {
      maintenance: string;
      update: string;
    }
  }
  ```

### 5.4 Analytics (`/analytics`)
Metrics for the Admin Dashboard.

- **Stats**: `GET /analytics/stats`
  - Returns: `{ totalUsers: number, totalExams: number, totalRevenue: number, activeSessions: number }`
- **Revenue**: `GET /analytics/revenue`
  - Returns: `Array<{ _id: "YYYY-MM-DD", amount: number }>` (Last 7 days).

---

## 6. Development Tips

- **S3 Media**: For videos, always fetch the presigned URL via `/videos/stream/:id`. These URLs are temporary and should not be cached permanently.
- **Cache Invalidation**: The backend uses Redis. If an Admin update doesn't reflect immediately, check the `Cache-Control` headers or use a hard refresh.
- **Error Handling**: Standardize on checking `status === false` and displaying the `message` string to the user.
