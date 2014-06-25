# mkmobile

MagicCardMarket Mobile Client

## Setup

### Requirements

To be able to compile everything and host a local copy of this app, you need:

* [CoffeeScript](http://coffeescript.org/)
* [Bower](http://bower.io/)
* [SASS](http://sass-lang.com/)
* [Grunt](http://github.com/mishoo/UglifyJS2)

### Compiling

You need to install the packages with Bower and Node first:

```
bower install
npm install
```
  
Afterwards, you can simply run `grunt` in order to compile the necessary development files and `grunt watch` to
monitor them for changes. You should point your local webserver to the `/src` directory and use the `index.html` file 
there for development. The `index.dist.html` represents the version that will be used in production.

If you want to generate a new build, use `grunt build` in order to generate the static files needed for a deyploment.
The generated files will be located in `/dist`.

In order to create a new release, use `grunt release`.

### Server Setup

The web root folder should be mapped to `/dist` and you need HTTP Rewrites for the HTML5 URLs.
For Apache, they look like this:

```
RewriteEngine on
RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]
RewriteRule ^ index.html [L]
```
  
Similarly, nginx Rules should like something like this:

```
location / {
  try_files $uri $uri/ /index.html =404;
}
```
