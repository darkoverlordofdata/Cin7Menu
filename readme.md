           ___ _     ____   __  __              
          / __(_)_ _|__  | |  \/  |___ _ _ _  _ 
         | (__| | ' \ / /  | |\/| / -_) ' \ || |
          \___|_|_||_/_/   |_|  |_\___|_||_\_,_|
                                        

## Is it a sin for Linux to look like Windows?
### Cin7Menu - Windows 7 style Menu for Linux Mint 17.3 / Cinnamon

Based on StarkMenu@mintystark
100% Pure Coffee-script Solution.

Status: new configuration
ToDo:
* less padding on favorites
* run ... prompt 
* sub menu type
* all programs menu should fit in same space as favorites.
* all programs menu should be a tree, not side x sid
* connect to should launch network applet instead of network settings.


## Install & Build
 
$ git clone git@github.com:darkoverlordofdata/Cin7Menu.git
$ cd Cin7Menu
$ npm install
$ tools/configure
$ npm run build
$ mv ./Cin7Menu@darkoverlordofdata.com ~./local/share/cinnamon/applets


## Motivation

I switch back and forth alot between Windows 7 and Mint machines.
I want the 2 desktops to be arranged the same - same background, same shortcuts, and in most cases, the same apps.
With Babun, I have almost the same terminal. Stardoc replaces Cairo.
So why not the same menu? And this is one case where Windows has the best widget with the StartMenu.