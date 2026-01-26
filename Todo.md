# Avo Migration Progress 

This shall be a parallel incremental Migration with existing dashboard

## Proposed Project Structure: 
- all the resources are added in the `app/avo/resources` in the format : (subject to change)
```
app/ 
├── avo/
│   ├── resources/
│   ├── actions/
│   ├── filters/
│   ├── dashboards/         
│   ├── cards/             
│   └── tools/             
│
├── concerns/
│   └── avo/
│       └── authentication.rb
│
└── policies/
    └── avo/
        └── application_policy.rb
```
## Plan : 

### Phase 1 – Core Domain Resources
> These are the highest-value admin features

Resources to migrate (in this order):
- User
- Project
- Group
- Assignment
- Contest

### Phase 2 – Supporting Admin Features
> Now migrate secondary domain models:

- Navigation-level resources
- Announcements
- FeaturedCircuits
- CustomMails
- Tags / Taggings
- Stars
- Collaborations
- Grades

### Phase 3 – Read-Only System & Audit Tables

- Resources (index + show ONLY)
- ActiveStorage
- Blobs
- Attachments
- Ahoy
- Events
- Visits
- Mailkick
- OptOuts
- Commontator
- Threads
- Comments
- Subscriptions
- MaintenanceTasks
- Runs

## TODO:
- [x] Avo installed
- [x] added `admin2` as the route for accessing avo dashboard
- [x] added `app/avo/resources` as the base resources, Authentication wired to `current_user.admin?`
- [x] Migrate the following panels:
  - [x] Navigation
    - [x] Announcements
    - [x] Assignments
    - [x] Collaborations
    - [x] Contests
    - [x] Contest Winners
    - [x] Custom Mails
    - [x] Featured Circuits
    - [x] Forum Categories
    - [x] Forum Posts
    - [x] Forum Subscriptions
    - [x] Forum Threads
    - [x] Grades
    - [x] Groups
    - [x] Group Members
    - [x] Grades
    - [x] Groups
    - [x] Group Members
    - [x] Issue Circuits Data
    - [x] Noticed Notifications
    - [x] Pending Invitations
    - [x] Projects
    - [x] Project Data
    - [x] Push Subscriptions
    - [x] Stars
    - [x] Submission
    - [x] Submission Votes
    - [x] Tags
    - [x] Taggings
    - [x] Users

  - [x] ActiveStorage
    - [x] Attachments
    - [x] Blobs
    - [x] Variant Records

  - [x] Commontator
    - [x] Comments
    - [x] Subscriptions
    - [x] Threads

  - [x] Ahoy
    - [x] Events
    - [x] Visits

  - [x] Mailkick
    - [x] Opt Outs

  - [x] Maintenance Tasks
    - [x] Runs

- [ ] Migrate site administration
- [ ] Add test files (optional)
- [ ] Grouping of the resources according to panels
- [x] Circuitverse themed dashboard
