class MyApplet
  __proto__: base = Applet.TextIconApplet.prototype

  constructor:(orientation, panel_height, instance_id) ->
    @_init(orientation, panel_height, instance_id)

  _init:(orientation, panel_height, instance_id) ->
    base._init.call(this, orientation, panel_height, instance_id)
    try
      @set_applet_tooltip(_("Menu"))

      @menuManager = new PopupMenu.PopupMenuManager(this)
      @menu = new Applet.AppletPopupMenu(this, orientation)
      @menuManager.addMenu(@menu)

      @actor.connect('key-press-event', Lang.bind(this, @_onSourceKeyPress))

      @settings = new Settings.AppletSettings(this, "StarkMenu@mintystark", instance_id)

      @settings.bindProperty(Settings.BindingDirection.IN, "show-recent", "showRecent", @_refreshPlacesAndRecent, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "show-places", "showPlaces", @_refreshPlacesAndRecent, null)

      @settings.bindProperty(Settings.BindingDirection.IN, "activate-on-hover", "activateOnHover", @_updateActivateOnHover, null)
      @_updateActivateOnHover()

      @menu.actor.add_style_class_name('menu-background')

      @settings.bindProperty(Settings.BindingDirection.IN, "menu-icon", "menuIcon", @_updateIconAndLabel, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "menu-label", "menuLabel", @_updateIconAndLabel, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "all-programs-label", "allProgramsLabel", null, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "favorites-label", "favoritesLabel", null, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "shutdown-label", "shutdownLabel", null, null)
      @_updateIconAndLabel()


      @_searchInactiveIcon = new St.Icon( style_class: 'menu-search-entry-icon',
        icon_name: 'edit-find',
        icon_type: St.IconType.SYMBOLIC )
      @_searchActiveIcon = new St.Icon( style_class: 'menu-search-entry-icon',
        icon_name: 'edit-clear',
        icon_type: St.IconType.SYMBOLIC )
      @_searchIconClickedId = 0
      @_applicationsButtons = new Array()
      @_favoritesButtons = new Array()
      @_placesButtons = new Array()
      @_transientButtons = new Array()
      @_recentButtons = new Array()
      @_selectedItemIndex = null
      @_previousTreeItemIndex = null
      @_previousSelectedActor = null
      @_previousTreeSelectedActor = null
      @_activeContainer = null
      @_activeActor = null
      @_applicationsBoxWidth = 0
      @menuIsOpening = false

      @RecentManager = new DocInfo.DocManager()

      @_display()
      @menu.connect('open-state-changed', Lang.bind(this, @_onOpenStateChanged))
      appsys.connect('installed-changed', Lang.bind(this, @_refreshApps))
      AppFavorites.getAppFavorites().connect('changed', Lang.bind(this, @_refreshFavs))

      @settings.bindProperty(Settings.BindingDirection.IN, "hover-delay", "hover_delay_ms", @_update_hover_delay, null)
      @_update_hover_delay()

      @settings.bindProperty(Settings.BindingDirection.IN, "show-quicklinks", "showQuicklinks", @_updateQuickLinksView, null)
      @_updateQuickLinksView()

      @settings.bindProperty(Settings.BindingDirection.IN, "show-quicklinks-shutdown-menu", "showQuicklinksShutdownMenu", @_updateQuickLinksShutdownView, null)
      @_updateQuickLinksShutdownView()

      ###
            global.display.connect('overlay-key', Lang.bind(this, function()
                try
                    @menu.toggle()
                
                catch(e) 
                    global.logError(e)
                
            ))
  
      ###
      Main.placesManager.connect('places-updated', Lang.bind(this, @_refreshApps))
      @RecentManager.connect('changed', Lang.bind(this, @_refreshApps))

      @_fileFolderAccessActive = false

      @_pathCompleter = new Gio.FilenameCompleter()
      @_pathCompleter.set_dirs_only(false)
      @lastAcResults = new Array()

      @settings.bindProperty(Settings.BindingDirection.IN, "search-filesystem", "searchFilesystem", null, null)

      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-0", "quicklink_0", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-1", "quicklink_1", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-2", "quicklink_2", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-3", "quicklink_3", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-4", "quicklink_4", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-5", "quicklink_5", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-6", "quicklink_6", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-7", "quicklink_7", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-8", "quicklink_8", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-9", "quicklink_9", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-10", "quicklink_10", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-11", "quicklink_11", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-12", "quicklink_12", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-13", "quicklink_13", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-14", "quicklink_14", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-15", "quicklink_15", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-16", "quicklink_16", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-17", "quicklink_17", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-18", "quicklink_18", @_updateQuickLinks, null)
      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-19", "quicklink_19", @_updateQuickLinks, null)

      @settings.bindProperty(Settings.BindingDirection.IN, "quicklink-options", "quicklinkOptions", @_updateQuickLinks, null)
      @_updateQuickLinks()

    catch e
      global.logError(e)

  openMenu:() ->
    @menu.open(true)

  _updateActivateOnHover:() ->
    if @_openMenuId
      @actor.disconnect(@_openMenuId)
      @_openMenuId = 0

    if @activateOnHover
      @_openMenuId = @actor.connect('enter-event', Lang.bind(this, @openMenu))

  _updateQuickLinksView:() ->
    @menu.showQuicklinks = @showQuicklinks
    if @menu.showQuicklinks
      @rightButtonsBox.actor.show()
    else
      @rightButtonsBox.actor.hide()

  _updateQuickLinksShutdownView:() ->
    @menu.showQuicklinksShutdownMenu = @showQuicklinksShutdownMenu
    if(@menu.showQuicklinksShutdownMenu)
      @rightButtonsBox.shutdown.actor.show()
      @rightButtonsBox.shutdownMenu.actor.show()
      if @quicklinkOptions isnt 'icons'
        @rightButtonsBox.shutDownMenuBox.set_style('min-height: 82px')
      else
        @rightButtonsBox.shutDownIconBox.show()
    else
      @rightButtonsBox.shutdown.actor.hide()
      @rightButtonsBox.shutdownMenu.actor.hide()
      @rightButtonsBox.shutDownIconBox.hide()
      @rightButtonsBox.shutDownMenuBox.set_style('min-height: 1px')

    @favsBox.style = "min-height: "+(@rightButtonsBox.actor.get_height()-100)+"pxmin-width: 235px"

  _updateQuickLinks:() ->
    @menu.quicklinks = []
    @menu.quicklinks[0] = @quicklink_0
    @menu.quicklinks[1] = @quicklink_1
    @menu.quicklinks[2] = @quicklink_2
    @menu.quicklinks[3] = @quicklink_3
    @menu.quicklinks[4] = @quicklink_4
    @menu.quicklinks[5] = @quicklink_5
    @menu.quicklinks[6] = @quicklink_6
    @menu.quicklinks[7] = @quicklink_7
    @menu.quicklinks[8] = @quicklink_8
    @menu.quicklinks[9] = @quicklink_9
    @menu.quicklinks[10] = @quicklink_10
    @menu.quicklinks[11] = @quicklink_11
    @menu.quicklinks[12] = @quicklink_12
    @menu.quicklinks[13] = @quicklink_13
    @menu.quicklinks[14] = @quicklink_14
    @menu.quicklinks[15] = @quicklink_15
    @menu.quicklinks[16] = @quicklink_16
    @menu.quicklinks[17] = @quicklink_17
    @menu.quicklinks[18] = @quicklink_18
    @menu.quicklinks[19] = @quicklink_19

    @menu.quicklinkOptions = @quicklinkOptions
    @rightButtonsBox.addItems()
    @rightButtonsBox._update_quicklinks(@quicklinkOptions)

    @_updateQuickLinksShutdownView()

    @favsBox.style = "min-height: "+(@rightButtonsBox.actor.get_height()-100)+"pxmin-width: 235px"

  _update_hover_delay:() ->
    @hover_delay = @hover_delay_ms / 1000

  on_orientation_changed:(orientation) ->
    @menu.destroy()
    @menu = new Applet.AppletPopupMenu(this, orientation)
    @menuManager.addMenu(@menu)

    @menu.actor.add_style_class_name('menu-background')
    @menu.connect('open-state-changed', Lang.bind(this, @_onOpenStateChanged))
    @_display()
    @_updateQuickLinksShutdownView()
    @_updateQuickLinks()

  _launch_editor:() ->
    Util.spawnCommandLine("cinnamon-menu-editor")

  on_applet_clicked:(event) ->
    @menu.toggle()

  _onSourceKeyPress:(actor, event) ->
    symbol = event.get_key_symbol()

    if symbol is Clutter.KEY_space or symbol is Clutter.KEY_Return
      @menu.toggle()
      return true
    else if symbol is Clutter.KEY_Escape and @menu.isOpen
      @menu.close()
      return true
    else if symbol is Clutter.KEY_Down
      if not @menu.isOpen
        @menu.toggle()
      @menu.actor.navigate_focus(@actor, Gtk.DirectionType.DOWN, false)
      return true
    else
      return false

  _onOpenStateChanged:(menu, open)->
    if open
      @menuIsOpening = true
      @actor.add_style_pseudo_class('active')
      @switchPanes("favs")
      @_appletStyles()
      global.stage.set_key_focus(@searchEntry)
      @_selectedItemIndex = null
      @_activeContainer = null
      @_activeActor = null
      monitorHeight = Main.layoutManager.primaryMonitor.height
      @_select_category(null, @_allAppsCategoryButton)
    else
      @actor.remove_style_pseudo_class('active')
      if @searchActive
        @resetSearch()
      @selectedAppTitle.set_text("")
      @selectedAppDescription.set_text("")
      @_previousTreeItemIndex = null
      @_previousTreeSelectedActor = null
      @_previousSelectedActor = null
      @closeApplicationsContextMenus(null, false)
      @_clearAllSelections()

  destroy:() ->
    @actor._delegate = null
    @menu.destroy()
    @actor.destroy()
    @emit('destroy')


  _updateIconAndLabel:() ->
    @set_applet_label(@menuLabel)
    try
      @set_applet_icon_path(@menuIcon)
    catch e
      global.logWarning("Could not load icon file \""+@menuIcon+"\" for menu button")


  _onMenuKeyPress:(actor, event) ->
    symbol = event.get_key_symbol()
    item_actor
    index = 0
    @appBoxIter.reloadVisible()
    @catBoxIter.reloadVisible()
    if symbol is Clutter.KEY_Super_L and @menu.isOpen
      @menu.close()
      return true
    index = @_selectedItemIndex
    if @_activeContainer is null and symbol is Clutter.KEY_Up
      @_activeContainer = @applicationsBox
      item_actor = @appBoxIter.getLastVisible()
      index = @appBoxIter.getAbsoluteIndexOfChild(item_actor)
    else if @_activeContainer is null and symbol is Clutter.KEY_Down
      @_activeContainer = @applicationsBox
      item_actor = @appBoxIter.getFirstVisible()
      index = @appBoxIter.getAbsoluteIndexOfChild(item_actor)
    else if symbol is Clutter.KEY_Up
      if @_activeContainer is @applicationsBox
        @_previousSelectedActor = @applicationsBox.get_child_at_index(index)
        item_actor = @appBoxIter.getPrevVisible(@_previousSelectedActor)
        index = @appBoxIter.getAbsoluteIndexOfChild(item_actor)
      else
        @_previousSelectedActor = @categoriesBox.get_child_at_index(index)
        @_previousSelectedActor._delegate.isHovered = false
        item_actor = @catBoxIter.getPrevVisible(@_activeActor)
        index = @catBoxIter.getAbsoluteIndexOfChild(item_actor)
    else if (symbol is Clutter.KEY_Down)
      if @_activeContainer is @applicationsBox
        @_previousSelectedActor = @applicationsBox.get_child_at_index(index)
        item_actor = @appBoxIter.getNextVisible(@_previousSelectedActor)
        index = @appBoxIter.getAbsoluteIndexOfChild(item_actor)
      else
        @_previousSelectedActor = @categoriesBox.get_child_at_index(index)
        @_previousSelectedActor._delegate.isHovered = false
        item_actor = @catBoxIter.getNextVisible(@_activeActor)
        index = @catBoxIter.getAbsoluteIndexOfChild(item_actor)
    else if symbol is Clutter.KEY_Right and (@_activeContainer isnt @applicationsBox)
      # Jump from Categories to Appications
      item_actor = @appBoxIter.getFirstVisible()
      index = @appBoxIter.getAbsoluteIndexOfChild(item_actor)
    else if symbol is Clutter.KEY_Left and @_activeContainer is @applicationsBox and not @searchActive
      # Jump from Appications to Categories
      @_previousSelectedActor = @applicationsBox.get_child_at_index(index)
      item_actor = if @_previousTreeSelectedActor isnt null then @_previousTreeSelectedActor else @catBoxIter.getFirstVisible()
      index = @catBoxIter.getAbsoluteIndexOfChild(item_actor)
    else if @_activeContainer is @applicationsBox and (symbol is Clutter.KEY_Return or symbol is Clutter.KP_Enter)
      item_actor = @applicationsBox.get_child_at_index(@_selectedItemIndex)
      item_actor._delegate.activate()
      return true
    else if @searchFilesystem and (@_fileFolderAccessActive or symbol is Clutter.slash)
      if symbol is Clutter.Return or symbol is Clutter.KP_Enter
        if @_run(@searchEntry.get_text())
          @menu.close()
        return true

      if symbol is Clutter.Escape
        @searchEntry.set_text('')
        @_fileFolderAccessActive = false

      if symbol is Clutter.slash
        # Need preload data before get completion. GFilenameCompleter load content of parent directory.
        # Parent directory for /usr/include/ is /usr/. So need to add fake name('a').
        text = @searchEntry.get_text().concat('/a')
        if text.lastIndexOf(' ') is -1
          prefix = text
        else
          prefix = text.substr(text.lastIndexOf(' ') + 1)
        @_getCompletion(prefix)

        return false

      if symbol is Clutter.Tab
        text = actor.get_text()
        if text.lastIndexOf(' ') is -1
          prefix = text
        else
          prefix = text.substr(text.lastIndexOf(' ') + 1)
        postfix = @_getCompletion(prefix)
        if postfix isnt null and postfix.length > 0
          actor.insert_text(postfix, -1)
          actor.set_cursor_position(text.length + postfix.length)
          if postfix[postfix.length - 1] is '/'
            @_getCompletion(text + postfix + 'a')
        return true

      return false

    else
      return false

      @_selectedItemIndex = index
      if not item_actor or item_actor is @searchEntry
        return false

      item_actor._delegate.emit('enter-event')
      return true

  _addEnterEvent:(button, callback) ->
    _callback = =>
      parent = button.actor.get_parent()
      if @_activeContainer isnt @applicationsBox and parent isnt @_activeContainer 
        @_previousTreeItemIndex = @_selectedItemIndex
        @_previousTreeSelectedActor = @_activeActor
        @_previousSelectedActor = null
  
      if @_previousTreeSelectedActor and @_activeContainer isnt @categoriesBox and parent isnt @_activeContainer and button isnt @_previousTreeSelectedActor
        @_previousTreeSelectedActor.style_class = "menu-category-button"
  
      if parent isnt @_activeContainer
        parent._vis_iter.reloadVisible()
        
      _maybePreviousActor = @_activeActor
      if _maybePreviousActor and @_activeContainer is @applicationsBox
        @_previousSelectedActor = _maybePreviousActor
        @_clearPrevAppSelection()
  
      if parent is @categoriesBox and !@searchActive
        @_previousSelectedActor = _maybePreviousActor
        @_clearPrevCatSelection()
  
      @_activeContainer = parent
      @_activeActor = button.actor
      @_selectedItemIndex = @_activeContainer._vis_iter.getAbsoluteIndexOfChild(@_activeActor)
      callback()

    button.connect('enter-event', _callback)
    button.actor.connect('enter-event', _callback)

  _clearPrevAppSelection:(actor) ->
    if @_previousSelectedActor and @_previousSelectedActor isnt actor
      @_previousSelectedActor.style_class = "menu-application-button"

  _clearPrevCatSelection:(actor) ->
    if @_previousSelectedActor and @_previousSelectedActor isnt actor
      @_previousSelectedActor.style_class = "menu-category-button"

  _appletStyles:(pane) ->
    favsWidth = (@favsBox.get_allocation_box().x2 - @favsBox.get_allocation_box().x1)
    scrollWidth = @searchBox.get_width() + @rightButtonsBox.actor.get_width()
    @searchEntry.style = "width:" + favsWidth + "px"
    @appsButton.box.style = "width:" + favsWidth + "px"
    scrollBoxHeight = (@favsBox.get_allocation_box().y2 - @favsBox.get_allocation_box().y1)-(@selectedAppBox.get_allocation_box().y2 - @selectedAppBox.get_allocation_box().y1)
    @applicationsScrollBox.style = "width: " + ((scrollWidth) * 0.55) + "pxheight: " + scrollBoxHeight + "px"
    @categoriesScrollBox.style = "width: " + ((scrollWidth) * 0.45) + "pxheight: " + scrollBoxHeight + "px"

  _refreshApps:() ->
    @applicationsBox.destroy_all_children()
    @_applicationsButtons = new Array()
    @_placesButtons = new Array()
    @_recentButtons = new Array()
    @_applicationsBoxWidth = 0
    #Remove all categories
    @categoriesBox.destroy_all_children()

    @_allAppsCategoryButton = new CategoryButton(null)
    @_addEnterEvent @_allAppsCategoryButton, =>
      if not @searchActive
        @_allAppsCategoryButton.isHovered = true
        @_allAppsCategoryButton.actor.style_class = "menu-category-button-selected"
        if @hover_delay > 0
          Tweener.addTween this,
            time: @hover_delay
            onComplete: () ->
              if @_allAppsCategoryButton.isHovered
                @_clearPrevCatSelection(@_allAppsCategoryButton.actor)
                @_select_category(null, @_allAppsCategoryButton)
              else
                @_allAppsCategoryButton.actor.style_class = "menu-category-button"
              return

        else
          @_clearPrevCatSelection(@_allAppsCategoryButton.actor)
          @_select_category(null, @_allAppsCategoryButton)
      return


    @_allAppsCategoryButton.actor.connect 'leave-event', =>
      if not @searchActive
        @_allAppsCategoryButton.actor.style_class = "menu-category-button"

      @_previousSelectedActor = @_allAppsCategoryButton.actor
      @_allAppsCategoryButton.isHovered = false
      return


    @categoriesBox.add_actor(@_allAppsCategoryButton.actor)

    trees = [appsys.get_tree()]
    for tree, i in trees
      root = tree.get_root_directory()

      iter = root.iter()
      while (nextType = iter.next()) isnt CMenu.TreeItemType.INVALID

        if nextType is CMenu.TreeItemType.DIRECTORY
          dir = iter.get_directory()
          if dir.get_is_nodisplay()
            continue
          @applicationsByCategory[dir.get_menu_id()] = new Array()
          @_loadCategory(dir)
          if @applicationsByCategory[dir.get_menu_id()].length>0
            categoryButton = new CategoryButton(dir)

            @_addEnterEvent categoryButton, =>
              if not @searchActive
                categoryButton.isHovered = true
                categoryButton.actor.style_class = "menu-category-button-selected"
                if @hover_delay > 0
                  Tweener.addTween this,
                    time: @hover_delay
                    onComplete: () ->
                      if categoryButton.isHovered
                        @_clearPrevCatSelection(categoryButton.actor)
                        @_select_category(dir, categoryButton)
                      else
                        categoryButton.actor.style_class = "menu-category-button"
                      return

                else
                  @_clearPrevCatSelection(categoryButton.actor)
                  @_select_category(dir, categoryButton)
              return

            categoryButton.actor.connect 'leave-event', =>
              if not @searchActive
                categoryButton.actor.style_class = "menu-category-button"

              @_previousSelectedActor = categoryButton.actor
              categoryButton.isHovered = false
              return


      # Sort apps and add to applicationsBox
      @_applicationsButtons.sort (a, b) -> a.app.get_name().toLowerCase() > b.app.get_name().toLowerCase()
      for button in @_applicationsButtons
        @applicationsBox.add_actor(button.actor)
        button.actor.realize()
        @applicationsBox.add_actor(button.menu.actor)

      # Now generate Places category and places buttons and add to the list
      if @showPlaces
        @placesButton = new PlaceCategoryButton()

        @_addEnterEvent @placesButton, =>
          if not @searchActive
            @placesButton.isHovered = true
            @placesButton.actor.style_class = "menu-category-button-selected"
            Tweener.addTween this,
              time: @hover_delay
              onComplete:  () ->
                if @placesButton.isHovered
                  @_clearPrevCatSelection(@placesButton)
                  @_displayButtons(null, -1)

            @_scrollToCategoryButton(@placesButton)
          return


        @placesButton.actor.connect 'leave-event', =>
          if not @searchActive
            @placesButton.actor.style_class = "menu-category-button"

          @_previousSelectedActor = @placesButton.actor
          @placesButton.isHovered = false
          return

        @categoriesBox.add_actor(@placesButton.actor)

        bookmarks = @_listBookmarks()
        devices = @_listDevices()
        places = bookmarks.concat(devices)
        for place in places
          do (button = new PlaceButton(this, place, place.name)) ->

            @_addEnterEvent button, =>
              @_clearPrevAppSelection(button.actor)
              button.actor.style_class = "menu-application-button-selected"
              @_scrollToButton(button)
              @selectedAppDescription.set_text(button.place.id.slice(16))
              return

            button.actor.connect 'leave-event', =>
              button.actor.style_class = "menu-application-button"
              @_previousSelectedActor = button.actor
              @selectedAppDescription.set_text("")
              return

            @_placesButtons.push(button)
            @applicationsBox.add_actor(button.actor)


        @placesButton.actor.connect 'leave-event', =>
          if not @searchActive
            @placesButton.actor.style_class = "menu-category-button"

          @_previousSelectedActor = @placesButton.actor
          @placesButton.isHovered = false
          return

        @categoriesBox.add_actor(@placesButton.actor)

        bookmarks = @_listBookmarks()
        devices = @_listDevices()
        places = bookmarks.concat(devices)
        for place in places
          do (button = new PlaceButton(this, place, place.name)) ->

            @_addEnterEvent button, =>
              @_clearPrevAppSelection(button.actor)
              button.actor.style_class = "menu-application-button-selected"
              @_scrollToButton(button)
              @selectedAppDescription.set_text(button.place.id.slice(16))
              return

            button.actor.connect 'leave-event', =>
              button.actor.style_class = "menu-application-button"
              @_previousSelectedActor = button.actor
              @selectedAppDescription.set_text("")
              return

            @_placesButtons.push(button)
            @applicationsBox.add_actor(button.actor)


      # Now generate recent category and recent files buttons and add to the list
      if @showRecent
        @recentButton = new RecentCategoryButton()

        @_addEnterEvent @recentButton, =>
          if not @searchActive
            @recentButton.isHovered = true
            @recentButton.actor.style_class = "menu-category-button-selected"
            Tweener.addTween this,
              time: @hover_delay,
              onComplete: () ->
                if @recentButton.isHovered
                  @_clearPrevCatSelection(@recentButton.actor)
                  @_displayButtons(null, null, -1)

          @_scrollToCategoryButton(@recentButton)
          return

        @recentButton.actor.connect 'leave-event', =>
          if not @searchActive
            @recentButton.actor.style_class = "menu-category-button"

          @_previousSelectedActor = @recentButton.actor
          @recentButton.isHovered = false
          return

        @categoriesBox.add_actor(@recentButton.actor)

        id = 0
        while id < MAX_RECENT_FILES and id < @RecentManager._infosByTimestamp.length
          do (button = new RecentButton(this, @RecentManager._infosByTimestamp[id++])) ->

            @_addEnterEvent button, =>
              @_clearPrevAppSelection(button.actor)
              button.actor.style_class = "menu-application-button-selected"
              @_scrollToButton(button)
              @selectedAppDescription.set_text(button.file.uri.slice(7))
              return

            button.actor.connect 'leave-event', =>
              button.actor.style_class = "menu-application-button"
              @_previousSelectedActor = button.actor
              @selectedAppTitle.set_text("")
              @selectedAppDescription.set_text("")
              return

            @_recentButtons.push(button)
            @applicationsBox.add_actor(button.actor)


        if @RecentManager._infosByTimestamp.length > 0
          button = new RecentClearButton(this)

          @_addEnterEvent button, =>
            @_clearPrevAppSelection(button.actor)
            button.actor.style_class = "menu-application-button-selected"
            @_scrollToButton(button)
            return

          button.actor.connect 'leave-event', =>
            button.actor.style_class = "menu-application-button"
            @_previousSelectedActor = button.actor
            return

          @_recentButtons.push(button)
          @applicationsBox.add_actor(button.actor)

    @_setCategoriesButtonActive(not @searchActive)
    return

  _refreshFavs:() ->
    #Remove all favorites
    @favsBox.get_children().forEach (child) -> child.destroy()

    favoritesBox = new FavoritesBox()
    @favsBox.add_actor(favoritesBox.actor, y_align: St.Align.END, y_fill: false)

    #Load favorites again
    @_favoritesButtons = new Array()
    launchers = global.settings.get_strv('favorite-apps')
    appSys = Cinnamon.AppSystem.get_default()
    for launcher in launchers
      app = appSys.lookup_app(launcher)
      if not app then app = appSys.lookup_settings_app(launcher)
      if app
        do (button = new FavoritesButton(this, app, launchers.length, @favorite_icon_size)) -> # + 3 because we're adding 3 system buttons at the bottom
          @_favoritesButtons[app] = button
          favoritesBox.actor.add_actor(button.actor, y_align: St.Align.END, y_fill: false)
          favoritesBox.actor.add_actor(button.menu.actor, y_align: St.Align.END, y_fill: false)

          button.actor.connect 'enter-event', =>
            @selectedAppTitle.set_text(button.app.get_name())
            if (button.app.get_description())
              @selectedAppDescription.set_text(button.app.get_description())
            else
              @selectedAppDescription.set_text("")

          button.actor.connect 'leave-event', =>
            @selectedAppTitle.set_text("")
            @selectedAppDescription.set_text("")


  _loadCategory:(dir, top_dir) ->
    iter = dir.iter()
    dupe = false
    if not top_dir then  top_dir = dir
    while (nextType = iter.next()) isnt CMenu.TreeItemType.INVALID
      if nextType is CMenu.TreeItemType.ENTRY
        entry = iter.get_entry()
        if not entry.get_app_info().get_nodisplay()
          app = appsys.lookup_app_by_tree_entry(entry)
          dupe = @find_dupe(app)
          if not dupe
            applicationButton = new ApplicationButton(this, app)
            applicationButton.actor.connect('realize', Lang.bind(this, @_onApplicationButtonRealized))
            applicationButton.actor.connect('leave-event', Lang.bind(this, @_appLeaveEvent, applicationButton))
            @_addEnterEvent(applicationButton, Lang.bind(this, @_appEnterEvent, applicationButton))
            @_applicationsButtons.push(applicationButton)
            applicationButton.category.push(top_dir.get_menu_id())
            @applicationsByCategory[top_dir.get_menu_id()].push(app.get_name())
          else
            for button in @_applicationsButtons
              if (button.app is app)
                button.category.push(dir.get_menu_id())
            @applicationsByCategory[dir.get_menu_id()].push(app.get_name())

        else if nextType is CMenu.TreeItemType.DIRECTORY
          @_previousSelectedActor = applicationButton.actor
          applicationButton.actor.style_class = "menu-application-button"
          @selectedAppTitle.set_text("")
          @selectedAppDescription.set_text("")

  _appLeaveEvent:(a, b, applicationButton) ->
    @_previousSelectedActor = applicationButton.actor
    applicationButton.actor.style_class = "menu-application-button"
    @selectedAppTitle.set_text("")
    @selectedAppDescription.set_text("")


  _appEnterEvent:(applicationButton) ->
    @selectedAppTitle.set_text(applicationButton.app.get_name())
    if applicationButton.app.get_description()
      @selectedAppDescription.set_text(applicationButton.app.get_description())
    else
      @selectedAppDescription.set_text("")
    @_clearPrevAppSelection(applicationButton.actor)
    applicationButton.actor.style_class = "menu-application-button-selected"
    @_scrollToButton(applicationButton)

  find_dupe:(app) ->
    for button in @_applicationsButtons
      if app is button.app then return true
    false

  _scrollToButton:(button) ->
    current_scroll_value = @applicationsScrollBox.get_vscroll_bar().get_adjustment().get_value()
    box_height = @applicationsScrollBox.get_allocation_box().y2-@applicationsScrollBox.get_allocation_box().y1
    new_scroll_value = current_scroll_value

    if current_scroll_value > button.actor.get_allocation_box().y1-10
      new_scroll_value = button.actor.get_allocation_box().y1-10

    if box_height+current_scroll_value < button.actor.get_allocation_box().y2+10
      new_scroll_value = button.actor.get_allocation_box().y2-box_height+10

    if new_scroll_value isnt current_scroll_value
      @applicationsScrollBox.get_vscroll_bar().get_adjustment().set_value(new_scroll_value)

  _scrollToCategoryButton:(button) ->
    current_scroll_value = @categoriesScrollBox.get_vscroll_bar().get_adjustment().get_value()
    box_height = @categoriesScrollBox.get_allocation_box().y2-@categoriesScrollBox.get_allocation_box().y1
    new_scroll_value = current_scroll_value

    if current_scroll_value > button.actor.get_allocation_box().y1-10
      new_scroll_value = button.actor.get_allocation_box().y1-10

    if box_height+current_scroll_value < button.actor.get_allocation_box().y2+10
      new_scroll_value = button.actor.get_allocation_box().y2-box_height+10

    if new_scroll_value isnt current_scroll_value
      @categoriesScrollBox.get_vscroll_bar().get_adjustment().set_value(new_scroll_value)

  _display:() ->
    @_activeContainer = null
    @_activeActor = null
    section = new PopupMenu.PopupMenuSection()
    @menu.addMenuItem(section)

    @leftPane = new St.Bin()

    @favsBox = new St.BoxLayout(vertical: true)
    @favsBox.style = "min-height: 152pxmin-width: 235px"

    @appsBox = new St.BoxLayout(vertical: true)

    @searchBox = new St.BoxLayout( style_class: 'menu-search-box' )
    @searchBox.set_style("padding-right: 0pxpadding-left: 0px")

    @searchEntry = new St.Entry( name: 'menu-search-entry',
      hint_text: _("Type to search..."),
      track_hover: true,
      can_focus: true )
    @searchEntry.set_secondary_icon(@_searchInactiveIcon)
    @searchActive = false
    @searchEntryText = @searchEntry.clutter_text
    @searchEntryText.connect('text-changed', Lang.bind(this, @_onSearchTextChanged))
    @searchEntryText.connect('key-press-event', Lang.bind(this, @_onMenuKeyPress))
    @_previousSearchPattern = ""

    @selectedAppBox = new St.BoxLayout( style_class: 'menu-selected-app-box', vertical: true )
    @selectedAppTitle = new St.Label( style_class: 'menu-selected-app-title', text: "" )
    @selectedAppBox.add_actor(@selectedAppTitle)
    @selectedAppDescription = new St.Label( style_class: 'menu-selected-app-description', text: "" )

    @categoriesApplicationsBox = new CategoriesApplicationsBox()
    @categoriesBox = new St.BoxLayout( style_class: 'menu-categories-box', vertical: true )


    @categoriesScrollBox = new St.ScrollView( x_fill: true, y_fill: false, y_align: St.Align.START, style_class: 'vfade menu-applications-scrollbox' )
    @categoriesScrollBox.set_width(192)
    @applicationsBox = new St.BoxLayout( style_class: 'menu-applications-box', vertical:true )
    @applicationsScrollBox = new St.ScrollView( x_fill: true, y_fill: false, y_align: St.Align.START, style_class: 'vfade menu-applications-scrollbox' )
    @applicationsScrollBox.set_width(244)
    @a11y_settings = new Gio.Settings( schema: "org.gnome.desktop.a11y.applications" )
    @a11y_settings.connect("changed::screen-magnifier-enabled", Lang.bind(this, @_updateVFade))
    @_updateVFade()

    @settings.bindProperty(Settings.BindingDirection.IN, "enable-autoscroll", "autoscroll_enabled", @_update_autoscroll, null)
    @_update_autoscroll()

    @settings.bindProperty(Settings.BindingDirection.IN, "favorite-icon-size", "favorite_icon_size", @_refreshFavs, null)

    vscroll = @applicationsScrollBox.get_vscroll_bar()
    vscroll.connect 'scroll-start', () =>
      @menu.passEvents = true

    vscroll.connect 'scroll-stop',() =>
      @menu.passEvents = false

    vscroll = @categoriesScrollBox.get_vscroll_bar()
    vscroll.connect 'scroll-start', () =>
      @menu.passEvents = true

    vscroll.connect 'scroll-stop', () =>
      @menu.passEvents = false

    @_refreshFavs()

    @separator = new PopupMenu.PopupSeparatorMenuItem()
    @separator.actor.set_style("padding: 0em 1em")

    @appsButton = new AllProgramsItem(_(@allProgramsLabel), "forward", this, false)

    @leftPaneBox = new St.BoxLayout( style_class: 'menu-favorites-box', vertical: true )
    @rightButtonsBox = new RightButtonsBox(this, @menu)

    @rightButtonsBox.actor.style_class = "right-buttons-box"
    @mainBox = new St.BoxLayout( style_class: 'menu-applications-box', vertical:false )

    @applicationsByCategory = 
    @_refreshApps()

    @appBoxIter = new VisibleChildIterator(this, @applicationsBox)
    @applicationsBox._vis_iter = @appBoxIter
    @catBoxIter = new VisibleChildIterator(this, @categoriesBox)
    @categoriesBox._vis_iter = @catBoxIter

    @leftPane.set_child(@favsBox,  y_align: St.Align.END,y_fill: false )

    @selectedAppBox.add_actor(@selectedAppTitle)
    @selectedAppBox.add_actor(@selectedAppDescription)
    @categoriesScrollBox.add_actor(@categoriesBox)
    @categoriesScrollBox.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
    @applicationsScrollBox.add_actor(@applicationsBox)
    @applicationsScrollBox.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
    @categoriesApplicationsBox.actor.add_actor(@categoriesScrollBox)
    @categoriesApplicationsBox.actor.add_actor(@applicationsScrollBox)
    @appsBox.add_actor(@selectedAppBox)
    @appsBox.add_actor(@categoriesApplicationsBox.actor)
    @searchBox.add_actor(@searchEntry)
    @leftPaneBox.add_actor(@leftPane)
    @leftPaneBox.add_actor(@separator.actor)
    @leftPaneBox.add_actor(@appsButton.actor)
    @leftPaneBox.add_actor(@searchBox)
    @mainBox.add_actor(@leftPaneBox)
    @mainBox.add_actor(@rightButtonsBox.actor)
    section.actor.add_actor(@mainBox)

    Mainloop.idle_add () =>
      @_clearAllSelections()
    return

  switchPanes:(pane) ->
    if pane is "apps"
      @leftPane.set_child(@appsBox)
      @appsButton.label.set_text(" "+_(@favoritesLabel))
      @rightButtonsBox.actor.hide()
      @_appletStyles("apps")
    else
      @leftPane.set_child(@favsBox)
      @appsButton.label.set_text(" "+_(@allProgramsLabel))
      if @menu.showQuicklinks
        @rightButtonsBox.actor.show()
      @_appletStyles("favs")
    @rightButtonsBox.shutdown.label.set_text(_(@shutdownLabel))
    return

  _updateVFade:() ->
    mag_on = @a11y_settings.get_boolean("screen-magnifier-enabled")
    if mag_on
      @applicationsScrollBox.style_class = "menu-applications-scrollbox"
    else
      @applicationsScrollBox.style_class = "vfade menu-applications-scrollbox"
    return

  _update_autoscroll:() ->
    @applicationsScrollBox.set_auto_scrolling(@autoscroll_enabled)


  _clearAllSelections:() ->
    actors = @applicationsBox.get_children()
    for actor in actors
      actor.style_class = "menu-application-button"
      actor.hide()
    actors = @categoriesBox.get_children()
    for actor in actors
      actor.style_class = "menu-category-button"
      actor.show()
    return

  _select_category:(dir, categoryButton) ->
    if dir
      @_displayButtons(@_listApplications(dir.get_menu_id()))
    else
      @_displayButtons(@_listApplications(null))
    @closeApplicationsContextMenus(null, false)
    @_scrollToCategoryButton(categoryButton)
    return

  closeApplicationsContextMenus:(excludeApp, animate) ->
    for app in @_applicationsButtons
      if app isnt excludeApp and app.menu.isOpen
        if animate
          app.toggleMenu()
        else
          app.closeMenu()

  _onApplicationButtonRealized:(actor) ->
    if actor.get_width() > @_applicationsBoxWidth
      @_applicationsBoxWidth = actor.get_width()
      @applicationsBox.set_width(@_applicationsBoxWidth + 20)
    return

  _displayButtons:(appCategory, places, recent, apps, autocompletes) ->
    innerapps = @applicationsBox.get_children()
    for app in innerapps
      app.hide()

    if appCategory
      if appCategory is "all"
        @_applicationsButtons.forEach (item, index) ->
          if not item.actor.visible
            item.actor.show()
          return
      else
        @_applicationsButtons.forEach (item, index) ->
          if item.category.indexOf(appCategory) isnt -1
            if not item.actor.visible
              item.actor.show()
            return
          else
            if item.actor.visible
              item.actor.hide()

    else if apps
      for button in @_applicationsButtons
        if apps.indexOf(button.name) isnt -1
          if not button.actor.visible
            button.actor.show()

        else
          if button.actor.visible
            button.actor.hide()

    else
      @_applicationsButtons.forEach (item, index) ->
        if item.actor.visible
          item.actor.hide()
          return

    if places
      if places is -1
        @_placesButtons.forEach (item, index) ->
          item.actor.show()
          return
      else
        for button in @_placesButtons
          if places.indexOf(button.button_name) isnt -1
            if not button.actor.visible
              button.actor.show()
          else
            if button.actor.visible
              button.actor.hide()

    else
      @_placesButtons.forEach (item, index) ->
        if item.actor.visible
          item.actor.hide()
        return

    if recent
      if recent is -1
        @_recentButtons.forEach (item, index) ->
          if not item.actor.visible
            item.actor.show()
          return
      else
        for button in @_recentButtons
          if recent.indexOf(button.button_name) isnt -1
            if not @_recentButtons[i].actor.visible
              @_recentButtons[i].actor.show()
          else
            if button.actor.visible
              button.actor.hide()
    else
      @_recentButtons.forEach (item, index) ->
        if item.actor.visible
          item.actor.hide()

    if autocompletes
        for auto in autocompletes
          button = new TransientButton(this, auto)
          button.actor.connect('realize', Lang.bind(this, @_onApplicationButtonRealized))
          button.actor.connect('leave-event', Lang.bind(this, @_appLeaveEvent, button))
          @_addEnterEvent(button, Lang.bind(this, @_appEnterEvent, button))
          @_transientButtons.push(button)
          @applicationsBox.add_actor(button.actor)
          button.actor.realize()

    return

  _setCategoriesButtonActive:(active) ->
    try
      categoriesButtons = @categoriesBox.get_children()
      for button in categoriesButtons
        if active
          button.set_style_class_name("menu-category-button")
        else
          button.set_style_class_name("menu-category-button-greyed")
    catch e
      global.log(e)
    return

  resetSearch:() ->
    @searchEntry.set_text("")
    @searchActive = false
    @_clearAllSelections()
    @_setCategoriesButtonActive(true)
    global.stage.set_key_focus(@searchEntry)
    return

  _onSearchTextChanged: (se, prop) ->
    if @menuIsOpening
      @menuIsOpening = false
      return false
    else
      searchString = @searchEntry.get_text()
      @searchActive = searchString isnt ''
      @_fileFolderAccessActive = @searchActive and @searchFilesystem
      @_clearAllSelections()

      if @searchActive
        @searchEntry.set_secondary_icon(@_searchActiveIcon)
        if @_searchIconClickedId is 0
          @_searchIconClickedId = @searchEntry.connect 'secondary-icon-clicked',() ->
            @resetSearch()
            @_select_category(null, @_allAppsCategoryButton)
            return
        @_setCategoriesButtonActive(false)
        @_doSearch()
      else
        if @_searchIconClickedId > 0
          @searchEntry.disconnect(@_searchIconClickedId)
        @_searchIconClickedId = 0
        @searchEntry.set_secondary_icon(@_searchInactiveIcon)
        @_previousSearchPattern = ""
        @_setCategoriesButtonActive(true)
        @_select_category(null, @_allAppsCategoryButton)
    return false

  _listBookmarks:(pattern) ->
    bookmarks = Main.placesManager.getBookmarks()
    res = new Array()
    for bookmark in bookmarks
      if not pattern or bookmark.name.toLowerCase().indexOf(pattern) isnt -1 then res.push(bookmark)
    return res

  _listDevices:(pattern)->
    devices = Main.placesManager.getMounts()
    res = new Array()
    for device in devices
      if not pattern or device.name.toLowerCase().indexOf(pattern) isnt -1 then res.push(device)
    return res

  _listApplications:(category_menu_id, pattern) ->
    applist = new Array()
    if category_menu_id
      applist = category_menu_id
    else
      applist = "all"
    if pattern
      res = new Array()
      for button in @_applicationsButtons
        app = button.app
        if app.get_name().toLowerCase().indexOf(pattern) isnt -1 or (app.get_description() and app.get_description().toLowerCase().indexOf(pattern) isnt -1) or (app.get_id() and app.get_id().slice(0, -8).toLowerCase().indexOf(pattern) isnt -1)
          res.push(app.get_name())
    else
      res = applist
    return res

  _doSearch:() ->
    if @leftPane.get_child() is @favsBox then @switchPanes("apps")
    pattern = @searchEntryText.get_text().replace(/^\s+/g, '').replace(/\s+$/g, '').toLowerCase()
    if pattern is @_previousSearchPattern then return false
    @_previousSearchPattern = pattern
    @_activeContainer = null
    @_activeActor = null
    @_selectedItemIndex = null
    @_previousTreeItemIndex = null
    @_previousTreeSelectedActor = null
    @_previousSelectedActor = null

    # _listApplications returns all the applications when the search
    # string is zero length. This will happend if you type a space
    # in the search entry.
    if pattern.length is 0
      return false

    appResults = @_listApplications(null, pattern)
    placesResults = new Array()
    bookmarks = @_listBookmarks(pattern)
    for bookmark in bookmarks
      placesResults.push(bookmark.name)
    devices = @_listDevices(pattern)
    for device in devices
      placesResults.push(device.name)
    recentResults = new Array()
    for button in @_recentButtons.length
      if not(button instanceof RecentClearButton) and button.button_name.toLowerCase().indexOf(pattern) isnt -1
        recentResults.push(button.button_name)

    acResults = new Array() # search box autocompletion results
    if @searchFilesystem
      # Don't use the pattern here, as filesystem is case sensitive
      acResults = @_getCompletions(@searchEntryText.get_text())
    @_displayButtons(null, placesResults, recentResults, appResults, acResults)

    @appBoxIter.reloadVisible()
    if @appBoxIter.getNumVisibleChildren() > 0
      item_actor = @appBoxIter.getFirstVisible()
      @_selectedItemIndex = @appBoxIter.getAbsoluteIndexOfChild(item_actor)
      @_activeContainer = @applicationsBox
      if item_actor and item_actor isnt- @searchEntry
        item_actor._delegate.emit('enter-event')
    return false

  _getCompletion:(text) ->
    if text.indexOf('/') isnt -1
      if text.substr(text.length - 1) is '/'
        return ''
      else
        return @_pathCompleter.get_completion_suffix(text)
    else
    return false

  _getCompletions:(text) ->
    if text.indexOf('/') isnt -1
      return @_pathCompleter.get_completions(text)
    else
      return new Array()

  _run:(input) ->
    command = input

    @_commandError = false
    if input
      path = null
      if input.charAt(0) is '/'
        path = input
      else
        if input.charAt(0) is '~'
          input = input.slice(1)
        path = GLib.get_home_dir() + '/' + input

        if GLib.file_test(path, GLib.FileTest.EXISTS)
          file = Gio.file_new_for_path(path)
          try
            Gio.app_info_launch_default_for_uri(file.get_uri(),
            global.create_app_launch_context())
          catch e
            # The exception from gjs contains an error string like:
            #     Error invoking Gio.app_info_launch_default_for_uri: No application
            #     is registered as handling this file
            # We are only interested in the part after the first colon.
            #var message = e.message.replace(/[^:]*: *(.+)/, '$1')
            return false
        else
          return false
    return true

main = (metadata, orientation, panel_height, instance_id) -> new MyApplet(orientation, panel_height, instance_id)

