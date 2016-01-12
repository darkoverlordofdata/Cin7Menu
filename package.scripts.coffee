###
#+--------------------------------------------------------------------+
#| package.scripts.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2014-2015
#+--------------------------------------------------------------------+
#|
#| Generate package.script
#|
#| ash.coffee is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
###
fs = require('fs')

# projectTypes enum:
JavaScript      = 0   # javascript
TypeScript      = 1   # typescript
CoffeeScript    = 2   # coffeescript
BabelScript     = 4   # es6
ClosureCompiler = 8   # plovr

# paths:
LIB_NAME        = "Cin7Menu"
CSCONFIG        = "./csconfig.json"

###
# Generate package.script
###
module.exports = (project, options = {}) ->

  ### build the project ###
  build: do ->

    step = [].concat(project.config.build)
      
    ###
    # Build after recompiling all coffeescript together
    ###
    files = require(CSCONFIG).files.join(" LF ")
    step.push """
      cat #{files} | coffee -cbs > Cin7Menu@darkoverlordofdata.com/applet.js
    """
      
    return step
      
  ### delete the prior build items ###
  clean: """
    rm -rf build/*
  """

  ### prepare for build ###
  prebuild: """
    npm run clean -s
  """

  postbuild: """
    cp -f ./Cin7Menu@darkoverlordofdata.com/applet.js ~/.local/share/cinnamon/applets/Cin7Menu@darkoverlordofdata.com/applet.js
  """
