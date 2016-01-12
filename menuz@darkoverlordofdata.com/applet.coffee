
# VisibleChildIterator takes a container (boxlayout, etc.)
# * and creates an array of its visible children and their index
# * positions.  We can then work thru that list without
# * mucking about with positions and math, just give a
# * child, and it'll give you the next or previous, or first or
# * last child in the list.
# *
# * We could have this object regenerate off a signal
# * every time the visibles have changed in our applicationBox,
# * but we really only need it when we start keyboard
# * navigating, so increase speed, we reload only when we
# * want to use it.
# 
VisibleChildIterator = (container) ->
  @_init container
  return
ApplicationContextMenuItem = (appButton, label, action) ->
  @_init appButton, label, action
  return

# Need to find a way to do that using the Gio library, but modifying the access::can-execute attribute on the file object seems unsupported
GenericApplicationButton = (appsMenuButton, app) ->
  @_init appsMenuButton, app
  return
TransientButton = (appsMenuButton, pathOrCommand) ->
  @_init appsMenuButton, pathOrCommand
  return

# We need this fake app to help appEnterEvent/appLeaveEvent 
# work with our search result.

# @todo Would be nice to indicate we don't have a handler for this file.

# Try anyway, even though we probably shouldn't.
ApplicationButton = (appsMenuButton, app) ->
  @_init appsMenuButton, app
  return

# Returns the original actor that should align with the actor
# we show as the item is being dragged.
SearchProviderResultButton = (appsMenuButton, provider, result) ->
  @_init appsMenuButton, provider, result
  return

# We need this fake app to help appEnterEvent/appLeaveEvent 
# work with our search result.
PlaceButton = (appsMenuButton, place, button_name) ->
  @_init appsMenuButton, place, button_name
  return
RecentContextMenuItem = (recentButton, label, is_default, callback) ->
  @_init recentButton, label, is_default, callback
  return
RecentButton = (appsMenuButton, file) ->
  @_init appsMenuButton, file
  return
GenericButton = (label, icon, reactive, callback) ->
  @_init label, icon, reactive, callback
  return
RecentClearButton = (appsMenuButton) ->
  @_init appsMenuButton
  return
CategoryButton = (app) ->
  @_init app
  return
PlaceCategoryButton = (app) ->
  @_init app
  return
RecentCategoryButton = (app) ->
  @_init app
  return
FavoritesButton = (appsMenuButton, app, nbFavorites) ->
  @_init appsMenuButton, app, nbFavorites
  return

# Returns the original actor that should align with the actor
# we show as the item is being dragged.
SystemButton = (appsMenuButton, icon, nbFavorites, name, desc) ->
  @_init appsMenuButton, icon, nbFavorites, name, desc
  return
CategoriesApplicationsBox = ->
  @_init()
  return
FavoritesBox = ->
  @_init()
  return

# Keep the placeholder out of the index calculation; assuming that
# the remove target has the same size as "normal" items, we don't
# need to do the same adjustment there.

# Don't allow positioning before or after self

# If the placeholder already exists, we just move
# it, but if we are adding it, expand its size in
# an animation

# Draggable target interface
MyApplet = (orientation, panel_height, instance_id) ->
  @_init orientation, panel_height, instance_id
  return
# Used to keep track of apps that are already installed, so we can highlight newly installed ones

# We shouldn't need to call refreshAll() here... since we get a "icon-theme-changed" signal when CSD starts.
# The reason we do is in case the Cinnamon icon theme is the same as the one specificed in GTK itself (in .config)
# In that particular case we get no signal at all.

# If all else fails, this will yield no icon 

# check for a keybinding and quit early, otherwise we get a double hit
#           of the keybinding callback 

# Need preload data before get completion. GFilenameCompleter load content of parent directory.
# Parent directory for /usr/include/ is /usr/. So need to add fake name('a').

# Now generate Places category and places buttons and add to the list

# Now generate recent category and recent files buttons and add to the list

#Remove all categories

# Sort apps and add to applicationsBox

#Remove all favorites

#Load favorites again
# + 3 because we're adding 3 system buttons at the bottom

#Separator

#Lock screen

#Logout button

#Shutdown button
#this is to support old themes
#this is to support old themes
# The answer to life...

# _listApplications returns all the applications when the search
# string is zero length. This will happend if you type a space
# in the search entry.
# search box autocompletion results

# Don't use the pattern here, as filesystem is case sensitive

# The exception from gjs contains an error string like:
#     Error invoking Gio.app_info_launch_default_for_uri: No application
#     is registered as handling this file
# We are only interested in the part after the first colon.
#var message = e.message.replace(/[^:]*: *(.+)/, '$1');
main = (metadata, orientation, panel_height, instance_id) ->
  myApplet = new MyApplet(orientation, panel_height, instance_id)
  myApplet
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
Atk = imports.gi.Atk
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
Settings = imports.ui.settings
Pango = imports.gi.Pango
SearchProviderManager = imports.ui.searchProviderManager
ICON_SIZE = 16
MAX_FAV_ICON_SIZE = 32
CATEGORY_ICON_SIZE = 22
APPLICATION_ICON_SIZE = 22
MAX_RECENT_FILES = 20
INITIAL_BUTTON_LOAD = 30
MAX_BUTTON_WIDTH = "max-width: 20em;"
USER_DESKTOP_PATH = FileUtils.getUserDesktopDir()
PRIVACY_SCHEMA = "org.cinnamon.desktop.privacy"
REMEMBER_RECENT_KEY = "remember-recent-files"
appsys = Cinnamon.AppSystem.get_default()
VisibleChildIterator:: =
  _init: (container) ->
    @container = container
    @reloadVisible()
    return

  reloadVisible: ->
    @array = @container.get_focus_chain().filter((x) ->
      (x._delegate not instanceof PopupMenu.PopupSeparatorMenuItem)
      return
    )
    return

  getNextVisible: (curChild) ->
    @getVisibleItem @array.indexOf(curChild) + 1

  getPrevVisible: (curChild) ->
    @getVisibleItem @array.indexOf(curChild) - 1

  getFirstVisible: ->
    @array[0]

  getLastVisible: ->
    @array[@array.length - 1]

  getVisibleIndex: (curChild) ->
    @array.indexOf curChild

  getVisibleItem: (index) ->
    len = @array.length
    index = ((index % len) + len) % len
    @array[index]

  getNumVisibleChildren: ->
    @array.length

  getAbsoluteIndexOfChild: (child) ->
    @container.get_children().indexOf child

ApplicationContextMenuItem:: =
  __proto__: PopupMenu.PopupBaseMenuItem::
  _init: (appButton, label, action) ->
    PopupMenu.PopupBaseMenuItem::_init.call this,
      focusOnHover: false

    @_appButton = appButton
    @_action = action
    @label = new St.Label(text: label)
    @addActor @label
    return

  activate: (event) ->
    switch @_action
      when "add_to_panel"
        unless Main.AppletManager.get_role_provider_exists(Main.AppletManager.Roles.PANEL_LAUNCHER)
          new_applet_id = global.settings.get_int("next-applet-id")
          global.settings.set_int "next-applet-id", (new_applet_id + 1)
          enabled_applets = global.settings.get_strv("enabled-applets")
          enabled_applets.push "panel1:right:0:panel-launchers@cinnamon.org:" + new_applet_id
          global.settings.set_strv "enabled-applets", enabled_applets
        launcherApplet = Main.AppletManager.get_role_provider(Main.AppletManager.Roles.PANEL_LAUNCHER)
        launcherApplet.acceptNewLauncher @_appButton.app.get_id()
        @_appButton.toggleMenu()
      when "add_to_desktop"
        file = Gio.file_new_for_path(@_appButton.app.get_app_info().get_filename())
        destFile = Gio.file_new_for_path(USER_DESKTOP_PATH + "/" + @_appButton.app.get_id())
        try
          file.copy destFile, 0, null, ->

          Util.spawnCommandLine "chmod +x \"" + USER_DESKTOP_PATH + "/" + @_appButton.app.get_id() + "\""
        catch e
          global.log e
        @_appButton.toggleMenu()
      when "add_to_favorites"
        AppFavorites.getAppFavorites().addFavorite @_appButton.app.get_id()
        @_appButton.toggleMenu()
      when "remove_from_favorites"
        AppFavorites.getAppFavorites().removeFavorite @_appButton.app.get_id()
        @_appButton.toggleMenu()
      when "uninstall"
        Util.spawnCommandLine "gksu -m '" + _("Please provide your password to uninstall this application") + "' /usr/bin/cinnamon-remove-application '" + @_appButton.app.get_app_info().get_filename() + "'"
        @_appButton.appsMenuButton.menu.close()
    false

GenericApplicationButton:: =
  __proto__: PopupMenu.PopupSubMenuMenuItem::
  _init: (appsMenuButton, app, withMenu) ->
    @app = app
    @appsMenuButton = appsMenuButton
    PopupMenu.PopupBaseMenuItem::_init.call this,
      hover: false

    @withMenu = withMenu
    if @withMenu
      @menu = new PopupMenu.PopupSubMenu(@actor)
      @menu.actor.set_style_class_name "menu-context-menu"
      @menu.connect "open-state-changed", Lang.bind(this, @_subMenuOpenStateChanged)
    return

  highlight: ->
    @actor.add_style_pseudo_class "highlighted"
    return

  unhighlight: ->
    app_key = @app.get_id()
    app_key = @app.get_name() + ":" + @app.get_description()  unless app_key?
    @appsMenuButton._knownApps.push app_key
    @actor.remove_style_pseudo_class "highlighted"
    return

  _onButtonReleaseEvent: (actor, event) ->
    @activate event  if event.get_button() is 1
    if event.get_button() is 3
      @appsMenuButton.closeContextMenus @app, true  if @withMenu and not @menu.isOpen
      @toggleMenu()
    true

  activate: (event) ->
    @unhighlight()
    @app.open_new_window -1
    @appsMenuButton.menu.close()
    return

  closeMenu: ->
    @menu.close()  if @withMenu
    return

  toggleMenu: ->
    return  unless @withMenu
    unless @menu.isOpen
      children = @menu.box.get_children()
      for i of children
        @menu.box.remove_actor children[i]
      menuItem = undefined
      menuItem = new ApplicationContextMenuItem(this, _("Add to panel"), "add_to_panel")
      @menu.addMenuItem menuItem
      if USER_DESKTOP_PATH
        menuItem = new ApplicationContextMenuItem(this, _("Add to desktop"), "add_to_desktop")
        @menu.addMenuItem menuItem
      if AppFavorites.getAppFavorites().isFavorite(@app.get_id())
        menuItem = new ApplicationContextMenuItem(this, _("Remove from favorites"), "remove_from_favorites")
        @menu.addMenuItem menuItem
      else
        menuItem = new ApplicationContextMenuItem(this, _("Add to favorites"), "add_to_favorites")
        @menu.addMenuItem menuItem
      if @appsMenuButton._canUninstallApps
        menuItem = new ApplicationContextMenuItem(this, _("Uninstall"), "uninstall")
        @menu.addMenuItem menuItem
    @menu.toggle()
    return

  _subMenuOpenStateChanged: ->
    @appsMenuButton._scrollToButton @menu  if @menu.isOpen
    return

