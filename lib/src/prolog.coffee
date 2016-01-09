###
  Cin7Menu
  
  Windows7 Style menu for Cinnamon
###

Applet = imports.ui.applet
Mainloop = imports.mainloop
CMenu = imports.gi.CMenu
Lang = imports.lang
Cinnamon = imports.gi.Cinnamon
St = imports.gi.St
Clutter = imports.gi.Clutter
Main = imports.ui.main
PopupMenu = imports.ui.popupMenu
AppFavorites = imports.ui.appFavorites
Gtk = imports.gi.Gtk
Gio = imports.gi.Gio
Signals = imports.signals
GnomeSession = imports.misc.gnomeSession
ScreenSaver = imports.misc.screenSaver
FileUtils = imports.misc.fileUtils
Util = imports.misc.util
Tweener = imports.ui.tweener
DND = imports.ui.dnd
Meta = imports.gi.Meta
DocInfo = imports.misc.docInfo
GLib = imports.gi.GLib
AccountsService = imports.gi.AccountsService
Settings = imports.ui.settings
Pango = imports.gi.Pango

Session = new GnomeSession.SessionManager()
ICON_SIZE = 16
MAX_FAV_ICON_SIZE = 64
CATEGORY_ICON_SIZE = 22
APPLICATION_ICON_SIZE = 22
HOVER_ICON_SIZE = 48
MAX_RECENT_FILES = 20

USER_DESKTOP_PATH = FileUtils.getUserDesktopDir()


appsys = Cinnamon.AppSystem.get_default()
