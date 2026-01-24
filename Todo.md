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
- [ ] Migrate the following panels:
  - [ ] Navigation
    - [ ] Announcements
    - [ ] Assignments
    - [ ] Collaborations
    - [x] Contests
    - [x] Contest Winners
    - [ ] Custom Mails
    - [ ] Featured Circuits
    - [ ] Forum Categories
    - [ ] Forum Posts
    - [ ] Forum Subscriptions
    - [ ] Forum Threads
    - [ ] Grades
    - [ ] Groups
    - [ ] Group Members
    - [ ] Issue Circuits Data
    - [ ] Noticed Notifications
    - [ ] Pending Invitations
    - [ ] Projects
    - [ ] Project Data
    - [ ] Push Subscriptions
    - [ ] Stars
    - [x] Submission
    - [x] Submission Votes
    - [ ] Tags
    - [ ] Taggings
    - [x] Users

  - [ ] ActiveStorage
    - [ ] Attachments
    - [ ] Blobs
    - [ ] Variant Records

  - [ ] Commontator
    - [ ] Comments
    - [ ] Subscriptions
    - [ ] Threads

  - [ ] Ahoy
    - [ ] Events
    - [ ] Visits

  - [ ] Mailkick
    - [ ] Opt Outs

  - [ ] Maintenance Tasks
    - [ ] Runs

- [ ] Migrate site administration
- [ ] Add test files (optional)


