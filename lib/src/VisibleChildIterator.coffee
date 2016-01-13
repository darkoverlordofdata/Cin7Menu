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
class VisibleChildIterator
  constructor: (parent, container) ->
    @container = container
    @_parent = parent
    @_num_children = 0
    @reloadVisible()
    return

  reloadVisible: ->
    @visible_children = new Array()
    @abs_index = new Array()
    children = @container.get_children()
    i = 0

    while i < children.length
      child = children[i]
      if child.visible
        @visible_children.push child
        @abs_index.push i
      i++
    @_num_children = @visible_children.length
    return

  getNextVisible: (cur_child) ->
    if @visible_children.indexOf(cur_child) is @_num_children - 1
      cur_child
    else
      @visible_children[@visible_children.indexOf(cur_child) + 1]

  getPrevVisible: (cur_child) ->
    if @visible_children.indexOf(cur_child) is 0
      cur_child
    else
      @visible_children[@visible_children.indexOf(cur_child) - 1]

  getFirstVisible: ->
    @visible_children[0]

  getLastVisible: ->
    @visible_children[@_num_children - 1]

  getNumVisibleChildren: ->
    @_num_children

  getAbsoluteIndexOfChild: (child) ->
    @abs_index[@visible_children.indexOf(child)]
