# mkmobile

Magic Card Market Mobile Client

## Setup

### Requirements

To be able to compile everything and host a local copy of this app, you need:

* [CoffeeScript](http://coffeescript.org/)
* [Bower](http://bower.io/)
* [SASS](http://sass-lang.com/)
* [UglifyJS2](https://github.com/mishoo/UglifyJS2)

### Compiling

You need to install the packages with Bower first:

  bower install
  
Afterwards, you can simply run the `compile.sh` shellscript located in `scripts/`:

  cd scripts
  ./compile.sh

### Running

The web root folder should be mapped to `/app/` and you need HTTP Rewrites for the HTML5 URLs.
For Apache, they look like this:

  RewriteEngine on
  RewriteCond %{REQUEST_FILENAME} -f [OR]
  RewriteCond %{REQUEST_FILENAME} -d
  RewriteRule ^ - [L]
  RewriteRule ^ index.html [L]
  
Similarly, nginx Rules should like something like this:

  location / {
    try_files $uri $uri/ /index.html =404;
  }