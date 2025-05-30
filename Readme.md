# Cloud Resume Challenge – Serverless AWS Web Application

This project is my implementation of the [Cloud Resume Challenge](https://cloudresumechallenge.dev/), a popular challenge that demonstrates end-to-end cloud skills by building a fully serverless web application to host a personal resume with a live visitor counter.

---

## Project Overview

A resume website hosted on AWS, integrated with a real-time visitor counter backed by serverless infrastructure, CI/CD automation, and Infrastructure as Code.

---

## Architecture

- **Frontend**: Static website built with HTML, CSS, and JavaScript.
  - Hosted on **Amazon S3**.
  - Delivered globally and securely via **CloudFront CDN** with **HTTPS** enabled through **AWS Certificate Manager (ACM)**.

- **Backend**: 
  - Built using **AWS Lambda** (Python) and **DynamoDB** to count and persist website visitors.
  - Lambda Function exposed using **Lambda Function URL**, eliminating the need for API Gateway.

- **CI/CD Automation**:
  - **Jenkins** pipeline automates backend deployments using Github webhook.

- **Infrastructure as Code**:
  - Entire AWS architecture provisioned using **Terraform**, ensuring reproducibility and version control.

- **Monitoring & Logging**:
  - **CloudWatch Logs** enabled for Lambda function for operational insight.

- **Domain & DNS**:
  - Custom domain (`balaji.website`) managed through **Route 53**.

---

## Tools and Implementation

| Frontend Hosting -> Amazon S3 + CloudFront |

| TLS/SSL          -> AWS ACM                |

| Visitor Counter  -> AWS Lambda + DynamoDB  |

| CI/CD            -> Jenkins                |

| IaC              -> Terraform              |

| Logging          -> CloudWatch Logs        |

| Domain Management -> Route 53              |


---


*Note:Inspired by the [Cloud Resume Challenge](https://cloudresumechallenge.dev/) by Forrest Brazeal. This project was a great opportunity to demonstrate full-stack serverless development with real-world cloud tooling.*