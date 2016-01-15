MyApplet = (orientation, panel_height, instance_id) ->
  @_init orientation, panel_height, instance_id
  return

#
#            global.display.connect('overlay-key', Lang.bind(this, function(){
#                try{
#                    this.menu.toggle();
#                }
#                catch(e) {
#                    global.logError(e);
#                }
#            }));
#	    

# Jump from Categories to Appications

# Jump from Appications to Categories

# Need preload data before get completion. GFilenameCompleter load content of parent directory.
# Parent directory for /usr/include/ is /usr/. So need to add fake name('a').

#Remove all categories

# Sort apps and add to applicationsBox

# Now generate Places category and places buttons and add to the list

# Now generate recent category and recent files buttons and add to the list

#Remove all favorites

#Load favorites again
# + 3 because we're adding 3 system buttons at the bottom

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
MyApplet:: =
  __proto__: Applet.TextIconApplet::
  _init: (orientation, panel_height, instance_id) ->
    Applet.TextIconApplet::_init.call this, orientation, panel_height, instance_id
    try
      @set_applet_tooltip _("Menu")
      @menuManager = new PopupMenu.PopupMenuManager(this)
      @menu = new Applet.AppletPopupMenu(this, orientation)
      @menuManager.addMenu @menu
      @actor.connect "key-press-event", Lang.bind(this, @_onSourceKeyPress)
      @settings = new Settings.AppletSettings(this, "Cin7Menu@darkoverlordofdata.com", instance_id)
      @settings.bindProperty Settings.BindingDirection.IN, "show-recent", "showRecent", @_refreshPlacesAndRecent, null
      @settings.bindProperty Settings.BindingDirection.IN, "show-places", "showPlaces", @_refreshPlacesAndRecent, null
      @settings.bindProperty Settings.BindingDirection.IN, "activate-on-hover", "activateOnHover", @_updateActivateOnHover, null
      @_updateActivateOnHover()
      @menu.actor.add_style_class_name "menu-background"
      @settings.bindProperty Settings.BindingDirection.IN, "menu-icon", "menuIcon", @_updateIconAndLabel, null
      @settings.bindProperty Settings.BindingDirection.IN, "menu-label", "menuLabel", @_updateIconAndLabel, null
      @settings.bindProperty Settings.BindingDirection.IN, "all-programs-label", "allProgramsLabel", null, null
      @settings.bindProperty Settings.BindingDirection.IN, "favorites-label", "favoritesLabel", null, null
      @settings.bindProperty Settings.BindingDirection.IN, "shutdown-label", "shutdownLabel", null, null
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
      @menu.connect "open-state-changed", Lang.bind(this, @_onOpenStateChanged)
      appsys.connect "installed-changed", Lang.bind(this, @_refreshApps)
      AppFavorites.getAppFavorites().connect "changed", Lang.bind(this, @_refreshFavs)
      @settings.bindProperty Settings.BindingDirection.IN, "hover-delay", "hover_delay_ms", @_update_hover_delay, null
      @_update_hover_delay()
      @settings.bindProperty Settings.BindingDirection.IN, "show-quicklinks", "showQuicklinks", @_updateQuickLinksView, null
      @_updateQuickLinksView()
      @settings.bindProperty Settings.BindingDirection.IN, "show-quicklinks-shutdown-menu", "showQuicklinksShutdownMenu", @_updateQuickLinksShutdownView, null
      @_updateQuickLinksShutdownView()
      Main.placesManager.connect "places-updated", Lang.bind(this, @_refreshApps)
      @RecentManager.connect "changed", Lang.bind(this, @_refreshApps)
      @_fileFolderAccessActive = false
      @_pathCompleter = new Gio.FilenameCompleter()
      @_pathCompleter.set_dirs_only false
      @lastAcResults = new Array()
      @settings.bindProperty Settings.BindingDirection.IN, "search-filesystem", "searchFilesystem", null, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-0", "quicklink_0", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-1", "quicklink_1", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-2", "quicklink_2", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-3", "quicklink_3", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-4", "quicklink_4", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-5", "quicklink_5", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-6", "quicklink_6", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-7", "quicklink_7", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-8", "quicklink_8", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-9", "quicklink_9", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-10", "quicklink_10", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-11", "quicklink_11", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-12", "quicklink_12", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-13", "quicklink_13", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-14", "quicklink_14", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-15", "quicklink_15", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-16", "quicklink_16", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-17", "quicklink_17", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-18", "quicklink_18", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-19", "quicklink_19", @_updateQuickLinks, null
      @settings.bindProperty Settings.BindingDirection.IN, "quicklink-options", "quicklinkOptions", @_updateQuickLinks, null
      @_updateQuickLinks()
    catch e
      global.logError e
    return

  openMenu: ->
    @menu.open true
    return

  _updateActivateOnHover: ->
    if @_openMenuId
      @actor.disconnect @_openMenuId
      @_openMenuId = 0
    @_openMenuId = @actor.connect("enter-event", Lang.bind(this, @openMenu))  if @activateOnHover
    return

  _updateQuickLinksView: ->
    @menu.showQuicklinks = @showQuicklinks
    if @menu.showQuicklinks
      @rightButtonsBox.actor.show()
    else
      @rightButtonsBox.actor.hide()
    return

  _updateQuickLinksShutdownView: ->
    @menu.showQuicklinksShutdownMenu = @showQuicklinksShutdownMenu
    if @menu.showQuicklinksShutdownMenu
      @rightButtonsBox.shutdown.actor.show()
      @rightButtonsBox.shutdownMenu.actor.show()
      unless @quicklinkOptions is "icons"
        @rightButtonsBox.shutDownMenuBox.set_style "min-height: 82px"
      else
        @rightButtonsBox.shutDownIconBox.show()
    else
      @rightButtonsBox.shutdown.actor.hide()
      @rightButtonsBox.shutdownMenu.actor.hide()
      @rightButtonsBox.shutDownIconBox.hide()
      @rightButtonsBox.shutDownMenuBox.set_style "min-height: 1px"
    @favsBox.style = "min-height: " + (@rightButtonsBox.actor.get_height() - 100) + "px;min-width: 235px;"
    return

  _updateQuickLinks: ->
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
    @rightButtonsBox._update_quicklinks @quicklinkOptions
    @_updateQuickLinksShutdownView()
    @favsBox.style = "min-height: " + (@rightButtonsBox.actor.get_height() - 100) + "px;min-width: 235px;"
    return

  _update_hover_delay: ->
    @hover_delay = @hover_delay_ms / 1000
    return

  on_orientation_changed: (orientation) ->
    @menu.destroy()
    @menu = new Applet.AppletPopupMenu(this, orientation)
    @menuManager.addMenu @menu
    @menu.actor.add_style_class_name "menu-background"
    @menu.connect "open-state-changed", Lang.bind(this, @_onOpenStateChanged)
    @_display()
    @_updateQuickLinksShutdownView()
    @_updateQuickLinks()
    return

  _launch_editor: ->
    Util.spawnCommandLine "cinnamon-menu-editor"
    return

  on_applet_clicked: (event) ->
    @menu.toggle()
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
      @switchPanes "favs"
      @_appletStyles()
      global.stage.set_key_focus @searchEntry
      @_selectedItemIndex = null
      @_activeContainer = null
      @_activeActor = null
      monitorHeight = Main.layoutManager.primaryMonitor.height
      @_select_category null, @_allAppsCategoryButton
    else
      @actor.remove_style_pseudo_class "active"
      @resetSearch()  if @searchActive
      @selectedAppTitle.set_text ""
      @selectedAppDescription.set_text ""
      @_previousTreeItemIndex = null
      @_previousTreeSelectedActor = null
      @_previousSelectedActor = null
      @closeApplicationsContextMenus null, false
      @_clearAllSelections()
    return

  destroy: ->
    @actor._delegate = null
    @menu.destroy()
    @actor.destroy()
    @emit "destroy"
    return

  _updateIconAndLabel: ->
    @set_applet_label @menuLabel
    try
      @set_applet_icon_path @menuIcon
    catch e
      global.logWarning "Could not load icon file \"" + @menuIcon + "\" for menu button"
    return

  _onMenuKeyPress: (actor, event) ->
    symbol = event.get_key_symbol()
    item_actor = undefined
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
    else if symbol is Clutter.KEY_Down
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
      item_actor = @appBoxIter.getFirstVisible()
      index = @appBoxIter.getAbsoluteIndexOfChild(item_actor)
    else if symbol is Clutter.KEY_Left and @_activeContainer is @applicationsBox and not @searchActive
      @_previousSelectedActor = @applicationsBox.get_child_at_index(index)
      item_actor = (if (@_previousTreeSelectedActor?) then @_previousTreeSelectedActor else @catBoxIter.getFirstVisible())
      index = @catBoxIter.getAbsoluteIndexOfChild(item_actor)
    else if @_activeContainer is @applicationsBox and (symbol is Clutter.KEY_Return or symbol is Clutter.KP_Enter)
      item_actor = @applicationsBox.get_child_at_index(@_selectedItemIndex)
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
      if @_activeContainer isnt @applicationsBox and parent isnt @_activeContainer
        @_previousTreeItemIndex = @_selectedItemIndex
        @_previousTreeSelectedActor = @_activeActor
        @_previousSelectedActor = null
      @_previousTreeSelectedActor.style_class = "menu-category-button"  if @_previousTreeSelectedActor and @_activeContainer isnt @categoriesBox and parent isnt @_activeContainer and button isnt @_previousTreeSelectedActor
      parent._vis_iter.reloadVisible()  unless parent is @_activeContainer
      _maybePreviousActor = @_activeActor
      if _maybePreviousActor and @_activeContainer is @applicationsBox
        @_previousSelectedActor = _maybePreviousActor
        @_clearPrevAppSelection()
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

  _clearPrevAppSelection: (actor) ->
    @_previousSelectedActor.style_class = "menu-application-button"  if @_previousSelectedActor and @_previousSelectedActor isnt actor
    return

  _clearPrevCatSelection: (actor) ->
    @_previousSelectedActor.style_class = "menu-category-button"  if @_previousSelectedActor and @_previousSelectedActor isnt actor
    return

  _appletStyles: (pane) ->
    favsWidth = (@favsBox.get_allocation_box().x2 - @favsBox.get_allocation_box().x1)
    scrollWidth = @searchBox.get_width() + @rightButtonsBox.actor.get_width()
    @searchEntry.style = "width:" + favsWidth + "px"
    @appsButton.box.style = "width:" + favsWidth + "px"
    scrollBoxHeight = (@favsBox.get_allocation_box().y2 - @favsBox.get_allocation_box().y1) - (@selectedAppBox.get_allocation_box().y2 - @selectedAppBox.get_allocation_box().y1)
    @applicationsScrollBox.style = "width: " + ((scrollWidth) * 0.55) + "px;height: " + scrollBoxHeight + "px;"
    @categoriesScrollBox.style = "width: " + ((scrollWidth) * 0.45) + "px;height: " + scrollBoxHeight + "px;"
    return

  _refreshApps: ->
    @applicationsBox.destroy_all_children()
    @_applicationsButtons = new Array()
    @_placesButtons = new Array()
    @_recentButtons = new Array()
    @_applicationsBoxWidth = 0
    @categoriesBox.destroy_all_children()
    @_allAppsCategoryButton = new CategoryButton(null)
    @_addEnterEvent @_allAppsCategoryButton, Lang.bind(this, ->
      unless @searchActive
        @_allAppsCategoryButton.isHovered = true
        @_allAppsCategoryButton.actor.style_class = "menu-category-button-selected"
        if @hover_delay > 0
          Tweener.addTween this,
            time: @hover_delay
            onComplete: ->
              if @_allAppsCategoryButton.isHovered
                @_clearPrevCatSelection @_allAppsCategoryButton.actor
                @_select_category null, @_allAppsCategoryButton
              else
                @_allAppsCategoryButton.actor.style_class = "menu-category-button"
              return

        else
          @_clearPrevCatSelection @_allAppsCategoryButton.actor
          @_select_category null, @_allAppsCategoryButton
      return
    )
    @_allAppsCategoryButton.actor.connect "leave-event", Lang.bind(this, ->
      @_allAppsCategoryButton.actor.style_class = "menu-category-button"  unless @searchActive
      @_previousSelectedActor = @_allAppsCategoryButton.actor
      @_allAppsCategoryButton.isHovered = false
      return
    )
    @categoriesBox.add_actor @_allAppsCategoryButton.actor
    trees = [appsys.get_tree()]
    for i of trees
      tree = trees[i]
      root = tree.get_root_directory()
      iter = root.iter()
      nextType = undefined
      until (nextType = iter.next()) is CMenu.TreeItemType.INVALID
        if nextType is CMenu.TreeItemType.DIRECTORY
          dir = iter.get_directory()
          continue  if dir.get_is_nodisplay()
          @applicationsByCategory[dir.get_menu_id()] = new Array()
          @_loadCategory dir
          if @applicationsByCategory[dir.get_menu_id()].length > 0
            categoryButton = new CategoryButton(dir)
            @_addEnterEvent categoryButton, Lang.bind(this, ->
              unless @searchActive
                categoryButton.isHovered = true
                categoryButton.actor.style_class = "menu-category-button-selected"
                if @hover_delay > 0
                  Tweener.addTween this,
                    time: @hover_delay
                    onComplete: ->
                      if categoryButton.isHovered
                        @_clearPrevCatSelection categoryButton.actor
                        @_select_category dir, categoryButton
                      else
                        categoryButton.actor.style_class = "menu-category-button"
                      return

                else
                  @_clearPrevCatSelection categoryButton.actor
                  @_select_category dir, categoryButton
              return
            )
            categoryButton.actor.connect "leave-event", Lang.bind(this, ->
              categoryButton.actor.style_class = "menu-category-button"  unless @searchActive
              @_previousSelectedActor = categoryButton.actor
              categoryButton.isHovered = false
              return
            )
            @categoriesBox.add_actor categoryButton.actor
    @_applicationsButtons.sort (a, b) ->
      sr = a.app.get_name().toLowerCase() > b.app.get_name().toLowerCase()
      sr

    i = 0

    while i < @_applicationsButtons.length
      @applicationsBox.add_actor @_applicationsButtons[i].actor
      @_applicationsButtons[i].actor.realize()
      @applicationsBox.add_actor @_applicationsButtons[i].menu.actor
      i++
    if @showPlaces
      @placesButton = new PlaceCategoryButton()
      @_addEnterEvent @placesButton, Lang.bind(this, ->
        unless @searchActive
          @placesButton.isHovered = true
          @placesButton.actor.style_class = "menu-category-button-selected"
          Tweener.addTween this,
            time: @hover_delay
            onComplete: ->
              if @placesButton.isHovered
                @_clearPrevCatSelection @placesButton
                @_displayButtons null, -1
              return

        @_scrollToCategoryButton @placesButton
        return
      )
      @placesButton.actor.connect "leave-event", Lang.bind(this, ->
        @placesButton.actor.style_class = "menu-category-button"  unless @searchActive
        @_previousSelectedActor = @placesButton.actor
        @placesButton.isHovered = false
        return
      )
      @categoriesBox.add_actor @placesButton.actor
      bookmarks = @_listBookmarks()
      devices = @_listDevices()
      places = bookmarks.concat(devices)
      i = 0

      while i < places.length
        place = places[i]
        button = new PlaceButton(this, place, place.name)
        @_addEnterEvent button, Lang.bind(this, ->
          @_clearPrevAppSelection button.actor
          button.actor.style_class = "menu-application-button-selected"
          @_scrollToButton button
          @selectedAppDescription.set_text button.place.id.slice(16)
          return
        )
        button.actor.connect "leave-event", Lang.bind(this, ->
          button.actor.style_class = "menu-application-button"
          @_previousSelectedActor = button.actor
          @selectedAppDescription.set_text ""
          return
        )
        @_placesButtons.push button
        @applicationsBox.add_actor button.actor
        i++
    if @showRecent
      @recentButton = new RecentCategoryButton()
      @_addEnterEvent @recentButton, Lang.bind(this, ->
        unless @searchActive
          @recentButton.isHovered = true
          @recentButton.actor.style_class = "menu-category-button-selected"
          Tweener.addTween this,
            time: @hover_delay
            onComplete: ->
              if @recentButton.isHovered
                @_clearPrevCatSelection @recentButton.actor
                @_displayButtons null, null, -1
              return

        @_scrollToCategoryButton @recentButton
        return
      )
      @recentButton.actor.connect "leave-event", Lang.bind(this, ->
        @recentButton.actor.style_class = "menu-category-button"  unless @searchActive
        @_previousSelectedActor = @recentButton.actor
        @recentButton.isHovered = false
        return
      )
      @categoriesBox.add_actor @recentButton.actor
      id = 0

      while id < MAX_RECENT_FILES and id < @RecentManager._infosByTimestamp.length
        button = new RecentButton(this, @RecentManager._infosByTimestamp[id])
        @_addEnterEvent button, Lang.bind(this, ->
          @_clearPrevAppSelection button.actor
          button.actor.style_class = "menu-application-button-selected"
          @_scrollToButton button
          @selectedAppDescription.set_text button.file.uri.slice(7)
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
        id++
      if @RecentManager._infosByTimestamp.length > 0
        button = new RecentClearButton(this)
        @_addEnterEvent button, Lang.bind(this, ->
          @_clearPrevAppSelection button.actor
          button.actor.style_class = "menu-application-button-selected"
          @_scrollToButton button
          return
        )
        button.actor.connect "leave-event", Lang.bind(this, ->
          button.actor.style_class = "menu-application-button"
          @_previousSelectedActor = button.actor
          return
        )
        @_recentButtons.push button
        @applicationsBox.add_actor button.actor
    @_setCategoriesButtonActive not @searchActive
    return

  _refreshFavs: ->
    @favsBox.get_children().forEach Lang.bind(this, (child) ->
      child.destroy()
      return
    )
    favoritesBox = new FavoritesBox()
    @favsBox.add_actor favoritesBox.actor,
      y_align: St.Align.END
      y_fill: false

    @_favoritesButtons = new Array()
    launchers = global.settings.get_strv("favorite-apps")
    appSys = Cinnamon.AppSystem.get_default()
    j = 0
    i = 0

    while i < launchers.length
      app = appSys.lookup_app(launchers[i])
      app = appSys.lookup_settings_app(launchers[i])  unless app
      if app
        button = new FavoritesButton(this, app, launchers.length, @favorite_icon_size)
        @_favoritesButtons[app] = button
        favoritesBox.actor.add_actor button.actor,
          y_align: St.Align.END
          y_fill: false

        favoritesBox.actor.add_actor button.menu.actor,
          y_align: St.Align.END
          y_fill: false

        button.actor.connect "enter-event", Lang.bind(this, ->
          @selectedAppTitle.set_text button.app.get_name()
          if button.app.get_description()
            @selectedAppDescription.set_text button.app.get_description()
          else
            @selectedAppDescription.set_text ""
          return
        )
        button.actor.connect "leave-event", Lang.bind(this, ->
          @selectedAppTitle.set_text ""
          @selectedAppDescription.set_text ""
          return
        )
        ++j
      ++i
    return

  _loadCategory: (dir, top_dir) ->
    iter = dir.iter()
    dupe = false
    nextType = undefined
    top_dir = dir  unless top_dir
    until (nextType = iter.next()) is CMenu.TreeItemType.INVALID
      if nextType is CMenu.TreeItemType.ENTRY
        entry = iter.get_entry()
        unless entry.get_app_info().get_nodisplay()
          app = appsys.lookup_app_by_tree_entry(entry)
          dupe = @find_dupe(app)
          unless dupe
            applicationButton = new ApplicationButton(this, app)
            applicationButton.actor.connect "realize", Lang.bind(this, @_onApplicationButtonRealized)
            applicationButton.actor.connect "leave-event", Lang.bind(this, @_appLeaveEvent, applicationButton)
            @_addEnterEvent applicationButton, Lang.bind(this, @_appEnterEvent, applicationButton)
            @_applicationsButtons.push applicationButton
            applicationButton.category.push top_dir.get_menu_id()
            @applicationsByCategory[top_dir.get_menu_id()].push app.get_name()
          else
            i = 0

            while i < @_applicationsButtons.length
              @_applicationsButtons[i].category.push dir.get_menu_id()  if @_applicationsButtons[i].app is app
              i++
            @applicationsByCategory[dir.get_menu_id()].push app.get_name()
      else if nextType is CMenu.TreeItemType.DIRECTORY
        subdir = iter.get_directory()
        @applicationsByCategory[subdir.get_menu_id()] = new Array()
        @_loadCategory subdir, top_dir
    return

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
    @_clearPrevAppSelection applicationButton.actor
    applicationButton.actor.style_class = "menu-application-button-selected"
    @_scrollToButton applicationButton
    return

  find_dupe: (app) ->
    ret = false
    i = 0

    while i < @_applicationsButtons.length
      if app is @_applicationsButtons[i].app
        ret = true
        break
      i++
    ret

  _scrollToButton: (button) ->
    current_scroll_value = @applicationsScrollBox.get_vscroll_bar().get_adjustment().get_value()
    box_height = @applicationsScrollBox.get_allocation_box().y2 - @applicationsScrollBox.get_allocation_box().y1
    new_scroll_value = current_scroll_value
    new_scroll_value = button.actor.get_allocation_box().y1 - 10  if current_scroll_value > button.actor.get_allocation_box().y1 - 10
    new_scroll_value = button.actor.get_allocation_box().y2 - box_height + 10  if box_height + current_scroll_value < button.actor.get_allocation_box().y2 + 10
    @applicationsScrollBox.get_vscroll_bar().get_adjustment().set_value new_scroll_value  unless new_scroll_value is current_scroll_value
    return

  _scrollToCategoryButton: (button) ->
    current_scroll_value = @categoriesScrollBox.get_vscroll_bar().get_adjustment().get_value()
    box_height = @categoriesScrollBox.get_allocation_box().y2 - @categoriesScrollBox.get_allocation_box().y1
    new_scroll_value = current_scroll_value
    new_scroll_value = button.actor.get_allocation_box().y1 - 10  if current_scroll_value > button.actor.get_allocation_box().y1 - 10
    new_scroll_value = button.actor.get_allocation_box().y2 - box_height + 10  if box_height + current_scroll_value < button.actor.get_allocation_box().y2 + 10
    @categoriesScrollBox.get_vscroll_bar().get_adjustment().set_value new_scroll_value  unless new_scroll_value is current_scroll_value
    return

  _display: ->
    @_activeContainer = null
    @_activeActor = null
    section = new PopupMenu.PopupMenuSection()
    @menu.addMenuItem section
    @leftPane = new St.Bin()
    @favsBox = new St.BoxLayout(vertical: true)
    @favsBox.style = "min-height: 152px;min-width: 235px;"
    @appsBox = new St.BoxLayout(vertical: true)
    @searchBox = new St.BoxLayout(style_class: "menu-search-box")
    @searchBox.set_style "padding-right: 0px;padding-left: 0px"
    @searchEntry = new St.Entry(
      name: "menu-search-entry"
      hint_text: _("Type to search...")
      track_hover: true
      can_focus: true
    )
    @searchEntry.set_secondary_icon @_searchInactiveIcon
    @searchActive = false
    @searchEntryText = @searchEntry.clutter_text
    @searchEntryText.connect "text-changed", Lang.bind(this, @_onSearchTextChanged)
    @searchEntryText.connect "key-press-event", Lang.bind(this, @_onMenuKeyPress)
    @_previousSearchPattern = ""
    @selectedAppBox = new St.BoxLayout(
      style_class: "menu-selected-app-box"
      vertical: true
    )
    @selectedAppTitle = new St.Label(
      style_class: "menu-selected-app-title"
      text: ""
    )
    @selectedAppBox.add_actor @selectedAppTitle
    @selectedAppDescription = new St.Label(
      style_class: "menu-selected-app-description"
      text: ""
    )
    @categoriesApplicationsBox = new CategoriesApplicationsBox()
    @categoriesBox = new St.BoxLayout(
      style_class: "menu-categories-box"
      vertical: true
    )
    @categoriesScrollBox = new St.ScrollView(
      x_fill: true
      y_fill: false
      y_align: St.Align.START
      style_class: "vfade menu-applications-scrollbox"
    )
    @categoriesScrollBox.set_width 192
    @applicationsBox = new St.BoxLayout(
      style_class: "menu-applications-box"
      vertical: true
    )
    @applicationsScrollBox = new St.ScrollView(
      x_fill: true
      y_fill: false
      y_align: St.Align.START
      style_class: "vfade menu-applications-scrollbox"
    )
    @applicationsScrollBox.set_width 244
    @a11y_settings = new Gio.Settings(schema: "org.gnome.desktop.a11y.applications")
    @a11y_settings.connect "changed::screen-magnifier-enabled", Lang.bind(this, @_updateVFade)
    @_updateVFade()
    @settings.bindProperty Settings.BindingDirection.IN, "enable-autoscroll", "autoscroll_enabled", @_update_autoscroll, null
    @_update_autoscroll()
    @settings.bindProperty Settings.BindingDirection.IN, "favorite-icon-size", "favorite_icon_size", @_refreshFavs, null
    vscroll = @applicationsScrollBox.get_vscroll_bar()
    vscroll.connect "scroll-start", Lang.bind(this, ->
      @menu.passEvents = true
      return
    )
    vscroll.connect "scroll-stop", Lang.bind(this, ->
      @menu.passEvents = false
      return
    )
    vscroll = @categoriesScrollBox.get_vscroll_bar()
    vscroll.connect "scroll-start", Lang.bind(this, ->
      @menu.passEvents = true
      return
    )
    vscroll.connect "scroll-stop", Lang.bind(this, ->
      @menu.passEvents = false
      return
    )
    @_refreshFavs()
    @separator = new PopupMenu.PopupSeparatorMenuItem()
    @separator.actor.set_style "padding: 0em 1em;"
    @appsButton = new AllProgramsItem(_(@allProgramsLabel), "forward", this, false)
    @leftPaneBox = new St.BoxLayout(
      style_class: "menu-favorites-box"
      vertical: true
    )
    @rightButtonsBox = new RightButtonsBox(this, @menu)
    @rightButtonsBox.actor.style_class = "right-buttons-box"
    @mainBox = new St.BoxLayout(
      style_class: "menu-applications-box"
      vertical: false
    )
    @applicationsByCategory = {}
    @_refreshApps()
    @appBoxIter = new VisibleChildIterator(this, @applicationsBox)
    @applicationsBox._vis_iter = @appBoxIter
    @catBoxIter = new VisibleChildIterator(this, @categoriesBox)
    @categoriesBox._vis_iter = @catBoxIter
    @leftPane.set_child @favsBox,
      y_align: St.Align.END
      y_fill: false

    @selectedAppBox.add_actor @selectedAppTitle
    @selectedAppBox.add_actor @selectedAppDescription
    @categoriesScrollBox.add_actor @categoriesBox
    @categoriesScrollBox.set_policy Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC
    @applicationsScrollBox.add_actor @applicationsBox
    @applicationsScrollBox.set_policy Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC
    @categoriesApplicationsBox.actor.add_actor @categoriesScrollBox
    @categoriesApplicationsBox.actor.add_actor @applicationsScrollBox
    @appsBox.add_actor @selectedAppBox
    @appsBox.add_actor @categoriesApplicationsBox.actor
    @searchBox.add_actor @searchEntry
    @leftPaneBox.add_actor @leftPane
    @leftPaneBox.add_actor @separator.actor
    @leftPaneBox.add_actor @appsButton.actor
    @leftPaneBox.add_actor @searchBox
    @mainBox.add_actor @leftPaneBox
    @mainBox.add_actor @rightButtonsBox.actor
    section.actor.add_actor @mainBox
    Mainloop.idle_add Lang.bind(this, ->
      @_clearAllSelections()
      return
    )
    return

  switchPanes: (pane) ->
    if pane is "apps"
      @leftPane.set_child @appsBox
      @appsButton.label.set_text " " + _(@favoritesLabel)
      @rightButtonsBox.actor.hide()
      @_appletStyles "apps"
    else
      @leftPane.set_child @favsBox
      @appsButton.label.set_text " " + _(@allProgramsLabel)
      @rightButtonsBox.actor.show()  if @menu.showQuicklinks
      @_appletStyles "favs"
    @rightButtonsBox.shutdown.label.set_text _(@shutdownLabel)
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

  _clearAllSelections: ->
    actors = @applicationsBox.get_children()
    i = 0

    while i < actors.length
      actor = actors[i]
      actor.style_class = "menu-application-button"
      actor.hide()
      i++
    actors = @categoriesBox.get_children()
    i = 0

    while i < actors.length
      actor = actors[i]
      actor.style_class = "menu-category-button"
      actor.show()
      i++
    return

  _select_category: (dir, categoryButton) ->
    if dir
      @_displayButtons @_listApplications(dir.get_menu_id())
    else
      @_displayButtons @_listApplications(null)
    @closeApplicationsContextMenus null, false
    @_scrollToCategoryButton categoryButton
    return

  closeApplicationsContextMenus: (excludeApp, animate) ->
    for app of @_applicationsButtons
      if app isnt excludeApp and @_applicationsButtons[app].menu.isOpen
        if animate
          @_applicationsButtons[app].toggleMenu()
        else
          @_applicationsButtons[app].closeMenu()
    return

  _onApplicationButtonRealized: (actor) ->
    if actor.get_width() > @_applicationsBoxWidth
      @_applicationsBoxWidth = actor.get_width()
      @applicationsBox.set_width @_applicationsBoxWidth + 20
    return

  _displayButtons: (appCategory, places, recent, apps, autocompletes) ->
    innerapps = @applicationsBox.get_children()
    for i of innerapps
      innerapps[i].hide()
    if appCategory
      if appCategory is "all"
        @_applicationsButtons.forEach (item, index) ->
          item.actor.show()  unless item.actor.visible
          return

      else
        @_applicationsButtons.forEach (item, index) ->
          unless item.category.indexOf(appCategory) is -1
            item.actor.show()  unless item.actor.visible
          else
            item.actor.hide()  if item.actor.visible
          return

    else if apps
      i = 0

      while i < @_applicationsButtons.length
        unless apps.indexOf(@_applicationsButtons[i].name) is -1
          @_applicationsButtons[i].actor.show()  unless @_applicationsButtons[i].actor.visible
        else
          @_applicationsButtons[i].actor.hide()  if @_applicationsButtons[i].actor.visible
        i++
    else
      @_applicationsButtons.forEach (item, index) ->
        item.actor.hide()  if item.actor.visible
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
            @_placesButtons[i].actor.show()  unless @_placesButtons[i].actor.visible
          else
            @_placesButtons[i].actor.hide()  if @_placesButtons[i].actor.visible
          i++
    else
      @_placesButtons.forEach (item, index) ->
        item.actor.hide()  if item.actor.visible
        return

    if recent
      if recent is -1
        @_recentButtons.forEach (item, index) ->
          item.actor.show()  unless item.actor.visible
          return

      else
        i = 0

        while i < @_recentButtons.length
          unless recent.indexOf(@_recentButtons[i].button_name) is -1
            @_recentButtons[i].actor.show()  unless @_recentButtons[i].actor.visible
          else
            @_recentButtons[i].actor.hide()  if @_recentButtons[i].actor.visible
          i++
    else
      @_recentButtons.forEach (item, index) ->
        item.actor.hide()  if item.actor.visible
        return

    if autocompletes
      i = 0

      while i < autocompletes.length
        button = new TransientButton(this, autocompletes[i])
        button.actor.connect "realize", Lang.bind(this, @_onApplicationButtonRealized)
        button.actor.connect "leave-event", Lang.bind(this, @_appLeaveEvent, button)
        @_addEnterEvent button, Lang.bind(this, @_appEnterEvent, button)
        @_transientButtons.push button
        @applicationsBox.add_actor button.actor
        button.actor.realize()
        i++
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
    @searchActive = false
    @_clearAllSelections()
    @_setCategoriesButtonActive true
    global.stage.set_key_focus @searchEntry
    return

  _onSearchTextChanged: (se, prop) ->
    if @menuIsOpening
      @menuIsOpening = false
      false
    else
      searchString = @searchEntry.get_text()
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
      false

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
    @switchPanes "apps"  if @leftPane.get_child() is @favsBox
    pattern = @searchEntryText.get_text().replace(/^\s+/g, "").replace(/\s+$/g, "").toLowerCase()
    return false  if pattern is @_previousSearchPattern
    @_previousSearchPattern = pattern
    @_activeContainer = null
    @_activeActor = null
    @_selectedItemIndex = null
    @_previousTreeItemIndex = null
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
