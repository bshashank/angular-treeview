# util functions
searchFunc = (node, searchText) -> # returns true on match, false on miss
  return if node.searchText.search(searchText) == -1 then false else true

makeAllVisible = (node) -> # makes specified node and all its children visible
  node.visible = true
  if node.nodes && node.nodes.length > 0
    makeAllVisible(child) for child in node.nodes

searchTraverse = (node, searchText) ->
  # expands all nodes that match or have children that match and hides all that don't
  node.visible = false
  node.expandedFromSearch = false
  if searchFunc(node, searchText)
    makeAllVisible(node)
    node.expandedFromSearch = true
    return true
  else if node.nodes && node.nodes.length > 0
    found = false
    for child in node.nodes
      if searchTraverse(child, searchText)
        node.visible = true
        node.expandedFromSearch = true
        found = true
    return found

updateVisibility = (rootNode, searchText) -> # update node visiblity based on search text
  if !searchText
    for node in rootNode
      makeAllVisible(node)
      collapseAll(node, true)
  else
    for node in rootNode
      searchTraverse(node, searchText.toLowerCase())

collapseAll = (node, onlySearch=false) -> # collapse node and all children nodes
  if !onlySearch then node.expanded = false
  node.expandedFromSearch = false
  if node.nodes then collapseAll(child) for child in node.nodes

hideElement = (el) -> el.css('display', 'none')
showElement = (el) -> el.css('display', 'block')

updateDom = (node) ->
  if node.visible
    showElement node.dom
    if node.bucket
      if node.expanded || node.expandedFromSearch
        showElement node.bucket
        node.dom.addClass('tree-view-parent-expanded')
      else
        hideElement node.bucket
        node.dom.removeClass('tree-view-parent-expanded')
  else
    hideElement node.dom

  if node.nodes
    for child in node.nodes
      updateDom(child)

clickNode = (node) ->
  if !node.expanded
    node.expanded = true
    showElement node.bucket
  else
    collapseAll(node)
    updateDom(node)


directiveDefinition =
  restrict: "EA"
  scope:
    search: "=searchModel"
    selected: "=ngModel"
    ngOnchange: "&"
    tree: "=?"
  compile: (cElement, cAttrs) ->

    post: (scope, element, attrs) ->

      element.addClass('tree-view')
      # crude clipsize not much use...
      scope.clipSize = if attrs.clipSize then parseInt(attrs.clipSize, 10) else 0


      initializeNode = (node) ->
        node.visible = true
        node.expanded = false
        node.expandedFromSearch = false
        node.searchText = node.text.toLowerCase()

        if (!scope.clipSize || node.text.length < scope.clipSize)
          node.visibleText = node.text
        else
          node.visibleText = "#{ node.text.slice(0, scope.clipSize-3)}..."

        if node.nodes && node.nodes.length > 0
          # parent DOM
          node.icon = angular.element("<span class='tree-view-parent-icon'></span>")
          node.dom = angular.element("<div class='tree-view-parent-node'></div>").append(node.icon)
          node.bucket = angular.element("<div style='display:none;' class='tree-view-children'></div>")
          txt = angular.element("<span class='tree-view-text'>#{node.visibleText}</span>")
          node.dom.append(txt).append(node.bucket)
          node.parent.bucket.append(node.dom)
          txt.bind "click", () -> clickNode(node)
          node.icon.bind "click", () -> clickNode(node)
          for child in node.nodes
            child.parent = node
            initializeNode(child)
        else
          # child DOM
          node.dom = angular.element("<div class='tree-view-leaf-node'>#{node.visibleText}</div>")
          node.parent.bucket.append(node.dom)
          node.dom.bind "click", () ->
            scope.selectedNode = node
            scope.$apply()

      scope.$watch 'selectedNode',  (newVal,oldVal) ->
        if oldVal then oldVal.dom.removeClass('tree-view-leaf-node-selected')
        if newVal
          newVal.dom.addClass('tree-view-leaf-node-selected')
          scope.selected = newVal.value || newVal.text

      initializeTree = (tree) ->
        element.children().remove()
        tree.bucket = element
        for node in tree
          node.parent = tree
          initializeNode(node)

      scope.$watch "search", (search) ->
        if search != undefined
          updateVisibility(scope.tree, search.toLowerCase())
          updateDom(node) for node in scope.tree


      scope.$watch 'tree', (tree) ->
        initializeTree(scope.tree)

angular
  .module("treeView", [])
  .directive("treeView", -> return directiveDefinition)