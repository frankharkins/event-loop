install: # Install everything needed to build this project
	mkdir -p .bin

	echo "Installing elm..."
	curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz
	gunzip elm.gz
	chmod +x elm
	mv elm .bin/

	npm install uglify-js --global
	npm install minify --global

run: # Build the site
	(cd frontend && ../.bin/elm make src/Main.elm --output=main.js)

build: # Build and optimize for production
	rm -rf frontend/build
	mkdir frontend/build

	(cd frontend && ../.bin/elm make src/Main.elm --output=main.js --optimize)
	uglifyjs frontend/main.js --compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output frontend/build/main.js
	minify frontend/index.html > frontend/build/index.html
	minify frontend/main.css > frontend/build/main.css

deploy:
	gh workflow run "deploy.yml"
