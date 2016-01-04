metalsmith = require 'metalsmith'
coffee = require 'metalsmith-coffee'
assets = require 'metalsmith-static'
lib = require('bower-files')()
_ = require 'lodash'
{ readFileSync } = require 'fs'
{ basename } = require 'path'



###*
 * Custom plugins
###

bower = (files, metalsmith, done) ->
  include = (root, included) ->
    for file in included
      contents = readFileSync(file)
      files["#{root}/#{basename(file)}"] =
        contents: contents
  include('css', lib.self().ext('css').files)
  include('js', lib.self().ext('js').files)
  include('fonts', lib.self().ext(['eot','otf','ttf','woff']).files)
  done()

createManifest = (files, metalsmith, done) ->
  manifest = 
    manifest_version: 2
    name: 'PayPal Plus'
    version: require('./package.json').version
    icons:
      '16': 'img/pluspal-16.png'
      '48': 'img/pluspal-48.png'
      '128': 'img/pluspal-128.png'
    content_scripts: [
      {
        matches: [
          'https://www.paypal.com/myaccount/activity'
        ]
        js: 
          _.chain(files)
          .map (obj, name) -> name
          .filter (name) -> name.endsWith '.js'
          .value()
      }
    ]  
  files['manifest.json'] = 
    contents: JSON.stringify manifest, null, 2  
  done()


###*
 * Putting everything together.
###

metalsmith(__dirname)
.use bower
.use assets(
  src: 'static'
  dest: '.'
)
.use coffee()
.use createManifest
.destination 'build'
.build (err, files) ->
  if err? 
    console.error 'Got an error', err.stack