TransientButton:: =
  __proto__: PopupMenu.PopupSubMenuMenuItem::
  _init: (appsMenuButton, pathOrCommand) ->
    displayPath = pathOrCommand
    if pathOrCommand.charAt(0) is "~"
      pathOrCommand = pathOrCommand.slice(1)
      pathOrCommand = GLib.get_home_dir() + pathOrCommand
    @isPath = pathOrCommand.substr(pathOrCommand.length - 1) is "/"
    if @isPath
      @path = pathOrCommand
    else
      n = pathOrCommand.lastIndexOf("/")
      @path = pathOrCommand.substr(0, n)  unless n is 1
    @pathOrCommand = pathOrCommand
    @appsMenuButton = appsMenuButton
    PopupMenu.PopupBaseMenuItem::_init.call this,
      hover: false

    @app =
      get_app_info:
        get_filename: ->
          pathOrCommand

      get_id: ->
        -1

      get_description: ->
        @pathOrCommand

      get_name: ->
        ""

    iconBox = new St.Bin()
    @file = Gio.file_new_for_path(@pathOrCommand)
    try
      @handler = @file.query_default_handler(null)
      icon_uri = @file.get_uri()
      fileInfo = @file.query_info(Gio.FILE_ATTRIBUTE_STANDARD_TYPE, Gio.FileQueryInfoFlags.NONE, null)
      contentType = Gio.content_type_guess(@pathOrCommand, null)
      themedIcon = Gio.content_type_get_icon(contentType[0])
      @icon = new St.Icon(
        gicon: themedIcon
        icon_size: APPLICATION_ICON_SIZE
        icon_type: St.IconType.FULLCOLOR
      )
      @actor.set_style_class_name "menu-application-button"
    catch e
      @handler = null
      iconName = (if @isPath then "folder" else "unknown")
      @icon = new St.Icon(
        icon_name: iconName
        icon_size: APPLICATION_ICON_SIZE
        icon_type: St.IconType.FULLCOLOR
      )
      @actor.set_style_class_name "menu-application-button"
    @addActor @icon
    @label = new St.Label(
      text: displayPath
      style_class: "menu-application-button-label"
    )
    @label.clutter_text.ellipsize = Pango.EllipsizeMode.END
    @label.set_style MAX_BUTTON_WIDTH
    @addActor @label
    @isDraggableApp = false
    return

  _onButtonReleaseEvent: (actor, event) ->
    @activate event  if event.get_button() is 1
    true

  activate: (event) ->
    if @handler?
      @handler.launch [@file], null
    else
      try
        Util.spawn [
          "gvfs-open"
          @file.get_uri()
        ]
      catch e
        global.logError "No handler available to open " + @file.get_uri()
    @appsMenuButton.menu.close()
    return

ApplicationButton:: =
  __proto__: GenericApplicationButton::
  _init: (appsMenuButton, app) ->
    GenericApplicationButton::_init.call this, appsMenuButton, app, true
    @category = new Array()
    @actor.set_style_class_name "menu-application-button"
    @icon = @app.create_icon_texture(APPLICATION_ICON_SIZE)
    @addActor @icon
    @name = @app.get_name()
    @label = new St.Label(
      text: @name
      style_class: "menu-application-button-label"
    )
    @label.clutter_text.ellipsize = Pango.EllipsizeMode.END
    @label.set_style MAX_BUTTON_WIDTH
    @addActor @label
    @_draggable = DND.makeDraggable(@actor)
    @isDraggableApp = true
    @actor.label_actor = @label
    @icon.realize()
    @label.realize()
    return

  get_app_id: ->
    @app.get_id()

  getDragActor: ->
    favorites = AppFavorites.getAppFavorites().getFavorites()
    nbFavorites = favorites.length
    monitorHeight = Main.layoutManager.primaryMonitor.height
    real_size = (0.7 * monitorHeight) / nbFavorites
    icon_size = 0.6 * real_size / global.ui_scale
    icon_size = MAX_FAV_ICON_SIZE  if icon_size > MAX_FAV_ICON_SIZE
    @app.create_icon_texture icon_size

  getDragActorSource: ->
    @actor

SearchProviderResultButton:: =
  __proto__: PopupMenu.PopupBaseMenuItem::
  _init: (appsMenuButton, provider, result) ->
    @provider = provider
    @result = result
    @appsMenuButton = appsMenuButton
    PopupMenu.PopupBaseMenuItem::_init.call this,
      hover: false

    @actor.set_style_class_name "menu-application-button"
    @app =
      get_app_info:
        get_filename: ->
          result.id

      get_id: ->
        -1

      get_description: ->
        result.description

      get_name: ->
        result.label

    @icon = null
    if result.icon
      @icon = result.icon
    else if result.icon_app
      @icon = result.icon_app.create_icon_texture(APPLICATION_ICON_SIZE)
    else if result.icon_filename
      @icon = new St.Icon(
        gicon: new Gio.FileIcon(file: Gio.file_new_for_path(result.icon_filename))
        icon_size: APPLICATION_ICON_SIZE
      )
    @addActor @icon  if @icon
    @label = new St.Label(
      text: result.label
      style_class: "menu-application-button-label"
    )
    @addActor @label
    @isDraggableApp = false
    @icon.realize()  if @icon
    @label.realize()
    return

  _onButtonReleaseEvent: (actor, event) ->
    @activate event  if event.get_button() is 1
    true

  activate: (event) ->
    try
      @provider.on_result_selected @result
      @appsMenuButton.menu.close()
    catch e
      global.logError e
    return

PlaceButton:: =
  __proto__: PopupMenu.PopupBaseMenuItem::
  _init: (appsMenuButton, place, button_name) ->
    PopupMenu.PopupBaseMenuItem::_init.call this,
      hover: false

    @appsMenuButton = appsMenuButton
    @place = place
    @button_name = button_name
    @actor.set_style_class_name "menu-application-button"
    @actor._delegate = this
    @label = new St.Label(
      text: @button_name
      style_class: "menu-application-button-label"
    )
    @label.clutter_text.ellipsize = Pango.EllipsizeMode.END
    @label.set_style MAX_BUTTON_WIDTH
    @icon = place.iconFactory(APPLICATION_ICON_SIZE)
    unless @icon
      @icon = new St.Icon(
        icon_name: "folder"
        icon_size: APPLICATION_ICON_SIZE
        icon_type: St.IconType.FULLCOLOR
      )
    @addActor @icon  if @icon
    @addActor @label
    @icon.realize()
    @label.realize()
    return

  _onButtonReleaseEvent: (actor, event) ->
    if event.get_button() is 1
      @place.launch()
      @appsMenuButton.menu.close()
    return

  activate: (event) ->
    @place.launch()
    @appsMenuButton.menu.close()
    return

RecentContextMenuItem:: =
  __proto__: PopupMenu.PopupBaseMenuItem::
  _init: (recentButton, label, is_default, callback) ->
    PopupMenu.PopupBaseMenuItem::_init.call this,
      focusOnHover: false

    @_recentButton = recentButton
    @_callback = callback
    @label = new St.Label(text: label)
    @addActor @label
    @label.style = "font-weight: bold;"  if is_default
    return

  activate: (event) ->
    @_callback()
    false

RecentButton:: =
  __proto__: PopupMenu.PopupSubMenuMenuItem::
  _init: (appsMenuButton, file) ->
    PopupMenu.PopupBaseMenuItem::_init.call this,
      hover: false

    @file = file
    @appsMenuButton = appsMenuButton
    @button_name = @file.name
    @actor.set_style_class_name "menu-application-button"
    @actor._delegate = this
    @label = new St.Label(
      text: @button_name
      style_class: "menu-application-button-label"
    )
    @label.clutter_text.ellipsize = Pango.EllipsizeMode.END
    @label.set_style MAX_BUTTON_WIDTH
    @icon = file.createIcon(APPLICATION_ICON_SIZE)
    @addActor @icon
    @addActor @label
    @icon.realize()
    @label.realize()
    @menu = new PopupMenu.PopupSubMenu(@actor)
    @menu.actor.set_style_class_name "menu-context-menu"
    @menu.connect "open-state-changed", Lang.bind(this, @_subMenuOpenStateChanged)
    return

  _onButtonReleaseEvent: (actor, event) ->
    if event.get_button() is 1
      @file.launch()
      @appsMenuButton.menu.close()
    if event.get_button() is 3
      @appsMenuButton.closeContextMenus this, true  unless @menu.isOpen
      @toggleMenu()
    true

  activate: (event) ->
    @file.launch()
    @appsMenuButton.menu.close()
    return

  closeMenu: ->
    @menu.close()
    return

  hasLocalPath: (file) ->
    file.is_native() or file.get_path()?

  toggleMenu: ->
    unless @menu.isOpen
      children = @menu.box.get_children()
      for i of children
        @menu.box.remove_actor children[i]
      menuItem = undefined
      menuItem = new PopupMenu.PopupMenuItem(_("Open with"),
        reactive: false
      )
      menuItem.actor.style = "font-weight: bold"
      @menu.addMenuItem menuItem
      file = Gio.File.new_for_uri(@file.uri)
      default_info = Gio.AppInfo.get_default_for_type(@file.mimeType, not @hasLocalPath(file))
      if default_info
        menuItem = new RecentContextMenuItem(this, default_info.get_display_name(), false, Lang.bind(this, ->
          default_info.launch [file], null, null
          @toggleMenu()
          @appsMenuButton.menu.close()
          return
        ))
        @menu.addMenuItem menuItem
      infos = Gio.AppInfo.get_all_for_type(@file.mimeType)
      i = 0

      while i < infos.length
        info = infos[i]
        file = Gio.File.new_for_uri(@file.uri)
        continue  if not @hasLocalPath(file) and not info.supports_uris()
        continue  if info.equal(default_info)
        menuItem = new RecentContextMenuItem(this, info.get_display_name(), false, Lang.bind(this, ->
          info.launch [file], null, null
          @toggleMenu()
          @appsMenuButton.menu.close()
          return
        ))
        @menu.addMenuItem menuItem
        i++
      if GLib.find_program_in_path("nemo-open-with")?
        menuItem = new RecentContextMenuItem(this, _("Other application..."), false, Lang.bind(this, ->
          Util.spawnCommandLine "nemo-open-with " + @file.uri
          @toggleMenu()
          @appsMenuButton.menu.close()
          return
        ))
        @menu.addMenuItem menuItem
    @menu.toggle()
    return

  _subMenuOpenStateChanged: ->
    @appsMenuButton._scrollToButton @menu  if @menu.isOpen
    return

