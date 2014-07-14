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

You need to install the dependencies with Bower and Node first:

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

### Folder structure

The project is split into 2 main folders, `dist` and `src`. For production, the web root should be `dist`,
while for development, it should be `src`.

```
dist/           # the web root for production, contains all the necesssary files for a deployment
  img/          # all image assets are copied over to this folder for production deployment
  translations/ # the translations are copied over here to be available in production as well
  
  app.js        # the compiled, concatenated and minified app code
  index.html    # the main index HTML, built from the index.dist.html
  lib.js        # all JS libraries are concatenated into this file
  styles.css    # the compiled and compressed styles are here
  
src/            # the web root for development, contains all the sources, libraries and assets
  css/          # contains the SCSS stylesheets and partials
  img/          # all images and spritemaps are here, with sprite source files in separate subfolders
  js/           # the main app logic
    app/        # controllers, directives and filters are here along with the base AngularJS app
    services/   # since there are several services built on top of the API, they are in their own folder
  lib/          # all JS dependencies are here, once you run Bower (not checked into GitHub)
  partials/     # the HTML templates are here
    directives/ # small directive templates are here, for footer, search fields, etc.
    pages/      # bigger page templates are here
  translations/ # the translations are here in form of a JSON file per language
  
  .htaccess     # example .htaccess file for an Apache server
  index.dist.html # the HTML file template that will be used in dist/
  index.html    # the development HTML index file, that contains all the necessary script tags

```

### URL Rewrite

The MKMobile App uses HTML5 URL States to allow navigation between different states of the app via
browser buttons. In order for this to work, you need to allow URL Rewriting on your server. Any requests that 
doesn't match an actual file / folder should be redirected to the `index.html`. Here are some example
rules for the most popular webservers.

- Apache:

```
RewriteEngine on
RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]
RewriteRule ^ index.html [L]
```
  
- nginx

```
location / {
  try_files $uri $uri/ /index.html =404;
}
```

- Lighttpd

```
$HTTP["host"] == "mkmobile.local" {
    url.rewrite-if-not-file = ( "^.+" => "index.html")
}
```
