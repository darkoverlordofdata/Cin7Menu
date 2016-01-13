HoverIcon = (parent) ->
  @_init parent
  return
HoverIcon:: =
  _init: (parent) ->
    @actor = new St.Bin()
    @icon = new St.Icon(
      icon_size: HOVER_ICON_SIZE
      icon_type: St.IconType.FULLCOLOR
      style_class: "hover-icon"
    )
    @actor.cild = @icon
    @showUser = true
    @userBox = new St.BoxLayout(
      style_class: "hover-box"
      reactive: true
      vertical: false
    )
    @_userIcon = new St.Icon(style_class: "hover-user-icon")
    @userBox.connect "button-press-event", Lang.bind(this, ->
      parent.toggle()
      Util.spawnCommandLine "cinnamon-settings user"
      return
    )
    @_userIcon.hide()
    @userBox.add @icon,
      x_fill: true
      y_fill: false
      x_align: St.Align.END
      y_align: St.Align.START

    @userBox.add @_userIcon,
      x_fill: true
      y_fill: false
      x_align: St.Align.END
      y_align: St.Align.START

    @userLabel = new St.Label((style_class: "hover-label"))
    @userBox.add @userLabel,
      x_fill: true
      y_fill: false
      x_align: St.Align.END
      y_align: St.Align.MIDDLE

    icon = new Gio.ThemedIcon(name: "avatar-default")
    @_userIcon.set_gicon icon
    @_userIcon.show()
    @_user = AccountsService.UserManager.get_default().get_user(GLib.get_user_name())
    @_userLoadedId = @_user.connect("notify::is_loaded", Lang.bind(this, @_onUserChanged))
    @_userChangedId = @_user.connect("changed", Lang.bind(this, @_onUserChanged))
    @_onUserChanged()
    return

  
  #this._refresh('folder-home');
  _onUserChanged: ->
    if @_user.is_loaded and @showUser
      
      #this.set_applet_tooltip(this._user.get_real_name());
      @userLabel.set_text @_user.get_real_name()
      if @_userIcon
        iconFileName = @_user.get_icon_file()
        iconFile = Gio.file_new_for_path(iconFileName)
        icon = undefined
        if iconFile.query_exists(null)
          icon = new Gio.FileIcon(file: iconFile)
        else
          icon = new Gio.ThemedIcon(name: "avatar-default")
        @_userIcon.set_gicon icon
        @icon.hide()
        @_userIcon.show()
    return

  _refresh: (icon) ->
    @_userIcon.hide()
    iconFileName = icon
    iconFile = Gio.file_new_for_path(iconFileName)
    newicon = undefined
    if iconFile.query_exists(null)
      newicon = new Gio.FileIcon(file: iconFile)
    else
      newicon = new Gio.ThemedIcon(name: icon)
    if iconFile.query_exists(null)
      @icon.set_gicon newicon
    else
      @icon.set_icon_name icon
    @icon.show()
    return
