git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
git config --list

mkdir my-first-repo-0426
git init

# Create first file
echo "# My Project" > README.md
# https://markdownlivepreview.com/

# Check git status (untracked file)
git status

# Start tracking the file
git add README.md
git status
git restore --staged README.md
git add README.md

# First commit
git commit -m "Add README"

# View commit history
git log --oneline --decorate
git show HEAD

# Modify a file
echo "This project is used to learn Git." >> README.md

# See what changed
git diff

# Stage and commit the change
git add README.md
git diff --staged
git commit -m "Add project description"

### Undoing things
# ---- git reset --soft ----
echo "junk" >> scratch.txt
git add scratch.txt
git commit -m "junk to undo"
git reset --soft HEAD~1
git status
#   Changes to be committed:
#         new file:   scratch.txt
#   → commit undone, but the change is still STAGED, ready to re-commit.

# ---- git reset --mixed (the default) ----
git commit -m "junk to undo"      # re-make the junk commit
git reset --mixed HEAD~1          # same as: git reset HEAD~1
git status
#   Untracked files:
#         scratch.txt
#   → commit undone, change KEPT on disk, but UNSTAGED.

# ---- git reset --hard ----
git add scratch.txt && git commit -m "junk to undo"   # re-make it
git reset --hard HEAD~1
git status
#   nothing to commit, working tree clean
#   → commit undone AND scratch.txt is gone from disk entirely. ⚠️

# Create and switch to a new branch
git branch
git switch -c feature/add-notes

# Add a new file on the branch
echo "- Git tracks snapshots, not files" > NOTES.md
git status

git add NOTES.md
git commit -m "Add notes file"

# View full history with branches
git log --oneline --graph --decorate --all

# Switch back to main branch
git switch main

# Merge feature branch into main
git merge feature/add-notes

# (Optional) Delete merged branch
git branch -d feature/add-notes

# Create a file that should be ignored
mkdir build
echo "temporary build output" > build/output.txt

# Ignore build directory
echo "build/" > .gitignore
git status

git add .gitignore
git commit -m "Add .gitignore"

# 13) Show clean status
git status

###################################################################
# Create new repository
# Go to https://github.com/new

# Create SSH Key
ssh-keygen -t ed25519 -C "your_email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

cat ~/.ssh/id_ed25519.pub
# Then in GitHub: Settings → SSH and GPG keys → New SSH key → paste.

ssh -T git@github.com

git remote add origin git@github.com:USERNAME/REPO.git
git remote -v   
###################################################################

git push -u origin main

# --- Create tags ---
git tag v1.0.0                          # lightweight: just a name pointing at HEAD
git tag -a v1.0.0 -m "Release 1.0.0"    # annotated (preferred for releases): stores tagger, date, and a message

# --- List & inspect ---
git tag                                 # list all tags
git tag -l "v1.*"                       # filter by pattern
git show v1.0.0                         # show the tag's metadata + the commit it points to

# --- Push tags (NOT pushed by 'git push' on its own) ---
git push origin v1.0.0                  # push one specific tag
git push origin --tags                  # push all tags at once

# --- Delete tags ---
git tag -d v1.0.0                       # delete locally
git push origin --delete v1.0.0         # delete on the remote
