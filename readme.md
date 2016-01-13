           ___ _     ____   __  __              
          / __(_)_ _|__  | |  \/  |___ _ _ _  _ 
         | (__| | ' \ / /  | |\/| / -_) ' \ || |
          \___|_|_||_/_/   |_|  |_\___|_||_\_,_|
                                        

## Is it a sin for Linux to look like Windows?
### Cin7Menu - Windows 7 style Menu for Linux Mint 17.3 / Cinnamon

Based on StarkMenu@mintystark

Status: baseline port. No mods yet.


## Install & Build
 
$ git clone git@github.com:darkoverlordofdata/Cin7Menu.git
$ cd Cin7Menu
$ npm install
$ tools/configure
$ npm run build
$ mv ./Cin7Menu@darkoverlordofdata.com ~./local/share/cinnamon/applets


## Reasoning
Coffee-script is easier to read, especially when there are a lot of async callbacks.
The build process encourages a more modular, 1 class per file approach that is easier to maintain than on big monolithic javascript... I couldn't follow the original code.

Among other things, coffee-script replaces these gjs builtins:
* Lang.Class
* Lang.bind

Why not use the builtins? 
* Based on Moo Tools (not bad, just ... why?)
* Doesn't appear to have updated since 2008
* Uses loose rather than strict equality

In general, coffeescript and typescript 'class' semantics are more clear than a library based class approach. They are also more flexible.
Lang.bind doesn't seem to be any different than Function.bind, in fact, it calls Function.bind. It can be replaced with Function.bind, or the convenient fat arrow. Perhaps at one time these were more useful, but I think it's time for a more modern solution.
