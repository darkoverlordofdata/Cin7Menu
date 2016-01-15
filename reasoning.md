## Reasoning

The gnome scripting environment supports ES6. Isn't that better than coffeescript?

Not necessarily, and it's not the current version of ES6. I can't find what version it is, but it doesn't support yield. At some time, the shell was forked from spidermonkey to prevent breaking changes from FF updates. So it's intentionaly behind.

Coffee-script is easier to read, especially when there are a lot of async callbacks.
The build process encourages a more modular, 1 class per file approach that is easier to maintain than on big monolithic javascript... I couldn't follow the original code.

To start with, both coffeescript and typescript 'class' semantics are more clear than a library based class approach. They are also more flexible.

Lang.bind doesn't seem to be any different than Function.bind, in fact, it calls Function.bind. It can be replaced with Function.bind, or the convenient fat arrow. 

Lang.* uses loose equality checks - instability waiting to happen.


