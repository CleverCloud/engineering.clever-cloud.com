all: build

build: 
	jekyll build

preview: 
	jekyll serve

publish: build
	git add .
	git stash save
	git checkout publish || git checkout --orphan publish
	find . -maxdepth 1 ! -name '.' ! -name '.git*' ! -name '_site' -exec rm -rf {} +
	find _site -maxdepth 1 -exec mv {} . \;
	rmdir _site
	git add -A && git commit -m "Publish" || true
	git push -f git+ssh://git@push.clever-cloud.com/app_35819e07-9134-4e79-9bb2-8c595fd5a275.git \
	    publish:master
	git checkout master
	git clean -fdx
	git stash pop || true