GenericButton:: =
  __proto__: PopupMenu.PopupBaseMenuItem::
  _init: (label, icon, reactive, callback) ->
    PopupMenu.PopupBaseMenuItem::_init.call this,
      hover: false

    @actor.set_style_class_name "menu-application-button"
    @actor._delegate = this
    @button_name = ""
    @label = new St.Label(
      text: label
      style_class: "menu-application-button-label"
    )
    @label.clutter_text.ellipsize = Pango.EllipsizeMode.END
    @label.set_style MAX_BUTTON_WIDTH
    if icon?
      icon_actor = new St.Icon(
        icon_name: icon
        icon_type: St.IconType.FULLCOLOR
        icon_size: APPLICATION_ICON_SIZE
      )
      @addActor icon_actor
    @addActor @label
    @label.realize()
    @actor.reactive = reactive
    @callback = callback
    @menu = new PopupMenu.PopupSubMenu(@actor)
    return

  _onButtonReleaseEvent: (actor, event) ->
    @callback()  if event.get_button() is 1
    return

RecentClearButton:: =
  __proto__: PopupMenu.PopupBaseMenuItem::
  _init: (appsMenuButton) ->
    PopupMenu.PopupBaseMenuItem::_init.call this,
      hover: false

    @appsMenuButton = appsMenuButton
    @actor.set_style_class_name "menu-application-button"
    @button_name = _("Clear list")
    @actor._delegate = this
    @label = new St.Label(
      text: @button_name
      style_class: "menu-application-button-label"
    )
    @icon = new St.Icon(
      icon_name: "edit-clear"
      icon_type: St.IconType.SYMBOLIC
      icon_size: APPLICATION_ICON_SIZE
    )
    @addActor @icon
    @addActor @label
    @menu = new PopupMenu.PopupSubMenu(@actor)
    return

  _onButtonReleaseEvent: (actor, event) ->
    if event.get_button() is 1
      @appsMenuButton.menu.close()
      GtkRecent = new Gtk.RecentManager()
      GtkRecent.purge_items()
    return

CategoryButton:: =
  __proto__: PopupMenu.PopupBaseMenuItem::
  _init: (category) ->
    PopupMenu.PopupBaseMenuItem::_init.call this,
      hover: false

    @actor.set_style_class_name "menu-category-button"
    label = undefined
    icon = null
    if category
      icon = category.get_icon()
      if icon and icon.get_names
        @icon_name = icon.get_names().toString()
      else
        @icon_name = ""
      label = category.get_name()
    else
      label = _("All Applications")
    @actor._delegate = this
    @label = new St.Label(
      text: label
      style_class: "menu-category-button-label"
    )
    if category and @icon_name
      @icon = St.TextureCache.get_default().load_gicon(null, icon, CATEGORY_ICON_SIZE)
      if @icon
        @addActor @icon
        @icon.realize()
    @actor.accessible_role = Atk.Role.LIST_ITEM
    @addActor @label
    @label.realize()
    return

PlaceCategoryButton:: =
  __proto__: PopupMenu.PopupBaseMenuItem::
  _init: (category) ->
    PopupMenu.PopupBaseMenuItem::_init.call this,
      hover: false

    @actor.set_style_class_name "menu-category-button"
    @actor._delegate = this
    @label = new St.Label(
      text: _("Places")
      style_class: "menu-category-button-label"
    )
    @icon = new St.Icon(
      icon_name: "folder"
      icon_size: CATEGORY_ICON_SIZE
      icon_type: St.IconType.FULLCOLOR
    )
    @addActor @icon
    @icon.realize()
    @addActor @label
    @label.realize()
    return

RecentCategoryButton:: =
  __proto__: PopupMenu.PopupBaseMenuItem::
  _init: (category) ->
    PopupMenu.PopupBaseMenuItem::_init.call this,
      hover: false

    @actor.set_style_class_name "menu-category-button"
    @actor._delegate = this
    @label = new St.Label(
      text: _("Recent Files")
      style_class: "menu-category-button-label"
    )
    @icon = new St.Icon(
      icon_name: "folder-recent"
      icon_size: CATEGORY_ICON_SIZE
      icon_type: St.IconType.FULLCOLOR
    )
    @addActor @icon
    @icon.realize()
    @addActor @label
    @label.realize()
    return

FavoritesButton:: =
  __proto__: GenericApplicationButton::
  _init: (appsMenuButton, app, nbFavorites) ->
    GenericApplicationButton::_init.call this, appsMenuButton, app
    monitorHeight = Main.layoutManager.primaryMonitor.height
    real_size = (0.7 * monitorHeight) / nbFavorites
    icon_size = 0.6 * real_size / global.ui_scale
    icon_size = MAX_FAV_ICON_SIZE  if icon_size > MAX_FAV_ICON_SIZE
    @actor.style = "padding-top: " + (icon_size / 3) + "px;padding-bottom: " + (icon_size / 3) + "px; margin:auto;"
    @actor.add_style_class_name "menu-favorites-button"
    icon = app.create_icon_texture(icon_size)
    @addActor icon
    icon.realize()
    @_draggable = DND.makeDraggable(@actor)
    @_draggable.connect "drag-end", Lang.bind(this, @_onDragEnd)
    @isDraggableApp = true
    return

  _onDragEnd: ->
    @actor.get_parent()._delegate._clearDragPlaceholder()
    return

  get_app_id: ->
    @app.get_id()

  getDragActor: ->
    new Clutter.Clone(source: @actor)

  getDragActorSource: ->
    @actor

SystemButton:: =
  __proto__: PopupMenu.PopupSubMenuMenuItem::
  _init: (appsMenuButton, icon, nbFavorites, name, desc) ->
    PopupMenu.PopupBaseMenuItem::_init.call this,
      hover: false

    @name = name
    @desc = desc
    monitorHeight = Main.layoutManager.primaryMonitor.height
    real_size = (0.7 * monitorHeight) / nbFavorites
    icon_size = 0.6 * real_size / global.ui_scale
    icon_size = MAX_FAV_ICON_SIZE  if icon_size > MAX_FAV_ICON_SIZE
    @actor.style = "padding-top: " + (icon_size / 3) + "px;padding-bottom: " + (icon_size / 3) + "px; margin:auto;"
    @actor.add_style_class_name "menu-favorites-button"
    iconObj = new St.Icon(
      icon_name: icon
      icon_size: icon_size
      icon_type: St.IconType.FULLCOLOR
    )
    @addActor iconObj
    iconObj.realize()
    return

  _onButtonReleaseEvent: (actor, event) ->
    @activate()  if event.get_button() is 1
    return

CategoriesApplicationsBox:: =
  _init: ->
    @actor = new St.BoxLayout()
    @actor._delegate = this
    return

  acceptDrop: (source, actor, x, y, time) ->
    if source instanceof FavoritesButton
      source.actor.destroy()
      actor.destroy()
      AppFavorites.getAppFavorites().removeFavorite source.app.get_id()
      return true
    false

FavoritesBox:: =
  _init: ->
    @actor = new St.BoxLayout(vertical: true)
    @actor._delegate = this
    @_dragPlaceholder = null
    @_dragPlaceholderPos = -1
    @_animatingPlaceholdersCount = 0
    return

  _clearDragPlaceholder: ->
    if @_dragPlaceholder
      @_dragPlaceholder.animateOutAndDestroy()
      @_dragPlaceholder = null
      @_dragPlaceholderPos = -1
    return

  handleDragOver: (source, actor, x, y, time) ->
    app = source.app
    favorites = AppFavorites.getAppFavorites().getFavorites()
    numFavorites = favorites.length
    favPos = favorites.indexOf(app)
    children = @actor.get_children()
    numChildren = children.length
    boxHeight = @actor.height
    if @_dragPlaceholder
      boxHeight -= @_dragPlaceholder.actor.height
      numChildren--
    pos = Math.round(y * numChildren / boxHeight)
    if pos isnt @_dragPlaceholderPos and pos <= numFavorites
      if @_animatingPlaceholdersCount > 0
        appChildren = children.filter((actor) ->
          actor._delegate instanceof FavoritesButton
        )
        @_dragPlaceholderPos = children.indexOf(appChildren[pos])
      else
        @_dragPlaceholderPos = pos
      if favPos isnt -1 and (pos is favPos or pos is favPos + 1)
        if @_dragPlaceholder
          @_dragPlaceholder.animateOutAndDestroy()
          @_animatingPlaceholdersCount++
          @_dragPlaceholder.actor.connect "destroy", Lang.bind(this, ->
            @_animatingPlaceholdersCount--
            return
          )
        @_dragPlaceholder = null
        return DND.DragMotionResult.CONTINUE
      fadeIn = undefined
      if @_dragPlaceholder
        @_dragPlaceholder.actor.destroy()
        fadeIn = false
      else
        fadeIn = true
      @_dragPlaceholder = new DND.GenericDragPlaceholderItem()
      @_dragPlaceholder.child.set_width source.actor.height
      @_dragPlaceholder.child.set_height source.actor.height
      @actor.insert_actor @_dragPlaceholder.actor, @_dragPlaceholderPos
      @_dragPlaceholder.animateIn()  if fadeIn
    DND.DragMotionResult.MOVE_DROP

  acceptDrop: (source, actor, x, y, time) ->
    app = source.app
    id = app.get_id()
    favorites = AppFavorites.getAppFavorites().getFavoriteMap()
    srcIsFavorite = (id of favorites)
    favPos = 0
    children = @actor.get_children()
    i = 0

    while i < @_dragPlaceholderPos
      continue  if @_dragPlaceholder and children[i] is @_dragPlaceholder.actor
      continue  unless children[i]._delegate instanceof FavoritesButton
      childId = children[i]._delegate.app.get_id()
      continue  if childId is id
      favPos++  if childId of favorites
      i++
    Meta.later_add Meta.LaterType.BEFORE_REDRAW, Lang.bind(this, ->
      appFavorites = AppFavorites.getAppFavorites()
      if srcIsFavorite
        appFavorites.moveFavoriteToPos id, favPos
      else
        appFavorites.addFavoriteAtPos id, favPos
      false
    )
    true

