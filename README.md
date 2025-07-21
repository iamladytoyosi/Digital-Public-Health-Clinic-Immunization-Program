# Digital Public Health Clinic Immunization Program

A comprehensive blockchain-based system for managing public health immunization programs using Clarity smart contracts on the Stacks blockchain.

## System Overview

This system consists of five interconnected smart contracts that manage different aspects of a public health immunization program:

### 1. Vaccine Inventory Management (`vaccine-inventory.clar`)
- Tracks vaccine supplies and stock levels
- Monitors expiration dates and batch information
- Manages vaccine allocation and distribution
- Handles low stock alerts and reorder notifications

### 2. Appointment Scheduling (`appointment-scheduler.clar`)
- Manages immunization clinic bookings
- Handles appointment slots and availability
- Tracks patient appointment history
- Supports appointment modifications and cancellations

### 3. Record Keeping (`vaccination-records.clar`)
- Maintains comprehensive patient vaccination history
- Stores vaccine administration details
- Tracks immunization schedules and due dates
- Provides vaccination status verification

### 4. School Compliance (`school-compliance.clar`)
- Ensures students meet immunization requirements
- Tracks school-specific vaccination mandates
- Generates compliance reports
- Manages exemption requests and approvals

### 5. Insurance Billing (`insurance-billing.clar`)
- Processes vaccine administration claims
- Manages insurance provider information
- Tracks billing status and payments
- Handles claim disputes and adjustments

## Key Features

- **Decentralized Data Management**: All records stored on blockchain for transparency and immutability
- **Privacy Protection**: Patient data encrypted and access-controlled
- **Automated Compliance**: Smart contract enforcement of vaccination requirements
- **Real-time Inventory**: Live tracking of vaccine supplies and expiration dates
- **Streamlined Billing**: Automated insurance claim processing
- **Audit Trail**: Complete transaction history for regulatory compliance

## Data Types

### Patient Information
- Patient ID (unique identifier)
- Personal details (name, DOB, contact info)
- Medical history and allergies
- Insurance information

### Vaccine Data
- Vaccine type and manufacturer
- Batch numbers and lot information
- Expiration dates
- Storage requirements
- Dosage information

### Appointment Data
- Appointment ID and scheduling details
- Patient and provider information
- Vaccine type and administration details
- Status tracking (scheduled, completed, cancelled)

## Security Features

- Role-based access control
- Data encryption for sensitive information
- Multi-signature requirements for critical operations
- Audit logging for all transactions
- Compliance with HIPAA and health data regulations

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm
- Stacks wallet for testing

### Installation
1. Clone the repository
2. Install dependencies: `npm install`
3. Run tests: `npm test`
4. Deploy contracts: `clarinet deploy`

### Testing
The system includes comprehensive test suites for each contract:
- Unit tests for individual functions
- Integration tests for contract interactions
- Edge case and error handling tests

## Usage Examples

### Adding Vaccine Inventory
\`\`\`clarity
(contract-call? .vaccine-inventory add-vaccine-batch
"COVID-19" "Pfizer" "LOT123" u1000 u1640995200)
\`\`\`

### Scheduling Appointment
\`\`\`clarity
(contract-call? .appointment-scheduler schedule-appointment
u1 "COVID-19" u1641081600)
\`\`\`

### Recording Vaccination
\`\`\`clarity
(contract-call? .vaccination-records record-vaccination
u1 "COVID-19" "LOT123" u1641081600)
\`\`\`

## Compliance and Regulations

This system is designed to comply with:
- CDC immunization guidelines
- State and local health department requirements
- HIPAA privacy regulations
- School district vaccination mandates
- Insurance billing standards

## Support and Documentation

For detailed API documentation, deployment guides, and troubleshooting:
- See individual contract documentation
- Review test files for usage examples
- Check PR-DETAILS.md for implementation specifics

## License

This project is licensed under the MIT License - see the LICENSE file for details.
