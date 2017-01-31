#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

TARGET_BRANCH="master"
TARGET_REPO="git@github.com:RWTH-i5-IDSG/RWTH-i5-IDSG.github.io"

CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`

# Clone the existing gh-pages for this repo into out/
# Create a new empty branch if gh-pages doesn't exist yet (should only happen on first deply)
git clone $TARGET_REPO out
cd out
git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH
cd ..

# copy docu to target repo
mkdir -p out/ixsi/
cp -aR ixsi-docu.pdf out/ixsi/ixsi-docu-$CURRENT_BRANCH.pdf

# Now let's go have some fun with the cloned repo
cd out
git config user.name "Travis CI"
git config user.email "$COMMIT_AUTHOR_EMAIL"

# Commit the "changes", i.e. the new version.
# The delta will show diffs between new and old versions.
git add ixsi/ixsi-docu-$CURRENT_BRANCH.pdf

echo "Deploy to ${SSH_REPO}: commit ${SHA}"
git commit -m "Deploy IXSI Docu to GitHub pages. Commit ${SHA}"

# Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc
ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in deploy_key.enc -out deploy_key -d
chmod 600 deploy_key
eval `ssh-agent -s`
ssh-add deploy_key

# Now that we're all set up, we can push.
git push $SSH_REPO $TARGET_BRANCH
