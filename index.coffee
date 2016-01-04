metalsmith = require 'metalsmith'
coffee = require 'metalsmith-coffee'
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
    name: 'Fix Paypal'
    version: require('./package.json').version
    content_scripts: [
      {
        matches: [
          '<all_urls>'
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
.use coffee()
.use createManifest
.destination 'build'
.build (err, files) ->
  if err 
    console.error err
