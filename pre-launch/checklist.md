# Pre-launch checklist

Each line is a thing that must be true before a paying customer touches the app.

## 1. Identity and access

- [ ] A schema someone designed, not one the AI improvised table by table
- [ ] Login works when a user puts a plus sign in their email
- [ ] Password reset links expire and work once
- [ ] MFA, plus a recovery path for the user who lost their phone
- [ ] Sessions time out, and one action kills every session for one user
- [ ] SSO for the enterprise customer who will not sign without it
- [ ] SAML, because that customer's IT team does not use magic links
- [ ] SCIM, so a fired employee loses access when IT offboards them
- [ ] Roles and permissions deeper than "admin" and "everyone else"
- [ ] Checks that stop user A from reading user B's data by changing one number in the URL
- [ ] Tenant isolation, so one customer's bug never shows another customer's records
- [ ] Admin "log in as this user" button for support, with an audit trail on every use
- [ ] Rate limits on login
- [ ] Lockouts that stop attackers without locking out a legitimate user at a bad moment

## 2. Database

- [ ] Migrations run forward and roll back
- [ ] Migrations do not lock the main table during business hours
- [ ] Indexes exist, so the query that was fast on 50 rows works on 5 million
- [ ] Connection pooling, so a traffic spike does not exhaust the database
- [ ] Nightly backups
- [ ] A restore from those backups, tested
- [ ] Point-in-time recovery, for a delete without a where clause
- [ ] Soft deletes, so "deleted by accident" is a support ticket and not an incident
- [ ] Data model survives the second customer asking for "one small change"
- [ ] Retention rules, and code that deletes what the contract says it will delete

## 3. Data correctness

- [ ] Validation on the server, not only in the form
- [ ] Timezones stored right, so the 9am reminder does not fire at 4am
- [ ] The customer with an apostrophe in the last name works
- [ ] Emoji, accents and right-to-left text work in every field
- [ ] Money stored as integers
- [ ] Currency, rounding and tax rules for every country sold into
- [ ] Idempotency keys, so a retried payment does not charge twice
- [ ] Deduplication for the user who clicks submit four times
- [ ] Pagination works on page 400
- [ ] Exports, so a customer can get their data in a spreadsheet
- [ ] Imports survive a CSV saved in 2009

## 4. Application security

- [ ] Secrets out of the code, out of the repo and out of the AI chat history
- [ ] Every key the AI pasted into a config file is rotated
- [ ] Every package the AI installed exists and is the one intended
- [ ] Dependency scanning
- [ ] Input sanitization everywhere a user can type
- [ ] Protection against SQL injection, XSS, CSRF and the rest of the OWASP list
- [ ] File uploads are scanned, size-limited and stored where they cannot execute
- [ ] CORS rules are not "allow everything"
- [ ] Security headers on every response
- [ ] Encryption at rest and in transit
- [ ] Least-privilege access for everyone, including the AI agent holding production credentials
- [ ] Logs record who did what, without passwords, tokens or card numbers

## 5. Security process

- [ ] A penetration test before the enterprise customer's security team runs their own
- [ ] Answers to the security questionnaire every enterprise buyer sends, with evidence for each
- [ ] A disclosure process for the day a stranger emails a vulnerability
- [ ] A plan for the day a laptop with production access is stolen

## 6. Compliance

- [ ] SOC 2: policies, evidence and an auditor, not a checkbox
- [ ] HIPAA, the moment one patient record touches the system
- [ ] A BAA with every vendor that touches that data, including the AI model provider
- [ ] Audit trails that show who viewed a record, not only who changed it
- [ ] PCI scope defined, and card numbers kept out of the database
- [ ] GDPR deletion requests reach every table, backup and log
- [ ] Data residency for the customer whose contract says EU only
- [ ] Quarterly access reviews that someone signs off
- [ ] Terms and a privacy policy that match what the code does

## 7. Environments and deploys

- [ ] Dev, staging and production environments match each other
- [ ] Infrastructure written as code
- [ ] A deploy pipeline that runs the tests before anything reaches customers
- [ ] One-click rollbacks
- [ ] Zero-downtime deploys
- [ ] Feature flags, so code ships without the feature
- [ ] Autoscaling for the Monday morning spike
- [ ] A CDN, so the app loads fast in far regions
- [ ] DNS and SSL certificates, with renewals that do not expire on a Sunday

## 8. Background work and email

- [ ] Background job queues, so slow work does not freeze the page
- [ ] Retries with backoff
- [ ] A dead-letter queue for jobs that fail every retry
- [ ] Cron jobs do not run twice when a second server is added
- [ ] Caching, and clearing the cache when data changes
- [ ] SPF, DKIM and DMARC, so password resets do not land in spam
- [ ] Bounce and complaint handling on every transactional email
- [ ] Storage rules, so old temp files stop costing money

## 9. Cost and resilience

