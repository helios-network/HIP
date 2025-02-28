sed -i -e 's/book\//book-tmp/g' ./.gitignore
rm -f .gitignore-e
git add book && git commit -m "Deploy - Book https://helios-network.github.io/HIP"
git subtree push --prefix book origin gh-pages --force
git checkout HEAD~1