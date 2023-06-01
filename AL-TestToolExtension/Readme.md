# Zeigt das letzt gemeinsame commit an

https://stackoverflow.com/questions/18407526/git-how-to-find-first-commit-of-specific-branch

git merge-base branch_experiment remotes/origin/develop               
ad22e54fe3990180efb8d43e019a6c5c43e95cf6


# Zeigt alle Änderungen an
git diff ad22e54fe3990180efb8d43e019a6c5c43e95cf6.. -U5000