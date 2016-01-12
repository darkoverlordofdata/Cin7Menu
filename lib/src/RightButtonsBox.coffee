class RightButtonsBox
  
  constructor: (appsMenuButton, menu) ->
    @appsMenuButton = appsMenuButton
    @actor = new St.BoxLayout()
    @itemsBox = new St.BoxLayout(vertical: true)
    @shutDownMenuBox = new St.BoxLayout(vertical: true)
    @shutDownIconBox = new St.BoxLayout(vertical: true)
    @shutdownBox = new St.BoxLayout(vertical: false)
    @actor._delegate = this
    @menu = menu
    @addItems()
    @_container = new Cinnamon.GenericContainer()
    @actor.add_actor(@_container)
    @_container.connect('get-preferred-height', Lang.bind(this, @_getPreferredHeight))
    @_container.connect('get-preferred-width', Lang.bind(this, @_getPreferredWidth))
    @_container.connect('allocate', Lang.bind(this, @_allocate))
    @_container.add_actor(@itemsBox)


  _update_quicklinks : (quicklinkOptions) -> 

    for link in @quicklinks
      link._update(quicklinkOptions)
    
    @shutdown._update(quicklinkOptions)
    @logout._update(quicklinkOptions)
    @lock._update(quicklinkOptions)

    if quicklinkOptions is 'icons'
      @hoverIcon.userLabel.hide()
      @hoverIcon._userIcon.set_icon_size(22)
      @hoverIcon.icon.set_icon_size(22)
      @shutDownMenuBox.set_style('min-height: 1px')
      @shutdownMenu.actor.hide()
      @shutdownBox.remove_actor(@shutdownMenu.actor)
    else
      @hoverIcon.userLabel.show()
      @hoverIcon._userIcon.set_icon_size(HOVER_ICON_SIZE)
      @hoverIcon.icon.set_icon_size(HOVER_ICON_SIZE)
      @shutDownIconBox.hide()
      @shutdownMenu.actor.show()
      @shutDownMenuBox.set_style('min-height: 82px')
      @shutdownBox.add_actor(@shutdownMenu.actor)
    return

  addItems:() ->
    @itemsBox.destroy_all_children()
    @shutdownBox.destroy_all_children()

    @hoverIcon = new HoverIcon(@menu)
    @itemsBox.add_actor(@hoverIcon.userBox)

    @quicklinks = []
    global.log @menu.quicklinks

    if @menu.quicklinks
      for link, i in @menu.quicklinks
        if link isnt ''
          if link is 'separator'
            @separator = new PopupMenu.PopupSeparatorMenuItem()
            @separator.actor.set_style("padding: 0em 0em min-width: 1px")
            @itemsBox.add_actor(@separator.actor)
          else
            split = link.split(',')
            if split.length is 3
              @quicklinks[i] = new TextBoxItem(_(split[0]), split[1], "Util.spawnCommandLine('"+split[2]+"')", @menu, @hoverIcon, false)
              @itemsBox.add_actor(@quicklinks[i].actor)

          @shutdown = new TextBoxItem(_("Shutdown"), "system-shutdown", "Session.ShutdownRemote()", @menu, @hoverIcon, false)
          @logout = new TextBoxItem(_("Logout"), "gnome-logout", "Session.LogoutRemote(0)", @menu, @hoverIcon, false)
          screensaver_settings = new Gio.Settings( schema: "org.cinnamon.desktop.screensaver" )
          screensaver_dialog = Gio.file_new_for_path("/usr/bin/cinnamon-screensaver-command")
          if screensaver_dialog.query_exists(null)
            if screensaver_settings.get_boolean("ask-for-away-message")
              @lock = new TextBoxItem(_("Lock"), "gnome-lockscreen", "Util.spawnCommandLine('cinnamon-screensaver-lock-dialog')", @menu, @hoverIcon, false)
            else
              @lock = new TextBoxItem(_("Lock"), "gnome-lockscreen", "Util.spawnCommandLine('cinnamon-screensaver-command --lock')", @menu, @hoverIcon, false)

          @shutdownMenu = new ShutdownMenu(@menu, @hoverIcon)

          @shutdownBox.add_actor(@shutdown.actor)
          @shutdownBox.add_actor(@shutdownMenu.actor)

          @shutDownMenuBox.add_actor(@shutdownBox)
          @shutDownMenuBox.add_actor(@shutdownMenu.menu.actor)

          @shutDownIconBox.add_actor(@logout.actor)
          @shutDownIconBox.add_actor(@lock.actor)

          @itemsBox.add_actor(@shutDownMenuBox)
          @shutDownMenuBox.set_style('min-height: 82px')

          @itemsBox.add_actor(@shutDownIconBox)


  _getPreferredHeight:(actor, forWidth, alloc) ->
    [minSize, naturalSize] = @itemsBox.get_preferred_height(forWidth)
    alloc.min_size = minSize
    alloc.natural_size = naturalSize

  _getPreferredWidth:(actor, forHeight, alloc) ->
    [minSize, naturalSize] = @itemsBox.get_preferred_width(forHeight)
    alloc.min_size = minSize
    alloc.natural_size = naturalSize

  _allocate:(actor, box, flags) ->
    childBox = new Clutter.ActorBox()

    [minWidth, minHeight, naturalWidth, naturalHeight] = @itemsBox.get_preferred_size()

    childBox.y1 = 0
    childBox.y2 = childBox.y1 + naturalHeight
    childBox.x1 = 0
    childBox.x2 = childBox.x1 + naturalWidth
    @itemsBox.allocate(childBox, flags)

    mainBoxHeight = @appsMenuButton.mainBox.get_height()

    # [minWidth, minHeight, naturalWidth, naturalHeight] = @shutDownItemsBox.get_preferred_size()

    # childBox.y1 = mainBoxHeight - 110
    # childBox.y2 = childBox.y1
    # childBox.x1 = 0
    # childBox.x2 = childBox.x1 + naturalWidth
    # @shutDownItemsBox.allocate(childBox, flags)



