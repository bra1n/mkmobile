module.exports = (grunt) ->

  # These plugins provide necessary tasks.
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-bump'
  grunt.loadNpmTasks 'grunt-html2js'

  # Default task.
  grunt.registerTask 'default', ['coffee', 'sass:dev', 'watch']
  grunt.registerTask 'build', ['clean', 'coffee', 'html2js', 'sass:dist', 'i18n', 'concat', 'uglify', 'copy']
  grunt.registerTask 'release', (type = "patch") -> grunt.task.run ['bump-only:'+type, 'build', 'bump-commit']

  # locales and translations gathering and transforming
  grunt.registerMultiTask 'i18n', 'Gather locales and translations for dynamic loading', ->
    unless @data.languages? and @data.locales? and @data.translations? and @data.dest?
      grunt.log.error "missing paramaters for i18n"
      return false
    # concatenate locale
    locales = @data.languages.map (elem) -> elem.toLowerCase().replace /_/, '-'
    content = "angular.module('locales', ['locales-"+locales.join("','locales-")+"']);\n"
    for locale in locales
      code = grunt.file.read @data.locales + locale + '.js'
      code = code.replace /'use strict';/, '\n'
      code = code.replace /"ngLocale", \[\], \[/, '"locales-'+locale+'", []).run(['
      code = code.replace /\$provide/g, 'tmhDynamicLocaleCache'
      code = code.replace /\.value\("\$locale"/, '.put("'+locale+'"'
      content += code
    grunt.file.write @data.dest + 'locales.js', content
    grunt.log.writeln "File #{(@data.dest+'locales.js').cyan} created from #{locales.length.toString().cyan} locales"
    # concatenate translations
    content = 'angular.module("translations", ["pascalprecht.translate"]).config(["$translateProvider", function($translateProvider) {\n'
    for language in @data.languages
      content += '$translateProvider.translations("' + language + '", '
      content += grunt.file.read @data.translations + language + '.json'
      content += ');\n'
    content += '}]);'
    grunt.file.write @data.dest + 'translations.js', content
    grunt.log.writeln "File #{(@data.dest+'translations.js').cyan} created from #{@data.languages.length.toString().cyan} translations"

  # Project configuration
  grunt.initConfig
    # Metadata
    distdir: 'dist'
    pkg: grunt.file.readJSON 'package.json'
    banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - '+
      '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
      '<%= pkg.author ? " * Author: " + pkg.author + "\\n" : "" %>' +
      '<%= pkg.homepage ? " * " + pkg.homepage + "\\n" : "" %>' +
      ' * Copyright (c) <%= grunt.template.today("yyyy") %> ; <%= pkg.company %> */\n'
    src:
      tpl: 'src/partials/**/*.html'
      css: 'src/css'
      js: 'src/js'
      lib: 'src/lib'
      index: 'src/index.dist.html'
      assets: 'src/img'
      translations: 'src/translations'

    # Task configuration
    bump:
      options:
        files: ['package.json', 'bower.json']
        updateConfigs: ['pkg']
        commitMessage: 'Release v%VERSION%'
        commitFiles: ['.']
        pushTo: 'origin'

    clean: ['<%= distdir %>/*']

    coffee:
      options:
        bare: true
        sourceMap: true
      main:
        expand: true
        cwd: '<%= src.js %>'
        src: ['**/*.coffee']
        dest: '<%= src.js %>'
        ext: '.js'

    html2js:
      options:
        module: 'templates'
        base: 'src'
        rename: (moduleName) -> '/' + moduleName
      main:
        src: ['<%= src.tpl %>']
        dest: '<%= src.js %>/build/templates.js'

    sass:
      dev:
        options:
          style: 'expanded'
          noCache: true
        files: '<%= src.css %>/styles.css': '<%= src.css %>/styles.scss'
      dist:
        options:
          style: 'compressed'
          noCache: true
          sourcemap: 'none'
        files: '<%= distdir %>/styles.css': '<%= src.css %>/styles.scss'

    i18n:
      dist:
        locales: '<%= src.lib %>/angular-i18n/angular-locale_'
        translations: '<%= src.translations %>/lang-'
        languages: ['en_GB', 'de_DE', 'it_IT', 'fr_FR', 'es_ES']
        dest: '<%= src.js %>/build/'

    concat:
      lib:
        options:
          banner: '<%= banner %>'
          stripBanners: true
        src: [
          '<%= src.lib %>/angular/angular.min.js'
          '<%= src.lib %>/angular-route/angular-route.min.js'
          '<%= src.lib %>/angular-sanitize/angular-sanitize.min.js'
          '<%= src.lib %>/angular-resource/angular-resource.min.js'
          '<%= src.lib %>/angular-dynamic-locale/tmhDynamicLocale.min.js'
          '<%= src.lib %>/angular-translate/angular-translate.min.js'
          '<%= src.lib %>/angular-translate-loader-static-files/angular-translate-loader-static-files.min.js'
          '<%= src.lib %>/cryptojslib/rollups/hmac-sha1.js'
          '<%= src.lib %>/cryptojslib/components/enc-base64-min.js'
        ]
        dest: '<%= distdir %>/lib.js'
      index:
        src: ['<%= src.index %>'],
        dest: '<%= distdir %>/index.html',
        options: process: true

    uglify: 
      options: 
        banner: '<%= banner %>'
      dist:
        src: '<%= src.js %>/**/*.js'
        dest: '<%= distdir %>/app.js'

    copy:
      assets:
        files: [{
          dest: '<%= distdir %>/img'
          src: '*.*'
          expand: true
          cwd: '<%= src.assets %>'
        }]

    watch:
      options:
        interrupt: true
        debounceDelay: 250
      coffee:
        files: '<%= src.js %>/**/*.coffee'
        tasks: ['coffee']
      css:
        files: '<%= src.css %>/*.scss'
        tasks: ['sass:dev']
