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
  grunt.registerTask 'default', ['coffee', 'html2js', 'sass:dev']
  grunt.registerTask 'build', ['clean', 'coffee', 'html2js', 'sass:dist', 'concat', 'uglify', 'copy']

  # Project configuration
  grunt.initConfig
    # Metadata
    distdir: 'dist'
    pkg: grunt.file.readJSON 'package.json'
    banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - '+
      '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
      '<%= pkg.homepage ? " * " + pkg.homepage + "\\n" : "" %>' +
      ' * Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;'+
      ' All rights reserved */\n'
    src:
      tpl: 'src/partials/**/*.html'
      css: 'src/css'
      js: 'src/js'
      lib: 'src/lib'
      index: 'src/index.dist.html'
      assets: 'src/img'

    # Task configuration
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
        base: 'app'
        rename: (moduleName) -> '/' + moduleName
      main:
        src: ['<%= src.tpl %>']
        dest: '<%= src.js %>/app/templates.js'

    sass:
      dev:
        options:
          style: 'expanded'
          noCache: true
          sourcemap: true
        files: '<%= src.css %>/styles.css': '<%= src.css %>/styles.scss'
      dist:
        options:
          style: 'compressed'
          noCache: true
        files: '<%= distdir %>/styles.<%= pkg.version %>.css': '<%= src.css %>/styles.scss'

    concat:
      lib:
        options:
          banner: '<%= banner %>'
          stripBanners: true
        src: [
          '<%= src.lib %>/jquery/dist/jquery.min.js'
          '<%= src.lib %>/angular/angular.min.js'
          '<%= src.lib %>/angular-route/angular-route.min.js'
          '<%= src.lib %>/angular-resource/angular-resource.min.js'
          '<%= src.lib %>/angular-animate/angular-animate.min.js'
          '<%= src.lib %>/angular-dynamic-locale/src/tmhDynamicLocale.js'
          '<%= src.lib %>/angular-translate/angular-translate.min.js'
          '<%= src.lib %>/angular-translate-loader-static-files/angular-translate-loader-static-files.min.js'
          '<%= src.lib %>/cryptojslib/rollups/hmac-sha1.js'
          '<%= src.lib %>/cryptojslib/components/enc-base64-min.js'
        ]
        dest: '<%= distdir %>/lib.<%= pkg.version %>.js'
      index:
        src: ['<%= src.index %>'],
        dest: '<%= distdir %>/index.html',
        options: process: true

    uglify: 
      options: 
        banner: '<%= banner %>'
      dist:
        src: '<%= src.js %>/**/*.js'
        dest: '<%= distdir %>/app.<%= pkg.version %>.js'

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
      html:
        files: '<%= src.tpl %>'
        tasks: ['html2js']
      css:
        files: '<%= src.css %>/*.scss'
        tasks: ['sass:dev']