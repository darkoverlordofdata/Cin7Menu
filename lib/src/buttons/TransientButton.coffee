class TransientButton
  __proto__: AppPopupSubMenuMenuItem::
  
  constructor: (appsMenuButton, pathOrCommand) ->
    @_init appsMenuButton, pathOrCommand
  
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

    
    # We need this fake app to help appEnterEvent/appLeaveEvent
    # work with our search result.
    @app =
      get_app_info:
        get_filename: =>
          pathOrCommand

      get_id: =>
        -1

      get_description: =>
        @pathOrCommand

      get_name: =>
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
      iconName = (if @isPath then "gnome-folder" else "unknown")
      @icon = new St.Icon(
        icon_name: iconName
        icon_size: APPLICATION_ICON_SIZE
        icon_type: St.IconType.FULLCOLOR
      )
      
      # @todo Would be nice to indicate we don't have a handler for this file.
      @actor.set_style_class_name "menu-application-button"
    @addActor @icon
    @label = new St.Label(
      text: displayPath
      style_class: "menu-application-button-label"
    )
    @addActor @label
    @isDraggableApp = false
    return

  _onButtonReleaseEvent: (actor, event) =>
    @activate event  if event.get_button() is 1
    true

  activate: (event) =>
    if @handler?
      @handler.launch [@file], null
    else
      
      # Try anyway, even though we probably shouldn't.
      try
        Util.spawn [
          "gvfs-open"
          @file.get_uri()
        ]
      catch e
        global.logError "No handler available to open " + @file.get_uri()
    @appsMenuButton.menu.close()
    return
