metalsmith = require 'metalsmith'
coffee = require 'metalsmith-coffee'

manifest = 
  manifest_version: 2
  name: 'Fix Paypal'
  version: require('./package.json').version
  content_scripts: [
    {
      matches: [
        '<all_urls>'
      ]
      js: [
        'content.js'
      ]
    }
  ]


###*
 * Custom plugins
###

copyManifest = (files, metalsmith, done) ->
  files['manifest.json'] = 
    contents: JSON.stringify manifest, null, 2  
  done()


###*
 * Putting everything together.
###

metalsmith(__dirname)
.use coffee()
.use copyManifest
.destination 'build'
.build (err, files) ->
  if err 
    console.error err
