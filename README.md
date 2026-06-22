# QR Manager — Dynamic QR Code Management Application

A web application that lets you create and manage dynamic QR codes. Unlike static QR codes, these can be updated at any time without reprinting — just change the destination URL in the admin panel.

## Live Application

**URL:** https://qrmanager-production.up.railway.app

## *Admin Login:** ##

- Email: admin@example.com
- Password: password123

**Test a redirect/qr_code:** https://qrmanager-production.up.railway.app/q/FIRST_SAMPLE_QR_LINKED_TO_MY_GIT_PROFILE

The live URL above will always work for anyone, on any device, anywhere in the world — no setup required. This is the version to use if you simply want to see and use the working application.

## Features

- Create, edit, and delete QR codes via admin panel
- Dynamic redirects — change destination URL anytime without reprinting
- QR code image generation and PNG download
- Scan tracking — records IP address, user agent, referrer, and timestamp for every scan
- Browser/device parsing — scan history shows readable browser and device names instead of raw user agent strings
- Paginated scan history — scans are paged (5 per page) instead of loading every scan at once, with navigation controls styled to match the rest of the app
- Search QR codes by name
- Activate/deactivate QR codes
- Archive/restore QR codes — soft delete with a dedicated archive view, fully restorable
- Basic scan analytics by day (bar chart on detail page)
- Mobile responsive UI — system-ui font, consistent button styling, fully tested and working on phone portrait, phone landscape, and desktop
- Rate limiting — protects the admin login from brute-force attempts and the public QR redirect links from scripted abuse
- Forgot password / email-based password reset — sends a real reset link to the admin's actual registered email via Resend, so only someone with access to that real inbox can ever reset the account password
- Dockerized — runs locally with either Ruby 3.3.4 or Ruby 4.0.2
- 404 handling for invalid or inactive slugs

## Tech Stack

| Technology | Purpose |
|-----------|---------|
| Ruby 4.0.2 / 3.3.4 | Programming language |
| Ruby on Rails 8 | Web framework |
| PostgreSQL | Database |
| Devise | Admin authentication |
| rqrcode | QR code image generation |
| useragent | Browser/device parsing for scan analytics |
| pagy | Pagination for scan history |
| rack-attack | Rate limiting / throttling |
| Resend | Transactional email delivery for password reset links |
| RSpec | Automated testing |
| Docker / Docker Compose | Local containerized environment |
| Railway | Production deployment |

## Run Locally with Docker (Recommended)

This is the easiest way to run the full application — including the database — on your own machine, without installing Ruby, Rails, or PostgreSQL directly.

### Prerequisites
- Docker and Docker Compose installed

### Steps

```bash
git clone https://github.com/ryanweitz22/qr_manager.git
cd qr_manager
./run.sh
```

You will be prompted:

```
Which Ruby version would you like to run locally?
Type 3.3.4 or 4.0.2 and press Enter:
```

Type either `3.3.4` or `4.0.2` and press Enter. Docker will build and start the application using that exact Ruby version inside an isolated container, alongside its own PostgreSQL database.

Once it says `Listening on http://0.0.0.0:3000`, open a second terminal and run the database setup (first run only):

```bash
docker compose exec web bin/rails db:create db:migrate db:seed
```

Then visit **http://localhost:3000** in your browser.

Login with admin@example.com / password123

### Important note about QR codes when running locally

When run locally via Docker, any QR code you create will encode a `localhost:3000` URL. This works only on the machine it was generated on — `localhost` always refers to "this computer" and can never be scanned successfully by someone else's phone, anywhere else. This is true for all local development environments, not specific to this app. To get a QR code that works for anyone, anywhere, use the live Railway deployment above — that is the only version with a real public address.

## Run Locally Without Docker

### Prerequisites
- Ruby 3.3.4 (or 4.0.2 — see note below)
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

### Running on Ruby 4.0.2 without Docker

```bash
rbenv install 4.0.2
rbenv local 4.0.2
sed -i 's/ruby "3.3.4"/ruby "4.0.2"/' Gemfile
bundle install
rails server
```

### Why two Ruby version options?

