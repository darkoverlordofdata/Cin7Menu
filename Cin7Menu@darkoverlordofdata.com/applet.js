// Generated by CoffeeScript 1.10.0

/*
  Cin7Menu
  
  Windows7 Style menu for Cinnamon
 */
var APPLICATION_ICON_SIZE, AccountsService, AppFavorites, Applet, CATEGORY_ICON_SIZE, CMenu, Cinnamon, Clutter, DND, DocInfo, FileUtils, GLib, Gettext, Gio, GnomeSession, Gtk, HOVER_ICON_SIZE, ICON_SIZE, Lang, MAX_FAV_ICON_SIZE, MAX_RECENT_FILES, Main, Mainloop, Meta, Pango, PopupMenu, ScreenSaver, Session, Settings, Signals, St, TestApplet, Tweener, USER_DESKTOP_PATH, Util, VisibleChildIterator, _, appsys, main,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Applet = imports.ui.applet;

Mainloop = imports.mainloop;

CMenu = imports.gi.CMenu;

Lang = imports.lang;

Cinnamon = imports.gi.Cinnamon;

St = imports.gi.St;

Clutter = imports.gi.Clutter;

Main = imports.ui.main;

PopupMenu = imports.ui.popupMenu;

AppFavorites = imports.ui.appFavorites;

Gtk = imports.gi.Gtk;

Gio = imports.gi.Gio;

Signals = imports.signals;

GnomeSession = imports.misc.gnomeSession;

ScreenSaver = imports.misc.screenSaver;

FileUtils = imports.misc.fileUtils;

Util = imports.misc.util;

Tweener = imports.ui.tweener;

DND = imports.ui.dnd;

Meta = imports.gi.Meta;

DocInfo = imports.misc.docInfo;

GLib = imports.gi.GLib;

AccountsService = imports.gi.AccountsService;

Settings = imports.ui.settings;

Pango = imports.gi.Pango;

Session = new GnomeSession.SessionManager();

ICON_SIZE = 16;

MAX_FAV_ICON_SIZE = 64;

CATEGORY_ICON_SIZE = 22;

APPLICATION_ICON_SIZE = 22;

HOVER_ICON_SIZE = 48;

MAX_RECENT_FILES = 20;

USER_DESKTOP_PATH = FileUtils.getUserDesktopDir();

appsys = Cinnamon.AppSystem.get_default();


/*
 * VisibleChildIterator takes a container (boxlayout, etc.)
 * and creates an array of its visible children and their index
 * positions.  We can then work thru that list without
 * mucking about with positions and math, just give a
 * child, and it'll give you the next or previous, or first or
 * last child in the list.
 *
 * We could have this object regenerate off a signal
 * every time the visibles have changed in our applicationBox,
 * but we really only need it when we start keyboard
 * navigating, so increase speed, we reload only when we
 * want to use it.
 */

VisibleChildIterator = (function() {
  function VisibleChildIterator(parent, container) {
    this._init(parent, container);
  }

  VisibleChildIterator.prototype._init = function(parent, container) {
    this.container = container;
    this._parent = parent;
    this._num_children = 0;
    this.reloadVisible();
  };

  VisibleChildIterator.prototype.reloadVisible = function() {
    var child, children, i;
    this.visible_children = new Array();
    this.abs_index = new Array();
    children = this.container.get_children();
    i = 0;
    while (i < children.length) {
      child = children[i];
      if (child.visible) {
        this.visible_children.push(child);
        this.abs_index.push(i);
      }
      i++;
    }
    this._num_children = this.visible_children.length;
  };

  VisibleChildIterator.prototype.getNextVisible = function(cur_child) {
    if (this.visible_children.indexOf(cur_child) === this._num_children - 1) {
      return cur_child;
    } else {
      return this.visible_children[this.visible_children.indexOf(cur_child) + 1];
    }
  };

  VisibleChildIterator.prototype.getPrevVisible = function(cur_child) {
    if (this.visible_children.indexOf(cur_child) === 0) {
      return cur_child;
    } else {
      return this.visible_children[this.visible_children.indexOf(cur_child) - 1];
    }
  };

  VisibleChildIterator.prototype.getFirstVisible = function() {
    return this.visible_children[0];
  };

  VisibleChildIterator.prototype.getLastVisible = function() {
    return this.visible_children[this._num_children - 1];
  };

  VisibleChildIterator.prototype.getNumVisibleChildren = function() {
    return this._num_children;
  };

  VisibleChildIterator.prototype.getAbsoluteIndexOfChild = function() {
    return this.abs_index[this.visible_children.indexOf(child)];
  };

  return VisibleChildIterator;

})();

Applet = imports.ui.applet;

GLib = imports.gi.GLib;

Util = imports.misc.util;

Gettext = imports.gettext.domain('cinnamon-applets');

_ = Gettext.gettext;

TestApplet = (function() {
  var base;

  TestApplet.prototype.__proto__ = base = Applet.IconApplet.prototype;

  TestApplet.prototype.name = 'Gracie';

  function TestApplet(orientation) {
    this.on_applet_clicked = bind(this.on_applet_clicked, this);
    var e, error;
    base._init.call(this, orientation);
    try {
      this.set_applet_icon_name("gnome-info");
      this.set_applet_tooltip(_("Say Hello, " + this.name));
      return;
    } catch (error) {
      e = error;
      global.logError(e);
      return;
    }
  }

  TestApplet.prototype.on_applet_clicked = function(evtdata) {
    var notification;
    notification = "notify-send \"Hello " + this.name + "\"  -a TEST -t 10 -u low";
    Util.spawnCommandLine(notification);
  };

  return TestApplet;

})();

main = function(metadata, orientation) {
  return new TestApplet(orientation);
};
