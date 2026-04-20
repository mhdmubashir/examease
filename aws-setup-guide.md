# AWS Setup Guide for ExamEase S3 Video Uploads

This document outlines the step-by-step process for configuring your AWS account to support the ExamEase platform's S3 video upload and streaming capabilities.

---

## 1. Create an S3 Bucket

1. Log into the [AWS Management Console](https://console.aws.amazon.com/).
2. Search for **S3** and navigate to the S3 dashboard.
3. Click **Create bucket**.
4. **Bucket name**: e.g., `examease-videos-prod` (Must be globally unique).
5. **AWS Region**: Select the region closest to your users (e.g., `Mumbai ap-south-1`).
6. **Object Ownership**: Leave as "ACLs disabled (recommended)".
7. **Block Public Access settings for this bucket**:
   - Check **Block *all* public access**. 
   - *Why? We use signed URLs. No public access is required or desired.*
8. **Bucket Versioning**: Disable (unless you explicitly need to keep older versions of deleted videos).
9. **Default encryption**: Server-side encryption with Amazon S3 managed keys (SSE-S3).
10. Click **Create bucket**.

---

## 2. Configure CORS for S3

Since the Admin Panel (frontend) uploads directly to S3 via the backend OR if you eventually want direct uploads from the frontend, you need CORS properly configured. Additionally, video players (like the one in Admin Panel and Mobile App) need CORS to stream the video content successfully.

1. Click on your newly created bucket.
2. Go to the **Permissions** tab.
3. Scroll down to **Cross-origin resource sharing (CORS)** and click **Edit**.
4. Paste the following JSON:

```json
[
    {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "GET",
            "PUT",
            "POST",
            "DELETE",
            "HEAD"
        ],
        "AllowedOrigins": [
            "*" 
        ],
        "ExposeHeaders": [
            "ETag",
            "Content-Length"
        ],
        "MaxAgeSeconds": 3000
    }
]
```
*(Note: For strict production, replace `AllowedOrigins: ["*"]` with your specific Admin Panel domain, e.g., `["https://admin.examease.com"]`)*

---

## 3. Create an IAM Policy

We need to create a restrictive policy that limits permissions only to this specific bucket.

1. Search for **IAM** in the AWS console.
2. Go to **Policies** (on the left menu) and click **Create policy**.
3. Choose the **JSON** tab and paste the following, replacing `YOUR_BUCKET_NAME` with the bucket name you created in Step 1:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME/*"
        }
    ]
}
```
4. Click **Next** until you reach Review.
5. **Name**: `ExamEaseS3VideoAccessPolicy`
6. Click **Create policy**.

---

## 4. Create an IAM User

This user will be used specifically by the Node.js backend.

1. In IAM, go to **Users** and click **Create user**.
2. **User name**: `examease-backend-user`.
3. Do NOT check "Provide user access to the AWS Management Console". Click **Next**.
4. Select **Attach policies directly**.
5. Search for the policy you just created (`ExamEaseS3VideoAccessPolicy`) and check the box next to it.
6. Click **Next**, then **Create user**.

---

## 5. Generate Access Keys

1. Click on the `examease-backend-user` you just created.
2. Go to the **Security credentials** tab.
3. Scroll down to **Access keys** and click **Create access key**.
4. Select **Application running outside AWS**.
5. Click **Next**, optionally add a description tag, then click **Create access key**.
6. **IMPORTANT**: Copy the **Access key** and **Secret access key**. This is the ONLY time the secret key will be shown to you.

---

## 6. Update Environment Variables

Now, open your `.env` file in the backend repository and populate it with your AWS details:

```env
# AWS S3
AWS_ACCESS_KEY_ID=YOUR_COPIED_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=YOUR_COPIED_SECRET_KEY
AWS_REGION=ap-south-1 # (or whatever region you selected)
AWS_S3_BUCKET=YOUR_BUCKET_NAME
AWS_S3_PRESIGNED_EXPIRY=3600
```

---

## 7. Next Steps & Production Recommendations

- **CloudFront Integration**: For significantly better video streaming performance and lower data transfer costs, you should put an AWS CloudFront distribution in front of this S3 bucket, and update the backend to generate signed URLs for CloudFront instead of native S3.
- **Transcoding**: Currently, videos are served in their original uploaded format. In the future, look into AWS MediaConvert or Elastic Transcoder to generate HLS (m3u8) streams for adaptive bitrate playback on mobile.