- [ ] Cost alerts, so a runaway agent loop shows up the same day
- [ ] A disaster recovery plan, written down and tested once a year
- [ ] A second region, if the contract promises uptime one region cannot deliver

## 10. Observability and operations

- [ ] Structured logs that can be searched at 3am
- [ ] Error tracking that groups the same bug
- [ ] Uptime checks from outside the network
- [ ] Alerts that page a human, tuned until they stop paging for nothing
- [ ] Dashboards for latency, error rate and throughput
- [ ] Tracing for one slow request across every service
- [ ] An on-call rotation, and a person who picks up
- [ ] Runbooks, so the engineer on call knows what "queue depth critical" means
- [ ] Postmortems that change something
- [ ] A status page customers check before they email

## 11. Testing

- [ ] Unit tests written by someone who knows what the logic should do
- [ ] Integration tests for every third-party API in use
- [ ] End-to-end tests for signup, checkout and the other flows that make money
- [ ] Load testing before the launch email goes out
- [ ] Test data that looks like production without being production data
- [ ] Regression tests, so fixing bug 41 does not bring back bug 12
- [ ] Testing on the old laptop the biggest customer's ops team still uses
- [ ] Accessibility compliance, because the enterprise contract requires it

## 12. Billing

- [ ] Subscriptions, upgrades, downgrades and proration
- [ ] Failed-payment retries and dunning emails
- [ ] Invoices with the customer's PO number
- [ ] Sales tax and VAT
- [ ] Refunds, credits and partial refunds
- [ ] Usage metering that matches the bill, to the cent
- [ ] Annual contracts with custom terms the billing logic did not plan for
- [ ] Revenue reports that finance can reconcile

## 13. API and integrations

- [ ] Webhooks verify signatures
- [ ] Webhooks retry, with a log of every failed delivery
- [ ] A versioned API
- [ ] API keys that customers can create and revoke
- [ ] API rate limits that protect the service without blocking real integrations
- [ ] A plan for the day a third-party API changes its response format
- [ ] OAuth token refresh
- [ ] A sandbox where customers can test their integration

## 14. AI features

- [ ] Protection against prompt injection in every field that reaches the model
- [ ] Customer and patient data kept out of prompts that leave the network
- [ ] A model spend cap per customer
- [ ] Evals, so a model update that makes answers worse is detected
- [ ] A fallback for the day the model provider goes down
- [ ] A migration plan for the day the model is deprecated
- [ ] Prompt and output logs for debugging, minus whatever the contract forbids keeping
- [ ] A human approval step for anything the AI does that cannot be undone

## 15. Product experience

- [ ] Pages that load on hotel wifi
- [ ] Empty, loading and error states on every screen
- [ ] Error messages a customer can act on
- [ ] Forms keep what people typed when one field fails validation
- [ ] Emails render in every mail client the customers use
- [ ] Notifications people can turn off
- [ ] Undo
- [ ] Keyboard navigation and screen reader support
- [ ] Translations, with dates and numbers formatted for each locale
- [ ] A back button that does what people expect
- [ ] A changelog customers can read

## 16. Code health and ownership

- [ ] Code a human can read
- [ ] Code review on every change
- [ ] A branching strategy, so two people do not overwrite each other
- [ ] Monthly dependency upgrades
- [ ] Framework upgrades before the old version stops getting security patches
- [ ] Dead code from the AI's first attempts is deleted
- [ ] The 2,000-line file the AI kept appending to is split
- [ ] Architecture decisions written down, with the reasons
- [ ] A README that gets a new engineer running locally in under an hour
- [ ] Documentation for whoever inherits the app
- [ ] An admin panel for the ops team
- [ ] Support tooling, so customer success can answer questions without engineering
- [ ] Every account, domain and repo in the company's name, not the name of whoever built the prototype
- [ ] A bus factor higher than one

## 17. People the app still needs

Items here stay `UNKNOWN` unless the repo or Ishan names a person.

- [ ] Someone reads every line the AI wrote before it ships (senior engineer)
- [ ] Someone designs the data model before the second customer breaks it (backend engineer)
- [ ] Someone explains why the AI's fix for one bug created two new ones (senior engineer)
- [ ] Someone owns deploys, rollbacks, servers and the cloud bill (DevOps engineer)
- [ ] Someone answers the page at 3am when payments stop (on-call)
- [ ] Someone patches the framework the week a vulnerability goes public (security)
- [ ] Someone walks an auditor through how patient data moves (security and compliance)
- [ ] Someone tests what the AI says it tested (QA)
- [ ] Someone runs a migration on a live database without losing a row (backend engineer)
- [ ] Someone says no to the feature that breaks three others (tech lead)
- [ ] Someone turns "works on my laptop" into "works for every customer at once" (architect)
- [ ] Someone debugs the code when the AI that wrote it cannot (senior engineer)
- [ ] Someone remembers why it is built this way, a year from now (someone who was there)
