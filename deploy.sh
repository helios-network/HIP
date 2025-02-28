sed -i -e 's/book\//book-tmp/g' ./.gitignore
rm -f .gitignore-e
# delete gh-pages
git push origin `git subtree split --prefix book gh-pages`:gh-pages --force
# Add book Commit
git add book && git commit -m "Deploy - Book https://helios-network.github.io/HIP"
# Push Book to gh-pages
git subtree push --prefix book origin gh-pages
# Back to last commit
git checkout HEAD~1