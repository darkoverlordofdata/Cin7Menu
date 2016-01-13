class ApplicationContextMenuItem
  __proto__: PopupMenu.PopupBaseMenuItem::
  
  constructor:(appButton, label, action) ->
    @_init appButton, label, action

  _init: (appButton, label, action) ->
    PopupMenu.PopupBaseMenuItem::_init.call this,
      focusOnHover: false

    @_appButton = appButton
    @_action = action
    @label = new St.Label(text: label)
    @addActor @label
    return

  activate: (event) =>
    switch @_action
      when "add_to_panel"
        winListApplet = false
        try
          winListApplet = imports.ui.appletManager.applets["WindowListGroup@jake.phy@gmail.com"]
        if winListApplet
          winListApplet.applet.GetAppFavorites().addFavorite @_appButton.app.get_id()
        else
          settings = new Gio.Settings(schema: "org.cinnamon")
          desktopFiles = settings.get_strv("panel-launchers")
          desktopFiles.push @_appButton.app.get_id()
          settings.set_strv "panel-launchers", desktopFiles
          unless Main.AppletManager.get_object_for_uuid("panel-launchers@cinnamon.org")
            new_applet_id = global.settings.get_int("next-applet-id")
            global.settings.set_int "next-applet-id", (new_applet_id + 1)
            enabled_applets = global.settings.get_strv("enabled-applets")
            enabled_applets.push "panel1:right:0:panel-launchers@cinnamon.org:" + new_applet_id
            global.settings.set_strv "enabled-applets", enabled_applets
      when "add_to_desktop"
        file = Gio.file_new_for_path(@_appButton.app.get_app_info().get_filename())
        destFile = Gio.file_new_for_path(USER_DESKTOP_PATH + "/" + @_appButton.app.get_id())
        try
          file.copy destFile, 0, null, ->

          
          # Need to find a way to do that using the Gio library, but modifying the access::can-execute attribute on the file object seems unsupported
          Util.spawnCommandLine "chmod +x \"" + USER_DESKTOP_PATH + "/" + @_appButton.app.get_id() + "\""
        catch e
          global.log e
      when "add_to_favorites"
        AppFavorites.getAppFavorites().addFavorite @_appButton.app.get_id()
      when "remove_from_favorites"
        AppFavorites.getAppFavorites().removeFavorite @_appButton.app.get_id()
    @_appButton.toggleMenu()
    false