MyApplet:: =
  __proto__: Applet.TextIconApplet::
  _init: (orientation, panel_height, instance_id) ->
    Applet.TextIconApplet::_init.call this, orientation, panel_height, instance_id
    @initial_load_done = false
    @set_applet_tooltip _("Menu")
    @menuManager = new PopupMenu.PopupMenuManager(this)
    @menu = new Applet.AppletPopupMenu(this, orientation)
    @menuManager.addMenu @menu
    @actor.connect "key-press-event", Lang.bind(this, @_onSourceKeyPress)
    @settings = new Settings.AppletSettings(this, "menuz@darkoverlordofdata.com", instance_id)
    @settings.bindProperty Settings.BindingDirection.IN, "show-places", "showPlaces", @_refreshBelowApps, null
    @settings.bindProperty Settings.BindingDirection.IN, "activate-on-hover", "activateOnHover", @_updateActivateOnHover, null
    @_updateActivateOnHover()
    @menu.actor.add_style_class_name "menu-background"
    @menu.connect "open-state-changed", Lang.bind(this, @_onOpenStateChanged)
    @settings.bindProperty Settings.BindingDirection.IN, "menu-icon-custom", "menuIconCustom", @_updateIconAndLabel, null
    @settings.bindProperty Settings.BindingDirection.IN, "menu-icon", "menuIcon", @_updateIconAndLabel, null
    @settings.bindProperty Settings.BindingDirection.IN, "menu-label", "menuLabel", @_updateIconAndLabel, null
    @settings.bindProperty Settings.BindingDirection.IN, "overlay-key", "overlayKey", @_updateKeybinding, null
    @_updateKeybinding()
    Main.themeManager.connect "theme-set", Lang.bind(this, @_updateIconAndLabel)
    @_updateIconAndLabel()
    @_searchInactiveIcon = new St.Icon(
      style_class: "menu-search-entry-icon"
      icon_name: "edit-find"
      icon_type: St.IconType.SYMBOLIC
    )
    @_searchActiveIcon = new St.Icon(
      style_class: "menu-search-entry-icon"
      icon_name: "edit-clear"
      icon_type: St.IconType.SYMBOLIC
    )
    @_searchIconClickedId = 0
    @_applicationsButtons = new Array()
    @_applicationsButtonFromApp = new Object()
    @_favoritesButtons = new Array()
    @_placesButtons = new Array()
    @_transientButtons = new Array()
    @_recentButtons = new Array()
    @_categoryButtons = new Array()
    @_searchProviderButtons = new Array()
    @_selectedItemIndex = null
    @_previousSelectedActor = null
    @_previousVisibleIndex = null
    @_previousTreeSelectedActor = null
    @_activeContainer = null
    @_activeActor = null
    @_applicationsBoxWidth = 0
    @menuIsOpening = false
    @_knownApps = new Array()
    @_appsWereRefreshed = false
    @_canUninstallApps = GLib.file_test("/usr/bin/cinnamon-remove-application", GLib.FileTest.EXISTS)
    @RecentManager = new DocInfo.DocManager()
    @privacy_settings = new Gio.Settings(schema_id: PRIVACY_SCHEMA)
    @_display()
    appsys.connect "installed-changed", Lang.bind(this, @_refreshAll)
    AppFavorites.getAppFavorites().connect "changed", Lang.bind(this, @_refreshFavs)
    @settings.bindProperty Settings.BindingDirection.IN, "hover-delay", "hover_delay_ms", @_update_hover_delay, null
    @_update_hover_delay()
    Main.placesManager.connect "places-updated", Lang.bind(this, @_refreshBelowApps)
    @RecentManager.connect "changed", Lang.bind(this, @_refreshRecent)
    @privacy_settings.connect "changed::" + REMEMBER_RECENT_KEY, Lang.bind(this, @_refreshRecent)
    @_fileFolderAccessActive = false
    @_pathCompleter = new Gio.FilenameCompleter()
    @_pathCompleter.set_dirs_only false
    @lastAcResults = new Array()
    @settings.bindProperty Settings.BindingDirection.IN, "search-filesystem", "searchFilesystem", null, null
    @_refreshAll()
    St.TextureCache.get_default().connect "icon-theme-changed", Lang.bind(this, @onIconThemeChanged)
    @_recalc_height()
    return

  _updateKeybinding: ->
    Main.keybindingManager.addHotKey "overlay-key", @overlayKey, Lang.bind(this, ->
      @menu.toggle_with_options false  if not Main.overview.visible and not Main.expo.visible
      return
    )
    return

  onIconThemeChanged: ->
    @_refreshAll()
    return

  _refreshAll: ->
    @_refreshApps()
    @_refreshFavs()
    @_refreshPlaces()
    @_refreshRecent()
    return

  _refreshBelowApps: ->
    @_refreshPlaces()
    @_refreshRecent()
    return

  openMenu: ->
    @menu.open false  unless @_applet_context_menu.isOpen
    return

  _updateActivateOnHover: ->
    if @_openMenuId
      @actor.disconnect @_openMenuId
      @_openMenuId = 0
    @_openMenuId = @actor.connect("enter-event", Lang.bind(this, @openMenu))  if @activateOnHover
    return

  _update_hover_delay: ->
    @hover_delay = @hover_delay_ms / 1000
    return

  _recalc_height: ->
    scrollBoxHeight = (@leftBox.get_allocation_box().y2 - @leftBox.get_allocation_box().y1) - (@searchBox.get_allocation_box().y2 - @searchBox.get_allocation_box().y1)
    @applicationsScrollBox.style = "height: " + scrollBoxHeight / global.ui_scale + "px;"
    return

  on_orientation_changed: (orientation) ->
    @menu.destroy()
    @menu = new Applet.AppletPopupMenu(this, orientation)
    @menuManager.addMenu @menu
    @menu.actor.add_style_class_name "menu-background"
    @menu.connect "open-state-changed", Lang.bind(this, @_onOpenStateChanged)
    @_display()
    @_refreshAll()  if @initial_load_done
    return

  on_applet_added_to_panel: ->
    @initial_load_done = true
    return

  _launch_editor: ->
    Util.spawnCommandLine "cinnamon-menu-editor"
    return

  on_applet_clicked: (event) ->
    @menu.toggle_with_options false
    return

  _onSourceKeyPress: (actor, event) ->
    symbol = event.get_key_symbol()
    if symbol is Clutter.KEY_space or symbol is Clutter.KEY_Return
      @menu.toggle()
      true
    else if symbol is Clutter.KEY_Escape and @menu.isOpen
      @menu.close()
      true
    else if symbol is Clutter.KEY_Down
      @menu.toggle()  unless @menu.isOpen
      @menu.actor.navigate_focus @actor, Gtk.DirectionType.DOWN, false
      true
    else
      false

  _onOpenStateChanged: (menu, open) ->
    if open
      @menuIsOpening = true
      @actor.add_style_pseudo_class "active"
      global.stage.set_key_focus @searchEntry
      @_selectedItemIndex = null
      @_activeContainer = null
      @_activeActor = null
      n = Math.min(@_applicationsButtons.length, INITIAL_BUTTON_LOAD)
      i = 0

      while i < n
        @_applicationsButtons[i].actor.show()
        i++
      @_allAppsCategoryButton.actor.style_class = "menu-category-button-selected"
      Mainloop.idle_add Lang.bind(this, @_initial_cat_selection, n)
    else
      @actor.remove_style_pseudo_class "active"
      @resetSearch()  if @searchActive
      @selectedAppTitle.set_text ""
      @selectedAppDescription.set_text ""
      @_previousTreeSelectedActor = null
      @_previousSelectedActor = null
      @closeContextMenus null, false
      @_clearAllSelections false
      @destroyVectorBox()
    return

  _initial_cat_selection: (start_index) ->
    n = @_applicationsButtons.length
    i = start_index

    while i < n
      @_applicationsButtons[i].actor.show()
      i++
    return

  destroy: ->
    @actor._delegate = null
    @menu.destroy()
    @actor.destroy()
    @emit "destroy"
    return

  _set_default_menu_icon: ->
    path = global.datadir + "/theme/menu.svg"
    if GLib.file_test(path, GLib.FileTest.EXISTS)
      @set_applet_icon_path path
      return
    path = global.datadir + "/theme/menu-symbolic.svg"
    if GLib.file_test(path, GLib.FileTest.EXISTS)
      @set_applet_icon_symbolic_path path
      return
    @set_applet_icon_path ""
    return

  _updateIconAndLabel: ->
    try
      if @menuIconCustom
        if @menuIcon is ""
          @set_applet_icon_name ""
        else if GLib.path_is_absolute(@menuIcon) and GLib.file_test(@menuIcon, GLib.FileTest.EXISTS)
          unless @menuIcon.search("-symbolic") is -1
            @set_applet_icon_symbolic_path @menuIcon
          else
            @set_applet_icon_path @menuIcon
        else if Gtk.IconTheme.get_default().has_icon(@menuIcon)
          unless @menuIcon.search("-symbolic") is -1
            @set_applet_icon_symbolic_name @menuIcon
          else
            @set_applet_icon_name @menuIcon
      else
        @_set_default_menu_icon()
    catch e
      global.logWarning "Could not load icon file \"" + @menuIcon + "\" for menu button"
    if @menuIconCustom and @menuIcon is ""
      @_applet_icon_box.hide()
    else
      @_applet_icon_box.show()
    unless @menuLabel is ""
      @set_applet_label _(@menuLabel)
    else
      @set_applet_label ""
    return

  _onMenuKeyPress: (actor, event) ->
    symbol = event.get_key_symbol()
    item_actor = undefined
    index = 0
    @appBoxIter.reloadVisible()
    @catBoxIter.reloadVisible()
    @favBoxIter.reloadVisible()
    keyCode = event.get_key_code()
    modifierState = Cinnamon.get_event_state(event)
    action = global.display.get_keybinding_action(keyCode, modifierState)
    return true  if action is Meta.KeyBindingAction.CUSTOM
    index = @_selectedItemIndex
    if @_activeContainer is null and symbol is Clutter.KEY_Up
      @_activeContainer = @applicationsBox
      item_actor = @appBoxIter.getLastVisible()
      index = @appBoxIter.getAbsoluteIndexOfChild(item_actor)
      @_scrollToButton item_actor._delegate
    else if @_activeContainer is null and symbol is Clutter.KEY_Down
      @_activeContainer = @applicationsBox
      item_actor = @appBoxIter.getFirstVisible()
      index = @appBoxIter.getAbsoluteIndexOfChild(item_actor)
      @_scrollToButton item_actor._delegate
    else if @_activeContainer is null and symbol is Clutter.KEY_Left
      @_activeContainer = @favoritesBox
      item_actor = @favBoxIter.getFirstVisible()
      index = @favBoxIter.getAbsoluteIndexOfChild(item_actor)
    else if symbol is Clutter.KEY_Up
      unless @_activeContainer is @categoriesBox
        @_previousSelectedActor = @_activeContainer.get_child_at_index(index)
        item_actor = @_activeContainer._vis_iter.getPrevVisible(@_previousSelectedActor)
        @_previousVisibleIndex = @_activeContainer._vis_iter.getVisibleIndex(item_actor)
        index = @_activeContainer._vis_iter.getAbsoluteIndexOfChild(item_actor)
        @_scrollToButton item_actor._delegate
      else
        @_previousTreeSelectedActor = @categoriesBox.get_child_at_index(index)
        @_previousTreeSelectedActor._delegate.isHovered = false
        item_actor = @catBoxIter.getPrevVisible(@_activeActor)
        index = @catBoxIter.getAbsoluteIndexOfChild(item_actor)
    else if symbol is Clutter.KEY_Down
      unless @_activeContainer is @categoriesBox
        @_previousSelectedActor = @_activeContainer.get_child_at_index(index)
        item_actor = @_activeContainer._vis_iter.getNextVisible(@_previousSelectedActor)
        @_previousVisibleIndex = @_activeContainer._vis_iter.getVisibleIndex(item_actor)
        index = @_activeContainer._vis_iter.getAbsoluteIndexOfChild(item_actor)
        @_scrollToButton item_actor._delegate
      else
        @_previousTreeSelectedActor = @categoriesBox.get_child_at_index(index)
        @_previousTreeSelectedActor._delegate.isHovered = false
        item_actor = @catBoxIter.getNextVisible(@_activeActor)
        index = @catBoxIter.getAbsoluteIndexOfChild(item_actor)
        @_previousTreeSelectedActor._delegate.emit "leave-event"
    else if symbol is Clutter.KEY_Right and (@_activeContainer isnt @applicationsBox)
      if @_activeContainer is @categoriesBox
        if @_previousVisibleIndex isnt null
          item_actor = @appBoxIter.getVisibleItem(@_previousVisibleIndex)
        else
          item_actor = @appBoxIter.getFirstVisible()
      else
        item_actor = (if (@_previousTreeSelectedActor?) then @_previousTreeSelectedActor else @catBoxIter.getFirstVisible())
        index = @catBoxIter.getAbsoluteIndexOfChild(item_actor)
        @_previousTreeSelectedActor = item_actor
      index = item_actor.get_parent()._vis_iter.getAbsoluteIndexOfChild(item_actor)
    else if symbol is Clutter.KEY_Left and @_activeContainer is @applicationsBox and not @searchActive
      @_previousSelectedActor = @applicationsBox.get_child_at_index(index)
      item_actor = (if (@_previousTreeSelectedActor?) then @_previousTreeSelectedActor else @catBoxIter.getFirstVisible())
      index = @catBoxIter.getAbsoluteIndexOfChild(item_actor)
      @_previousTreeSelectedActor = item_actor
    else if symbol is Clutter.KEY_Left and @_activeContainer is @categoriesBox and not @searchActive
      @_previousSelectedActor = @categoriesBox.get_child_at_index(index)
      item_actor = @favBoxIter.getFirstVisible()
      index = @favBoxIter.getAbsoluteIndexOfChild(item_actor)
    else if @_activeContainer isnt @categoriesBox and (symbol is Clutter.KEY_Return or symbol is Clutter.KP_Enter)
      item_actor = @_activeContainer.get_child_at_index(@_selectedItemIndex)
      item_actor._delegate.activate()
      return true
    else if @searchFilesystem and (@_fileFolderAccessActive or symbol is Clutter.slash)
      if symbol is Clutter.Return or symbol is Clutter.KP_Enter
        @menu.close()  if @_run(@searchEntry.get_text())
        return true
      if symbol is Clutter.Escape
        @searchEntry.set_text ""
        @_fileFolderAccessActive = false
      if symbol is Clutter.slash
        text = @searchEntry.get_text().concat("/a")
        prefix = undefined
        if text.lastIndexOf(" ") is -1
          prefix = text
        else
          prefix = text.substr(text.lastIndexOf(" ") + 1)
        @_getCompletion prefix
        return false
      if symbol is Clutter.Tab
        text = actor.get_text()
        prefix = undefined
        if text.lastIndexOf(" ") is -1
          prefix = text
        else
          prefix = text.substr(text.lastIndexOf(" ") + 1)
        postfix = @_getCompletion(prefix)
        if postfix? and postfix.length > 0
          actor.insert_text postfix, -1
          actor.set_cursor_position text.length + postfix.length
          @_getCompletion text + postfix + "a"  if postfix[postfix.length - 1] is "/"
        return true
      return false
    else
      return false
    @_selectedItemIndex = index
    return false  if not item_actor or item_actor is @searchEntry
    item_actor._delegate.emit "enter-event"
    true

  _addEnterEvent: (button, callback) ->
    _callback = Lang.bind(this, ->
      parent = button.actor.get_parent()
      if @_activeContainer is @categoriesBox and parent isnt @_activeContainer
        @_previousTreeSelectedActor = @_activeActor
        @_previousSelectedActor = null
      @_previousTreeSelectedActor.style_class = "menu-category-button"  if @_previousTreeSelectedActor and @_activeContainer isnt @categoriesBox and parent isnt @_activeContainer and button isnt @_previousTreeSelectedActor and not @searchActive
      parent._vis_iter.reloadVisible()  unless parent is @_activeContainer
      _maybePreviousActor = @_activeActor
      if _maybePreviousActor and @_activeContainer isnt @categoriesBox
        @_previousSelectedActor = _maybePreviousActor
        @_clearPrevSelection()
      if parent is @categoriesBox and not @searchActive
        @_previousSelectedActor = _maybePreviousActor
        @_clearPrevCatSelection()
      @_activeContainer = parent
      @_activeActor = button.actor
      @_selectedItemIndex = @_activeContainer._vis_iter.getAbsoluteIndexOfChild(@_activeActor)
      callback()
      return
    )
    button.connect "enter-event", _callback
    button.actor.connect "enter-event", _callback
    return

  _clearPrevSelection: (actor) ->
    if @_previousSelectedActor and @_previousSelectedActor isnt actor
      if @_previousSelectedActor._delegate instanceof ApplicationButton or @_previousSelectedActor._delegate instanceof RecentButton or @_previousSelectedActor._delegate instanceof SearchProviderResultButton or @_previousSelectedActor._delegate instanceof PlaceButton or @_previousSelectedActor._delegate instanceof RecentClearButton
        @_previousSelectedActor.style_class = "menu-application-button"
      else @_previousSelectedActor.remove_style_pseudo_class "hover"  if @_previousSelectedActor._delegate instanceof FavoritesButton or @_previousSelectedActor._delegate instanceof SystemButton
    return

  _clearPrevCatSelection: (actor) ->
    if @_previousTreeSelectedActor and @_previousTreeSelectedActor isnt actor
      @_previousTreeSelectedActor.style_class = "menu-category-button"
      @_previousTreeSelectedActor._delegate.emit "leave-event"  if @_previousTreeSelectedActor._delegate
      if actor isnt `undefined`
        @_previousVisibleIndex = null
        @_previousTreeSelectedActor = actor
    else
      @categoriesBox.get_children().forEach Lang.bind(this, (child) ->
        child.style_class = "menu-category-button"
        return
      )
    return

  makeVectorBox: (actor) ->
    @destroyVectorBox actor
    ] = global.get_pointer()
    ] = @categoriesApplicationsBox.actor.get_transformed_position()
    ] = @categoriesApplicationsBox.actor.get_transformed_size()
    ] = actor.get_transformed_size()
    ] = actor.get_transformed_position()
    ] = @applicationsBox.get_transformed_position()
    right_x = appbox_x - bx
    xformed_mouse_x = mx - bx
    xformed_mouse_y = my - by_
    w = Math.max(right_x - xformed_mouse_x, 0)
    ulc_y = xformed_mouse_y + 0
    llc_y = xformed_mouse_y + 0
    @vectorBox = new St.Polygon(
      debug: false
      width: w
      height: bh
      ulc_x: 0
      ulc_y: ulc_y
      llc_x: 0
      llc_y: llc_y
      urc_x: w
      urc_y: 0
      lrc_x: w
      lrc_y: bh
    )
    @categoriesApplicationsBox.actor.add_actor @vectorBox
    @vectorBox.set_position xformed_mouse_x, 0
    @vectorBox.show()
    @vectorBox.set_reactive true
    @vectorBox.raise_top()
    @vectorBox.connect "leave-event", Lang.bind(this, @destroyVectorBox)
    @vectorBox.connect "motion-event", Lang.bind(this, @maybeUpdateVectorBox)
    @actor_motion_id = actor.connect("motion-event", Lang.bind(this, @maybeUpdateVectorBox))
    @current_motion_actor = actor
    return

  maybeUpdateVectorBox: ->
    if @vector_update_loop
      Mainloop.source_remove @vector_update_loop
      @vector_update_loop = 0
    @vector_update_loop = Mainloop.timeout_add(35, Lang.bind(this, @updateVectorBox))
    return

  updateVectorBox: (actor) ->
    if @vectorBox
      ] = global.get_pointer()
      ] = @categoriesApplicationsBox.actor.get_transformed_position()
      xformed_mouse_x = mx - bx
      ] = @applicationsBox.get_transformed_position()
      right_x = appbox_x - bx
      if (right_x - xformed_mouse_x) > 0
        @vectorBox.width = Math.max(right_x - xformed_mouse_x, 0)
        @vectorBox.set_position xformed_mouse_x, 0
        @vectorBox.urc_x = @vectorBox.width
        @vectorBox.lrc_x = @vectorBox.width
        @vectorBox.queue_repaint()
      else
        @destroyVectorBox actor
    @vector_update_loop = 0
    false

  destroyVectorBox: (actor) ->
    if @vectorBox?
      @vectorBox.destroy()
      @vectorBox = null
    if @actor_motion_id > 0 and @current_motion_actor?
      @current_motion_actor.disconnect @actor_motion_id
      @actor_motion_id = 0
      @current_motion_actor = null
    return

  _refreshPlaces: ->
    i = 0

    while i < @_placesButtons.length
      @_placesButtons[i].actor.destroy()
      i++
    i = 0

    while i < @_categoryButtons.length
      @_categoryButtons[i].actor.destroy()  if @_categoryButtons[i] instanceof PlaceCategoryButton
      i++
    @_placesButtons = new Array()
    if @showPlaces
      @placesButton = new PlaceCategoryButton()
      @_addEnterEvent @placesButton, Lang.bind(this, ->
        unless @searchActive
          @placesButton.isHovered = true
          if @hover_delay > 0
            Tweener.addTween this,
              time: @hover_delay
              onComplete: ->
                if @placesButton.isHovered
                  @_clearPrevCatSelection @placesButton
                  @placesButton.actor.style_class = "menu-category-button-selected"
                  @closeContextMenus null, false
                  @_displayButtons null, -1
                else
                  @placesButton.actor.style_class = "menu-category-button"
                return

          else
            @_clearPrevCatSelection @placesButton
            @placesButton.actor.style_class = "menu-category-button-selected"
            @closeContextMenus null, false
            @_displayButtons null, -1
          @makeVectorBox @placesButton.actor
        return
      )
      @placesButton.actor.connect "leave-event", Lang.bind(this, ->
        if @_previousTreeSelectedActor is null
          @_previousTreeSelectedActor = @placesButton.actor
        else
          prevIdx = @catBoxIter.getVisibleIndex(@_previousTreeSelectedActor)
          nextIdx = @catBoxIter.getVisibleIndex(@placesButton.actor)
          idxDiff = Math.abs(prevIdx - nextIdx)
          @_previousTreeSelectedActor = @placesButton.actor  if idxDiff <= 1 or Math.min(prevIdx, nextIdx) < 0
        @placesButton.isHovered = false
        return
      )
      @_categoryButtons.push @placesButton
      @categoriesBox.add_actor @placesButton.actor
      bookmarks = @_listBookmarks()
      devices = @_listDevices()
      places = bookmarks.concat(devices)
      i = 0

      while i < places.length
        place = places[i]
        button = new PlaceButton(this, place, place.name)
        @_addEnterEvent button, Lang.bind(this, ->
          @_clearPrevSelection button.actor
          button.actor.style_class = "menu-application-button-selected"
          @selectedAppTitle.set_text ""
          @selectedAppDescription.set_text button.place.id.slice(16).replace(/%20/g, " ")
          return
        )
        button.actor.connect "leave-event", Lang.bind(this, ->
          @_previousSelectedActor = button.actor
          @selectedAppTitle.set_text ""
          @selectedAppDescription.set_text ""
          return
        )
        @_placesButtons.push button
        @applicationsBox.add_actor button.actor
        i++
    @_setCategoriesButtonActive not @searchActive
    @_recalc_height()
    @_resizeApplicationsBox()
    return

  _refreshRecent: ->
    i = 0

    while i < @_recentButtons.length
      @_recentButtons[i].actor.destroy()
      i++
    i = 0

    while i < @_categoryButtons.length
      @_categoryButtons[i].actor.destroy()  if @_categoryButtons[i] instanceof RecentCategoryButton
      i++
    @_recentButtons = new Array()
    if @privacy_settings.get_boolean(REMEMBER_RECENT_KEY)
      @recentButton = new RecentCategoryButton()
      @_addEnterEvent @recentButton, Lang.bind(this, ->
        unless @searchActive
          @recentButton.isHovered = true
          if @hover_delay > 0
            Tweener.addTween this,
              time: @hover_delay
              onComplete: ->
                if @recentButton.isHovered
                  @_clearPrevCatSelection @recentButton.actor
                  @recentButton.actor.style_class = "menu-category-button-selected"
                  @closeContextMenus null, false
                  @_displayButtons null, null, -1
                else
                  @recentButton.actor.style_class = "menu-category-button"
                return

          else
            @_clearPrevCatSelection @recentButton.actor
            @recentButton.actor.style_class = "menu-category-button-selected"
            @closeContextMenus null, false
            @_displayButtons null, null, -1
          @makeVectorBox @recentButton.actor
        return
      )
      @recentButton.actor.connect "leave-event", Lang.bind(this, ->
        if @_previousTreeSelectedActor is null
          @_previousTreeSelectedActor = @recentButton.actor
        else
          prevIdx = @catBoxIter.getVisibleIndex(@_previousTreeSelectedActor)
          nextIdx = @catBoxIter.getVisibleIndex(@recentButton.actor)
          @_previousTreeSelectedActor = @recentButton.actor  if Math.abs(prevIdx - nextIdx) <= 1
        @recentButton.isHovered = false
        return
      )
      @categoriesBox.add_actor @recentButton.actor
      @_categoryButtons.push @recentButton
      if @RecentManager._infosByTimestamp.length > 0
        id = 0

        while id < MAX_RECENT_FILES and id < @RecentManager._infosByTimestamp.length
          button = new RecentButton(this, @RecentManager._infosByTimestamp[id])
          @_addEnterEvent button, Lang.bind(this, ->
            @_clearPrevSelection button.actor
            button.actor.style_class = "menu-application-button-selected"
            @selectedAppTitle.set_text ""
            @selectedAppDescription.set_text button.file.uri.slice(7).replace(/%20/g, " ")
            return
          )
          button.actor.connect "leave-event", Lang.bind(this, ->
            button.actor.style_class = "menu-application-button"
            @_previousSelectedActor = button.actor
            @selectedAppTitle.set_text ""
            @selectedAppDescription.set_text ""
            return
          )
          @_recentButtons.push button
          @applicationsBox.add_actor button.actor
          @applicationsBox.add_actor button.menu.actor
          id++
        button = new RecentClearButton(this)
        @_addEnterEvent button, Lang.bind(this, ->
          @_clearPrevSelection button.actor
          button.actor.style_class = "menu-application-button-selected"
          return
        )
        button.actor.connect "leave-event", Lang.bind(this, ->
          button.actor.style_class = "menu-application-button"
          @_previousSelectedActor = button.actor
          return
        )
        @_recentButtons.push button
        @applicationsBox.add_actor button.actor
      else
        button = new GenericButton(_("No recent documents"), null, false, null)
        @_recentButtons.push button
        @applicationsBox.add_actor button.actor
    @_setCategoriesButtonActive not @searchActive
    @_recalc_height()
    @_resizeApplicationsBox()
    return

  _refreshApps: ->
    @applicationsBox.destroy_all_children()
    @_applicationsButtons = new Array()
    @_transientButtons = new Array()
    @_applicationsButtonFromApp = new Object()
    @_applicationsBoxWidth = 0
    @categoriesBox.destroy_all_children()
    @_allAppsCategoryButton = new CategoryButton(null)
    @_addEnterEvent @_allAppsCategoryButton, Lang.bind(this, ->
      unless @searchActive
        @_allAppsCategoryButton.isHovered = true
        if @hover_delay > 0
          Tweener.addTween this,
            time: @hover_delay
            onComplete: ->
              if @_allAppsCategoryButton.isHovered
                @_clearPrevCatSelection @_allAppsCategoryButton.actor
                @_allAppsCategoryButton.actor.style_class = "menu-category-button-selected"
                @_select_category null, @_allAppsCategoryButton
              else
                @_allAppsCategoryButton.actor.style_class = "menu-category-button"
              return

        else
          @_clearPrevCatSelection @_allAppsCategoryButton.actor
          @_allAppsCategoryButton.actor.style_class = "menu-category-button-selected"
          @_select_category null, @_allAppsCategoryButton
        @makeVectorBox @_allAppsCategoryButton.actor
      return
    )
    @_allAppsCategoryButton.actor.connect "leave-event", Lang.bind(this, ->
      @_previousSelectedActor = @_allAppsCategoryButton.actor
      @_allAppsCategoryButton.isHovered = false
      return
    )
    @categoriesBox.add_actor @_allAppsCategoryButton.actor
    trees = [appsys.get_tree()]
    for i of trees
      tree = trees[i]
      root = tree.get_root_directory()
      dirs = []
      iter = root.iter()
      nextType = undefined
      dirs.push iter.get_directory()  if nextType is CMenu.TreeItemType.DIRECTORY  until (nextType = iter.next()) is CMenu.TreeItemType.INVALID
      prefCats = [
        "administration"
        "preferences"
      ]
      dirs = dirs.sort((a, b) ->
        menuIdA = a.get_menu_id().toLowerCase()
        menuIdB = b.get_menu_id().toLowerCase()
        prefIdA = prefCats.indexOf(menuIdA)
        prefIdB = prefCats.indexOf(menuIdB)
        return -1  if prefIdA < 0 and prefIdB >= 0
        return 1  if prefIdA >= 0 and prefIdB < 0
        nameA = a.get_name().toLowerCase()
        nameB = b.get_name().toLowerCase()
        return 1  if nameA > nameB
        return -1  if nameA < nameB
        0
      )
      i = 0

      while i < dirs.length
        dir = dirs[i]
        continue  if dir.get_is_nodisplay()
        if @_loadCategory(dir)
          categoryButton = new CategoryButton(dir)
          @_addEnterEvent categoryButton, Lang.bind(this, ->
            unless @searchActive
              categoryButton.isHovered = true
              if @hover_delay > 0
                Tweener.addTween this,
                  time: @hover_delay
                  onComplete: ->
                    if categoryButton.isHovered
                      @_clearPrevCatSelection categoryButton.actor
                      categoryButton.actor.style_class = "menu-category-button-selected"
                      @_select_category dir, categoryButton
                    else
                      categoryButton.actor.style_class = "menu-category-button"
                    return

              else
                @_clearPrevCatSelection categoryButton.actor
                categoryButton.actor.style_class = "menu-category-button-selected"
                @_select_category dir, categoryButton
              @makeVectorBox categoryButton.actor
            return
          )
          categoryButton.actor.connect "leave-event", Lang.bind(this, ->
            if @_previousTreeSelectedActor is null
              @_previousTreeSelectedActor = categoryButton.actor
            else
              prevIdx = @catBoxIter.getVisibleIndex(@_previousTreeSelectedActor)
              nextIdx = @catBoxIter.getVisibleIndex(categoryButton.actor)
              @_previousTreeSelectedActor = categoryButton.actor  if Math.abs(prevIdx - nextIdx) <= 1
            categoryButton.isHovered = false
            return
          )
          @categoriesBox.add_actor categoryButton.actor
        i++
    @_applicationsButtons.sort (a, b) ->
      a = Util.latinise(a.app.get_name().toLowerCase())
      b = Util.latinise(b.app.get_name().toLowerCase())
      a > b

    i = 0

    while i < @_applicationsButtons.length
      @applicationsBox.add_actor @_applicationsButtons[i].actor
      @applicationsBox.add_actor @_applicationsButtons[i].menu.actor
      i++
    @_appsWereRefreshed = true
    return

  _favEnterEvent: (button) ->
    button.actor.add_style_pseudo_class "hover"
    if button instanceof FavoritesButton
      @selectedAppTitle.set_text button.app.get_name()
      if button.app.get_description()
        @selectedAppDescription.set_text button.app.get_description().split("\n")[0]
      else
        @selectedAppDescription.set_text ""
    else
      @selectedAppTitle.set_text button.name
      @selectedAppDescription.set_text button.desc
    return

  _favLeaveEvent: (widget, event, button) ->
    @_previousSelectedActor = button.actor
    button.actor.remove_style_pseudo_class "hover"
    @selectedAppTitle.set_text ""
    @selectedAppDescription.set_text ""
    return

  _refreshFavs: ->
    @favoritesBox.destroy_all_children()
    @_favoritesButtons = new Array()
    launchers = global.settings.get_strv("favorite-apps")
    appSys = Cinnamon.AppSystem.get_default()
    j = 0
    i = 0

    while i < launchers.length
      app = appSys.lookup_app(launchers[i])
      if app
        button = new FavoritesButton(this, app, launchers.length + 3)
        @_favoritesButtons[app] = button
        @favoritesBox.add_actor button.actor,
          y_align: St.Align.END
          y_fill: false

        @_addEnterEvent button, Lang.bind(this, @_favEnterEvent, button)
        button.actor.connect "leave-event", Lang.bind(this, @_favLeaveEvent, button)
        ++j
      ++i
    unless launchers.length is 0
      separator = new PopupMenu.PopupSeparatorMenuItem()
      @favoritesBox.add_actor separator.actor,
        y_align: St.Align.END
        y_fill: false

    button = new SystemButton(this, "system-lock-screen", launchers.length + 3, _("Lock screen"), _("Lock the screen"))
    @_addEnterEvent button, Lang.bind(this, @_favEnterEvent, button)
    button.actor.connect "leave-event", Lang.bind(this, @_favLeaveEvent, button)
    button.activate = Lang.bind(this, ->
      @menu.close()
      screensaver_settings = new Gio.Settings(schema_id: "org.cinnamon.desktop.screensaver")
      screensaver_dialog = Gio.file_new_for_path("/usr/bin/cinnamon-screensaver-command")
      if screensaver_dialog.query_exists(null)
        if screensaver_settings.get_boolean("ask-for-away-message")
          Util.spawnCommandLine "cinnamon-screensaver-lock-dialog"
        else
          Util.spawnCommandLine "cinnamon-screensaver-command --lock"
      else
        @_screenSaverProxy.LockRemote()
      return
    )
    @favoritesBox.add_actor button.actor,
      y_align: St.Align.END
      y_fill: false

    button = new SystemButton(this, "system-log-out", launchers.length + 3, _("Logout"), _("Leave the session"))
    @_addEnterEvent button, Lang.bind(this, @_favEnterEvent, button)
    button.actor.connect "leave-event", Lang.bind(this, @_favLeaveEvent, button)
    button.activate = Lang.bind(this, ->
      @menu.close()
      @_session.LogoutRemote 0
      return
    )
    @favoritesBox.add_actor button.actor,
      y_align: St.Align.END
      y_fill: false

    button = new SystemButton(this, "system-shutdown", launchers.length + 3, _("Quit"), _("Shutdown the computer"))
    @_addEnterEvent button, Lang.bind(this, @_favEnterEvent, button)
    button.actor.connect "leave-event", Lang.bind(this, @_favLeaveEvent, button)
    button.activate = Lang.bind(this, ->
      @menu.close()
      @_session.ShutdownRemote()
      return
    )
    @favoritesBox.add_actor button.actor,
      y_align: St.Align.END
      y_fill: false

    @_recalc_height()
    return

  _loadCategory: (dir, top_dir) ->
    iter = dir.iter()
    has_entries = false
    nextType = undefined
    top_dir = dir  unless top_dir
    until (nextType = iter.next()) is CMenu.TreeItemType.INVALID
      if nextType is CMenu.TreeItemType.ENTRY
        entry = iter.get_entry()
        unless entry.get_app_info().get_nodisplay()
          has_entries = true
          app = appsys.lookup_app_by_tree_entry(entry)
          app = appsys.lookup_settings_app_by_tree_entry(entry)  unless app
          app_key = app.get_id()
          app_key = app.get_name() + ":" + app.get_description()  unless app_key?
          unless app_key of @_applicationsButtonFromApp
            applicationButton = new ApplicationButton(this, app)
            app_is_known = false
            i = 0

            while i < @_knownApps.length
              app_is_known = true  if @_knownApps[i] is app_key
              i++
            unless app_is_known
              if @_appsWereRefreshed
                applicationButton.highlight()
              else
                @_knownApps.push app_key
            applicationButton.actor.connect "leave-event", Lang.bind(this, @_appLeaveEvent, applicationButton)
            @_addEnterEvent applicationButton, Lang.bind(this, @_appEnterEvent, applicationButton)
            @_applicationsButtons.push applicationButton
            applicationButton.category.push top_dir.get_menu_id()
            @_applicationsButtonFromApp[app_key] = applicationButton
          else
            @_applicationsButtonFromApp[app_key].category.push dir.get_menu_id()
      else if nextType is CMenu.TreeItemType.DIRECTORY
        subdir = iter.get_directory()
        has_entries = true  if @_loadCategory(subdir, top_dir)
    has_entries

  _appLeaveEvent: (a, b, applicationButton) ->
    @_previousSelectedActor = applicationButton.actor
    applicationButton.actor.style_class = "menu-application-button"
    @selectedAppTitle.set_text ""
    @selectedAppDescription.set_text ""
    return

  _appEnterEvent: (applicationButton) ->
    @selectedAppTitle.set_text applicationButton.app.get_name()
    if applicationButton.app.get_description()
      @selectedAppDescription.set_text applicationButton.app.get_description()
    else
      @selectedAppDescription.set_text ""
    @_previousVisibleIndex = @appBoxIter.getVisibleIndex(applicationButton.actor)
    @_clearPrevSelection applicationButton.actor
    applicationButton.actor.style_class = "menu-application-button-selected"
    return

  _scrollToButton: (button) ->
    current_scroll_value = @applicationsScrollBox.get_vscroll_bar().get_adjustment().get_value()
    box_height = @applicationsScrollBox.get_allocation_box().y2 - @applicationsScrollBox.get_allocation_box().y1
    new_scroll_value = current_scroll_value
    new_scroll_value = button.actor.get_allocation_box().y1 - 10  if current_scroll_value > button.actor.get_allocation_box().y1 - 10
    new_scroll_value = button.actor.get_allocation_box().y2 - box_height + 10  if box_height + current_scroll_value < button.actor.get_allocation_box().y2 + 10
    @applicationsScrollBox.get_vscroll_bar().get_adjustment().set_value new_scroll_value  unless new_scroll_value is current_scroll_value
    return

  _display: ->
    @_activeContainer = null
    @_activeActor = null
    @vectorBox = null
    @actor_motion_id = 0
    @vector_update_loop = null
    @current_motion_actor = null
    section = new PopupMenu.PopupMenuSection()
    @menu.addMenuItem section
    leftPane = new St.BoxLayout(vertical: true)
    @leftBox = new St.BoxLayout(
      style_class: "menu-favorites-box"
      vertical: true
    )
    @_session = new GnomeSession.SessionManager()
    @_screenSaverProxy = new ScreenSaver.ScreenSaverProxy()
    leftPane.add_actor @leftBox,
      y_align: St.Align.END
      y_fill: false

    rightPane = new St.BoxLayout(vertical: true)
    @searchBox = new St.BoxLayout(style_class: "menu-search-box")
    rightPane.add_actor @searchBox
    @searchEntry = new St.Entry(
      name: "menu-search-entry"
      hint_text: _("Type to search...")
      track_hover: true
      can_focus: true
    )
    @searchEntry.set_secondary_icon @_searchInactiveIcon
    @searchBox.add_actor @searchEntry
    @searchActive = false
    @searchEntryText = @searchEntry.clutter_text
    @searchEntryText.connect "text-changed", Lang.bind(this, @_onSearchTextChanged)
    @searchEntryText.connect "key-press-event", Lang.bind(this, @_onMenuKeyPress)
    @_previousSearchPattern = ""
    @categoriesApplicationsBox = new CategoriesApplicationsBox()
    rightPane.add_actor @categoriesApplicationsBox.actor
    @categoriesBox = new St.BoxLayout(
      style_class: "menu-categories-box"
      vertical: true
      accessible_role: Atk.Role.LIST
    )
    @applicationsScrollBox = new St.ScrollView(
      x_fill: true
      y_fill: false
      y_align: St.Align.START
      style_class: "vfade menu-applications-scrollbox"
    )
    @a11y_settings = new Gio.Settings(schema_id: "org.cinnamon.desktop.a11y.applications")
    @a11y_settings.connect "changed::screen-magnifier-enabled", Lang.bind(this, @_updateVFade)
    @_updateVFade()
    @settings.bindProperty Settings.BindingDirection.IN, "enable-autoscroll", "autoscroll_enabled", @_update_autoscroll, null
    @_update_autoscroll()
    vscroll = @applicationsScrollBox.get_vscroll_bar()
    vscroll.connect "scroll-start", Lang.bind(this, ->
      @menu.passEvents = true
      return
    )
    vscroll.connect "scroll-stop", Lang.bind(this, ->
      @menu.passEvents = false
      return
    )
    @applicationsBox = new St.BoxLayout(
      style_class: "menu-applications-inner-box"
      vertical: true
    )
    @applicationsBox.add_style_class_name "menu-applications-box"
    @applicationsScrollBox.add_actor @applicationsBox
    @applicationsScrollBox.set_policy Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC
    @categoriesApplicationsBox.actor.add_actor @categoriesBox
    @categoriesApplicationsBox.actor.add_actor @applicationsScrollBox
    fav_obj = new FavoritesBox()
    @favoritesBox = fav_obj.actor
    @leftBox.add_actor @favoritesBox,
      y_align: St.Align.END
      y_fill: false

    @mainBox = new St.BoxLayout(
      style_class: "menu-applications-outer-box"
      vertical: false
    )
    @mainBox.add_style_class_name "menu-applications-box"
    @mainBox.add_actor leftPane,
      span: 1

    @mainBox.add_actor rightPane,
      span: 1

    section.actor.add_actor @mainBox
    @selectedAppBox = new St.BoxLayout(
      style_class: "menu-selected-app-box"
      vertical: true
    )
    @selectedAppBox.set_height 30 * global.ui_scale  if not @selectedAppBox.peek_theme_node()? or @selectedAppBox.get_theme_node().get_length("height") is 0
    @selectedAppTitle = new St.Label(
      style_class: "menu-selected-app-title"
      text: ""
    )
    @selectedAppBox.add_actor @selectedAppTitle
    @selectedAppDescription = new St.Label(
      style_class: "menu-selected-app-description"
      text: ""
    )
    @selectedAppBox.add_actor @selectedAppDescription
    section.actor.add_actor @selectedAppBox
    @appBoxIter = new VisibleChildIterator(@applicationsBox)
    @applicationsBox._vis_iter = @appBoxIter
    @catBoxIter = new VisibleChildIterator(@categoriesBox)
    @categoriesBox._vis_iter = @catBoxIter
    @favBoxIter = new VisibleChildIterator(@favoritesBox)
    @favoritesBox._vis_iter = @favBoxIter
    Mainloop.idle_add Lang.bind(this, ->
      @_clearAllSelections true
      return
    )
    return

  _updateVFade: ->
    mag_on = @a11y_settings.get_boolean("screen-magnifier-enabled")
    if mag_on
      @applicationsScrollBox.style_class = "menu-applications-scrollbox"
    else
      @applicationsScrollBox.style_class = "vfade menu-applications-scrollbox"
    return

  _update_autoscroll: ->
    @applicationsScrollBox.set_auto_scrolling @autoscroll_enabled
    return

  _clearAllSelections: (hide_apps) ->
    actors = @applicationsBox.get_children()
    i = 0

    while i < actors.length
      actor = actors[i]
      actor.style_class = "menu-application-button"
      actor.hide()  if hide_apps
      i++
    actors = @categoriesBox.get_children()
    i = 0

    while i < actors.length
      actor = actors[i]
      actor.style_class = "menu-category-button"
      actor.show()
      i++
    actors = @favoritesBox.get_children()
    i = 0

    while i < actors.length
      actor = actors[i]
      actor.remove_style_pseudo_class "hover"
      actor.show()
      i++
    return

  _select_category: (dir, categoryButton) ->
    if dir
      @_displayButtons @_listApplications(dir.get_menu_id())
    else
      @_displayButtons @_listApplications(null)
    @closeContextMenus null, false
    return

  closeContextMenus: (excluded, animate) ->
    for app of @_applicationsButtons
      if app isnt excluded and @_applicationsButtons[app].menu.isOpen
        if animate
          @_applicationsButtons[app].toggleMenu()
        else
          @_applicationsButtons[app].closeMenu()
    for recent of @_recentButtons
      if recent isnt excluded and @_recentButtons[recent].menu.isOpen
        if animate
          @_recentButtons[recent].toggleMenu()
        else
          @_recentButtons[recent].closeMenu()
    return

  _resize_actor_iter: (actor) ->
    ] = actor.get_preferred_width(-1.0)
    if nat > @_applicationsBoxWidth
      @_applicationsBoxWidth = nat
      @applicationsBox.set_width @_applicationsBoxWidth + 42
    return

  _resizeApplicationsBox: ->
    @_applicationsBoxWidth = 0
    @applicationsBox.set_width -1
    child = @applicationsBox.get_first_child()
    @_resize_actor_iter child
    @_resize_actor_iter child  while (child = child.get_next_sibling())?
    return

  _displayButtons: (appCategory, places, recent, apps, autocompletes) ->
    if appCategory
      if appCategory is "all"
        @_applicationsButtons.forEach (item, index) ->
          item.actor.show()
          return

      else
        @_applicationsButtons.forEach (item, index) ->
          unless item.category.indexOf(appCategory) is -1
            item.actor.show()
          else
            item.actor.hide()
          return

    else if apps
      i = 0

      while i < @_applicationsButtons.length
        unless apps.indexOf(@_applicationsButtons[i].name) is -1
          @_applicationsButtons[i].actor.show()
        else
          @_applicationsButtons[i].actor.hide()
        i++
    else
      @_applicationsButtons.forEach (item, index) ->
        item.actor.hide()
        return

    if places
      if places is -1
        @_placesButtons.forEach (item, index) ->
          item.actor.show()
          return

      else
        i = 0

        while i < @_placesButtons.length
          unless places.indexOf(@_placesButtons[i].button_name) is -1
            @_placesButtons[i].actor.show()
          else
            @_placesButtons[i].actor.hide()
          i++
    else
      @_placesButtons.forEach (item, index) ->
        item.actor.hide()
        return

    if recent
      if recent is -1
        @_recentButtons.forEach (item, index) ->
          item.actor.show()
          return

      else
        i = 0

        while i < @_recentButtons.length
          unless recent.indexOf(@_recentButtons[i].button_name) is -1
            @_recentButtons[i].actor.show()
          else
            @_recentButtons[i].actor.hide()
          i++
    else
      @_recentButtons.forEach (item, index) ->
        item.actor.hide()
        return

    if autocompletes
      @_transientButtons.forEach (item, index) ->
        item.actor.destroy()
        return

      @_transientButtons = new Array()
      i = 0

      while i < autocompletes.length
        button = new TransientButton(this, autocompletes[i])
        button.actor.connect "leave-event", Lang.bind(this, @_appLeaveEvent, button)
        @_addEnterEvent button, Lang.bind(this, @_appEnterEvent, button)
        @_transientButtons.push button
        @applicationsBox.add_actor button.actor
        button.actor.realize()
        i++
    @_searchProviderButtons.forEach (item, index) ->
      item.actor.hide()  if item.actor.visible
      return

    return

  _setCategoriesButtonActive: (active) ->
    try
      categoriesButtons = @categoriesBox.get_children()
      for i of categoriesButtons
        button = categoriesButtons[i]
        if active
          button.set_style_class_name "menu-category-button"
        else
          button.set_style_class_name "menu-category-button-greyed"
    catch e
      global.log e
    return

  resetSearch: ->
    @searchEntry.set_text ""
    @_previousSearchPattern = ""
    @searchActive = false
    @_clearAllSelections true
    @_setCategoriesButtonActive true
    global.stage.set_key_focus @searchEntry
    return

  _onSearchTextChanged: (se, prop) ->
    if @menuIsOpening
      @menuIsOpening = false
      return
    else
      searchString = @searchEntry.get_text()
      return  if searchString is "" and not @searchActive
      @searchActive = searchString isnt ""
      @_fileFolderAccessActive = @searchActive and @searchFilesystem
      @_clearAllSelections()
      if @searchActive
        @searchEntry.set_secondary_icon @_searchActiveIcon
        if @_searchIconClickedId is 0
          @_searchIconClickedId = @searchEntry.connect("secondary-icon-clicked", Lang.bind(this, ->
            @resetSearch()
            @_select_category null, @_allAppsCategoryButton
            return
          ))
        @_setCategoriesButtonActive false
        @_doSearch()
      else
        @searchEntry.disconnect @_searchIconClickedId  if @_searchIconClickedId > 0
        @_searchIconClickedId = 0
        @searchEntry.set_secondary_icon @_searchInactiveIcon
        @_previousSearchPattern = ""
        @_setCategoriesButtonActive true
        @_select_category null, @_allAppsCategoryButton
      return

  _listBookmarks: (pattern) ->
    bookmarks = Main.placesManager.getBookmarks()
    res = new Array()
    id = 0

    while id < bookmarks.length
      res.push bookmarks[id]  if not pattern or bookmarks[id].name.toLowerCase().indexOf(pattern) isnt -1
      id++
    res

  _listDevices: (pattern) ->
    devices = Main.placesManager.getMounts()
    res = new Array()
    id = 0

    while id < devices.length
      res.push devices[id]  if not pattern or devices[id].name.toLowerCase().indexOf(pattern) isnt -1
      id++
    res

  _listApplications: (category_menu_id, pattern) ->
    applist = new Array()
    if category_menu_id
      applist = category_menu_id
    else
      applist = "all"
    res = undefined
    if pattern
      res = new Array()
      for i of @_applicationsButtons
        app = @_applicationsButtons[i].app
        res.push app.get_name()  if app.get_name().toLowerCase().indexOf(pattern) isnt -1 or (app.get_description() and app.get_description().toLowerCase().indexOf(pattern) isnt -1) or (app.get_id() and app.get_id().slice(0, -8).toLowerCase().indexOf(pattern) isnt -1)
    else
      res = applist
    res

  _doSearch: ->
    @_searchTimeoutId = 0
    pattern = @searchEntryText.get_text().replace(/^\s+/g, "").replace(/\s+$/g, "").toLowerCase()
    return false  if pattern is @_previousSearchPattern
    @_previousSearchPattern = pattern
    @_activeContainer = null
    @_activeActor = null
    @_selectedItemIndex = null
    @_previousTreeSelectedActor = null
    @_previousSelectedActor = null
    return false  if pattern.length is 0
    appResults = @_listApplications(null, pattern)
    placesResults = new Array()
    bookmarks = @_listBookmarks(pattern)
    for i of bookmarks
      placesResults.push bookmarks[i].name
    devices = @_listDevices(pattern)
    for i of devices
      placesResults.push devices[i].name
    recentResults = new Array()
    i = 0

    while i < @_recentButtons.length
      recentResults.push @_recentButtons[i].button_name  if (@_recentButtons[i] not instanceof RecentClearButton) and @_recentButtons[i].button_name.toLowerCase().indexOf(pattern) isnt -1
      i++
    acResults = new Array()
    acResults = @_getCompletions(@searchEntryText.get_text())  if @searchFilesystem
    @_displayButtons null, placesResults, recentResults, appResults, acResults
    @appBoxIter.reloadVisible()
    if @appBoxIter.getNumVisibleChildren() > 0
      item_actor = @appBoxIter.getFirstVisible()
      @_selectedItemIndex = @appBoxIter.getAbsoluteIndexOfChild(item_actor)
      @_activeContainer = @applicationsBox
      item_actor._delegate.emit "enter-event"  if item_actor and item_actor isnt @searchEntry
    SearchProviderManager.launch_all pattern, Lang.bind(this, (provider, results) ->
      try
        for i of results
          unless results[i].type is "software"
            button = new SearchProviderResultButton(this, provider, results[i])
            button.actor.connect "leave-event", Lang.bind(this, @_appLeaveEvent, button)
            @_addEnterEvent button, Lang.bind(this, @_appEnterEvent, button)
            @_searchProviderButtons.push button
            @applicationsBox.add_actor button.actor
            button.actor.realize()
      catch e
        global.log e
      return
    )
    false

  _getCompletion: (text) ->
    unless text.indexOf("/") is -1
      if text.substr(text.length - 1) is "/"
        ""
      else
        @_pathCompleter.get_completion_suffix text
    else
      false

  _getCompletions: (text) ->
    unless text.indexOf("/") is -1
      @_pathCompleter.get_completions text
    else
      new Array()

  _run: (input) ->
    command = input
    @_commandError = false
    if input
      path = null
      if input.charAt(0) is "/"
        path = input
      else
        input = input.slice(1)  if input.charAt(0) is "~"
        path = GLib.get_home_dir() + "/" + input
      if GLib.file_test(path, GLib.FileTest.EXISTS)
        file = Gio.file_new_for_path(path)
        try
          Gio.app_info_launch_default_for_uri file.get_uri(), global.create_app_launch_context()
        catch e
          return false
      else
        return false
    true
