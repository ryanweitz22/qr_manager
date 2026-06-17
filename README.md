# QR Manager — Dynamic QR Code Management Application

A web application that lets you create and manage dynamic QR codes. Unlike static QR codes, these can be updated at any time without reprinting — just change the destination URL in the admin panel.

## Live Application

**URL:** https://qrmanager-production.up.railway.app

**Admin Login:**
- Email: admin@example.com
- Password: password123

**Test a redirect:** https://qrmanager-production.up.railway.app/q/sample-qr

## Features

- Create, edit, and delete QR codes via admin panel
- Dynamic redirects — change destination URL anytime without reprinting
- QR code image generation and PNG download
- Scan tracking — records IP address, user agent, referrer, and timestamp for every scan
- Search QR codes by name
- Activate/deactivate QR codes
- 404 handling for invalid or inactive slugs

## Tech Stack

| Technology | Purpose |
|-----------|---------|
| Ruby 3.3.4 | Programming language |
| Ruby on Rails 8 | Web framework |
| PostgreSQL | Database |
| Devise | Admin authentication |
| rqrcode | QR code image generation |
| RSpec | Automated testing |
| Railway | Production deployment |

## Local Setup

### Prerequisites
- Ruby 3.3.4
- PostgreSQL
- Node.js and Yarn

### Steps

```bash
git clone https://github.com/ryanweitz22/qr_manager.git
cd qr_manager
bundle install
rails db:create db:migrate db:seed
rails server
```

Visit http://localhost:3000 — it redirects to the admin panel automatically.

Login with admin@example.com / password123

## Running Tests

```bash
bundle exec rspec --format documentation
```

21 examples, 0 failures.

## How Dynamic QR Codes Work

1. Admin creates a QR code with a destination URL
2. App generates a QR image encoding `your-app.com/q/slug`
3. User scans the QR code — hits the app first
4. App records the scan, then redirects to the destination
5. Admin can change the destination at any time
6. Same printed QR code, new destination — no reprinting needed

## Deployment

Deployed on Railway with a linked PostgreSQL service. Auto-deploys on every push to the main branch.
