# Create new repository
# Go to https://github.com/new

# Create SSH Key
ssh-keygen -t ed25519 -C "your_email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

cat ~/.ssh/id_ed25519.pub
# Then in GitHub: Settings → SSH and GPG keys → New SSH key → paste.
git remote set-url origin git@github.com:USERNAME/REPO.git
ssh -T git@github.com

git clone git@github.com:USERNAME/REPO.git

###################################################################

git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"


# Create first file
echo "# My Project" > README.md

# Check git status (untracked file)
git status

# Start tracking the file
git add README.md
git status

# First commit
git commit -m "Add README"

# View commit history
git log --oneline --decorate

# Modify a file
echo "This project is used to learn Git." >> README.md

# See what changed
git diff

# Stage and commit the change
git add README.md
git commit -m "Add project description"

# Create and switch to a new branch
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

git push -u origin main
