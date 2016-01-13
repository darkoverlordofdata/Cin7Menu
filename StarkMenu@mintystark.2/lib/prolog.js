var Applet = imports.ui.applet;
var Mainloop = imports.mainloop;
var CMenu = imports.gi.CMenu;
var Lang = imports.lang;
var Cinnamon = imports.gi.Cinnamon;
var St = imports.gi.St;
var Clutter = imports.gi.Clutter;
var Main = imports.ui.main;
var PopupMenu = imports.ui.popupMenu;
var AppFavorites = imports.ui.appFavorites;
var Gtk = imports.gi.Gtk;
var Gio = imports.gi.Gio;
var Signals = imports.signals;
var GnomeSession = imports.misc.gnomeSession;
var ScreenSaver = imports.misc.screenSaver;
var FileUtils = imports.misc.fileUtils;
var Util = imports.misc.util;
var Tweener = imports.ui.tweener;
var DND = imports.ui.dnd;
var Meta = imports.gi.Meta;
var DocInfo = imports.misc.docInfo;
var GLib = imports.gi.GLib;
var AccountsService = imports.gi.AccountsService;
var Settings = imports.ui.settings;
var Pango = imports.gi.Pango;

var Session = new GnomeSession.SessionManager();
var ICON_SIZE = 16;
var MAX_FAV_ICON_SIZE = 64;
var CATEGORY_ICON_SIZE = 22;
var APPLICATION_ICON_SIZE = 22;
var HOVER_ICON_SIZE = 48;
var MAX_RECENT_FILES = 20;

var USER_DESKTOP_PATH = FileUtils.getUserDesktopDir();


var appsys = Cinnamon.AppSystem.get_default();