The original specification required Ruby 4.0.2. I built and tested the application on Ruby 4.0.2 locally and confirmed it runs correctly, including inside Docker (Ruby 4.0.2 requires the `libyaml-dev` system package to build the `psych` gem's native extension — this is included in the Dockerfile). However, no free deployment platform currently supports Ruby 4.0.2, since it was only released in March 2026. For that reason, the live Railway deployment runs on Ruby 3.3.4. The Docker setup lets you choose either version to run and inspect locally, while the live link always reflects the actual production environment (3.3.4).

## Running Tests

```bash
bundle exec rspec --format documentation
```

21 examples, 0 failures, 1 pending.

## How Dynamic QR Codes Work

1. Admin creates a QR code with a destination URL
2. App generates a QR image encoding `your-app.com/q/slug`
3. User scans the QR code — hits the app first
4. App records the scan, then redirects to the destination
5. Admin can change the destination at any time
6. Same printed QR code, new destination — no reprinting needed

## Forgot Password / Email Reset

The admin login includes a standard Devise "forgot password" flow. Entering a
registered email sends a real reset link via Resend (a transactional email
API) to that email address. Only someone with access to the actual registered
inbox can ever complete the reset, since the link is only ever delivered
there — the admin password itself is also stored encrypted in the database,
so it's never visible to anyone, including the app owner.

Email delivery for this app specifically goes through Resend's API rather
than direct SMTP (e.g. Gmail's mail servers), because Railway's hosting
network does not allow outbound SMTP connections at all, on any port — this
was confirmed directly by testing real send attempts on both port 587 and
465 and getting a connection timeout both times, regardless of how the
mailer was configured. Resend sends mail over a normal HTTPS request instead
of SMTP, which isn't blocked the same way.

## Rate Limiting

The app uses the `rack-attack` gem to throttle three categories of traffic:

- **Login attempts** — 5 attempts per 20 seconds, keyed on the submitted email
  address. This protects the admin login from automated password-guessing.
  It is keyed on email rather than IP address, since IP-based throttling did
  not reliably trigger when tested on the live Railway deployment — some
  requests from the same client arrived from different source IPs through
  Railway's edge network, which a pure IP-based rule could miss.
- **Public QR redirect links** (`/q/*`) — 60 requests per minute per IP. This
  allows normal scanning activity through while limiting scripted attempts to
  inflate scan counts.
- **General traffic** — 300 requests per 5 minutes per IP, as a baseline
  safety net against any other kind of automated abuse.

Requests that exceed a limit receive an HTTP 429 response.

## Deployment

Deployed on Railway with a linked PostgreSQL service. Auto-deploys on every
push to the main branch.

The project was originally running on Railway's free trial. The trial fully
expired partway through this project and paused all deployments, taking the
live link down independently of any application code. I upgraded to Railway's
paid Hobby plan to keep the live submission link working and stable going
forward. This is a small recurring cost on my end, so depending on timing
relative to this submission being reviewed, the subscription may be
cancelled before its next billing cycle — if the live link is ever down for
that reason rather than an application issue, the full codebase, README, and
local/Docker setup instructions above are all still complete and runnable
independently of Railway specifically.

## Assumptions and Notes

The specification listed Ruby 4.0.2. I installed Ruby 4.0.2 locally using rbenv, updated the Gemfile, ran bundle install, and confirmed the application runs perfectly on Ruby 4.0.2 on my local machine, including inside a Docker container (after adding the `libyaml-dev` system dependency required by the `psych` gem on this Ruby version). The only reason 3.3.4 is used in production is that Railway's build servers — in fact no free deployment platform — currently supports Ruby 4.0.2, as it was only released in March 2026. The Gemfile and Dockerfile both default to Ruby 3.3.4 for deployment compatibility, but the application is fully tested and confirmed working on Ruby 4.0.2 as originally specified, both directly and inside Docker.

Mobile responsiveness was tested on a real iPhone 14 Plus in both portrait and landscape orientation, and on a full desktop browser window. Tablet behaviour has not been physically tested (no tablet device was available), but both tablet portrait and landscape widths fall above the 600px breakpoint used throughout the CSS, so tablets should receive the same desktop-style layout already confirmed working from phone-landscape width upward — this is a reasoned inference based on the CSS, not a confirmed test.

## RECOMMENDED:
Please Open the Word version of the Documentation_QR_Manager in word then view in web Layout for efficiency/time saving, easy scroll through and better feel, however PDF Will be attached for portrait viewing.