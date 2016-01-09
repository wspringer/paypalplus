metalsmith       = require 'metalsmith'
coffee           = require 'metalsmith-coffee'
assets           = require 'metalsmith-static'
lib              = require('bower-files')()
_                = require 'lodash'
yazl             = require 'yazl'
{ readFileSync } = require 'fs'
{ basename }     = require 'path'
assert           = require 'assert'
fs               = require 'fs'
uglify           = require 'metalsmith-uglify'



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
          .filter (name) -> name.endsWith 'min.js'
          .value()
      }
    ]  
  files['manifest.json'] = 
    contents: JSON.stringify manifest, null, 2  
  done()


zip = (target) ->
  try
    assert not _.isUndefined(target), 'Expecting target to be set'
    (files, metalsmith, done) ->
      zip = new yazl.ZipFile()
      zip.outputStream.pipe(fs.createWriteStream(target))
      _.each files, (file, name) ->
        if not name.startsWith '.'
          if name.endsWith '.js'
            if name.endsWith 'min.js'
              zip.addBuffer file.contents, name
          else zip.addBuffer file.contents, name
      zip.end()
      done()
  catch err
    done(err)


###*
 * Putting everything together.
###

name = 'paypalplus-' + (require('./package.json')).version + '.zip'

metalsmith(__dirname)
.use bower
.use assets(
  src: 'static'
  dest: '.'
)
.use coffee()
.use uglify()
.use createManifest
.use zip(name)
.destination 'build'
.build (err, files) ->
  if err? 
    console.error 'Got an error', err.stack
