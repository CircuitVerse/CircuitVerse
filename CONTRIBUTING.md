[Back to README](README.md)

## Development Process 

## Step 1: Leave a comment on the GitHub issue
When you are ready to start work on a issue:

1. Let us know by leaving a comment on the issue. (Also let us know later if you are no longer working on it.)

## Step 2: Update local repo development branch
Reason: Your **local repo** *master* branch needs to stay in sync with the **project repo** *master* branch.  This is because you want to have your feature branch (to be created below) to have the latest project code before you start adding code for the feature you’re working on.

    git checkout master
    git fetch upstream
    git merge upstream/master

You should not have merge conflicts in step 3, unless you’ve made changes to your local *master* branch directly (which you should not do).

## Step 3: Create the feature branch in your local and github repos
Reason: All of your development should occur in feature branches - ideally, one branch per issue solved.  This keeps your local *master* branch clean (reflecting *upstream* master branch), allows you to abandon development approaches easily if required (e.g., simply delete the feature branch), and also allows you to maintain multiple work-in-process branches if you need to (e.g., work on a feature branch while also working on fixing a critical bug - each in its own branch).

1. Create a branch whose name contains the github issue number. For example, if you are going to work on issue number #44(which is, say, a new feature for ‘forgot password’ management):

        git checkout -b forgot-password#44

    This both creates and checks out that branch in one command.  
    The feature name should provide a (short) description of the issue.

2. Push the new branch to your github repo:

        git push -u origin forgot-password#44

## Step 4: Develop the Feature
Develop the code for your feature (or chore/bug) as usual.  You can make interim commits to your local repo if this is a particularly large feature that takes a lot of time.

When you have completed development, make your final commit to the feature branch in your local repo.

## Step 5: Update local repo **master** branch
This should be done again in case any commits have occurred to the *master* branch in the project repo since you performed step 1.

    git checkout master
    git fetch upstream
    git merge upstream/master

## Step 6: Rebase master changes into feature branch
Now, you will need to rebase changes from the local repo *master* branch into the feature branch.

Reason: This step will add changes to your feature branch that have already been applied to the project repo *master* branch.  The result is that when you deliver your feature (that is, create a Pull Request), those changes will not be (needlessly) included in that Pull Request.

    git checkout <feature-branch-name>
    git rebase master

## Step 7: Push feature branch to your github repo
Reason: You will now push the feature branch code to github so that you can create a Pull Request against the project repo (in next step).

    git checkout <feature-branch-name>
    git push origin <feature-branch-name>

## Step 8: Create Pull Request (PR)
On the github website:

1. Go to your personal repo on Github
2. Select the *master* branch in the “Branch: “ pull-down menu
3. Click the “Compare” link

    On the next page, the “base fork” and “base” should be **CircuitVerse/CircuitVerse** and **master**, respectively.

4. Confirm “head fork: is set to **\<username\>/CircuitVerse**
5. Set “compare: “ to your feature branch name (e.g. *forgot-password*)
6. Review the file changes that are shown and confirm that all is OK.
7. Fill out details of the pull request - title, description, etc.
8. Click “Create Pull Request”
