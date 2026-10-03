# CareVoice — AWS Lex V2 Healthcare Appointment Assistant

CareVoice is a healthcare appointment assistant built using **Amazon Lex V2, AWS Lambda, and Amazon DynamoDB**.

The assistant handles appointment-related conversations such as booking an appointment, checking appointments, providing hospital information, and connecting the user to human assistance.

The project was built with a focus on **serverless architecture, AWS service integration, conversational workflows, and infrastructure management with Terraform**.


## AWS Services Used
- Amazon Lex V2 — conversational interface and intent/slot management
- AWS Lambda — serverless backend and appointment business logic
- Amazon DynamoDB — storage for confirmed appointments
- Amazon CloudWatch — Lambda logging and monitoring
- AWS IAM — Lambda execution permissions and DynamoDB access
- Terraform — infrastructure management and configuration tracking

---

## Architecture

```text
User
  │
  ▼
Amazon Lex V2
  │
  ▼
AWS Lambda — CareVoiceLexHandler
  │
  ├── Appointment business logic
  ├── Doctor / patient reference data
  │
  ▼
Amazon DynamoDB
  │
  └── Appointment records

CloudWatch
  └── Lambda logs and troubleshooting
