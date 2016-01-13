class ShutdownContextMenuItem extends ApplicationContextMenuItem
  
  constructor: (parentMenu, menu, label, action) ->
    @parentMenu = parentMenu
    @_init menu, label, action
    @_screenSaverProxy = new ScreenSaver.ScreenSaverProxy()
    return

  activate: (event) ->
    switch @_action
      when "logout"
        Session.LogoutRemote 0
      when "lock"
        screensaver_settings = new Gio.Settings(schema: "org.cinnamon.desktop.screensaver")
        screensaver_dialog = Gio.file_new_for_path("/usr/bin/cinnamon-screensaver-command")
        if screensaver_dialog.query_exists(null)
          if screensaver_settings.get_boolean("ask-for-away-message")
            Util.spawnCommandLine "cinnamon-screensaver-lock-dialog"
          else
            Util.spawnCommandLine "cinnamon-screensaver-command --lock"
        else
          @_screenSaverProxy.LockRemote()
    @_appButton.toggle()
    @parentMenu.toggle()
    false
