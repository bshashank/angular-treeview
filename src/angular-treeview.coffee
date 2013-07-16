directiveName = "treeView"

template = """
<script type="text/ng-template"  id="recursive_tree_renderer.html">
  <div ng-switch="node.nodes.length > 0" ng-init="node.expanded = false" class="tree-view-node" ng-show="node.visible">

    <div ng-switch-when="true" class="tree-view-parent-node">
      <div ng-click="clickParent(node)" class="tree-view-parent-node-text">
      <span ng-class="{'tree-view-parent-icon-expanded': node.expanded, 'tree-view-parent-icon': !node.expanded}">
      </span>{{node.text}}</div>
      <ul ng-show="node.expanded || node.expandedFromSearch">
        <li ng-repeat="node in node.nodes  | filter:searchFilter" ng-include="'recursive_tree_renderer.html'"></li>
      </ul>
    </div>

    <div ng-switch-when="false" class="tree-view-leaf-node">
      <div ng-click="select(node)" class="tree-view-leaf-node-text" ng-class="{'tree-view-leaf-node-selected': isSelected(node)}">{{node.visibleText}}</div>
    </div>

  </div>
</script>

<div class="tree-view">
  <ul>
    <li ng-repeat="node in rootNode" ng-include="'recursive_tree_renderer.html'"></li>
  </ul>
</div>
"""

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

directiveDefinition =
  restrict: "A"
  scope:
    search: "=searchModel"
    selected: "=ngModel"
    ngOnchange: "&"
    tree: "=?"
  compile: (cElement, cAttrs) ->

    post: (scope, element, attrs) ->

      # crude clipsize not much use...
      scope.clipSize = if attrs.clipSize then parseInt(attrs.clipSize, 10) else 0

      initializeNode = (node) ->
        node.visible = true
        node.searchText = node.text.toLowerCase()
        if (!scope.clipSize || node.text.length < scope.clipSize)
          node.visibleText = node.text
        else
          node.visibleText = "#{ node.text.slice(0, scope.clipSize-3)}..."

        if node.nodes && node.nodes.length > 0
          initializeNode(child) for child in node.nodes

      initializeTree = (tree) ->
        for node in tree
          initializeNode(node)
        scope.rootNode = tree

      scope.rootNode = []

      scope.clickParent = (node) ->
        if node.expanded
          collapseAll(node)
        else
          node.expanded = true

      scope.$watch "search", -> updateVisibility(scope.tree, scope.search)

      scope.select = (node) ->
        scope.selected = node.value || node.text
        scope.ngOnchange({value: scope.selected})
      scope.isSelected = (node) -> return scope.selected == (node.value || node.text)

      scope.$watch 'tree', (tree) ->
        initializeTree(scope.tree)
        updateVisibility(scope.tree, scope.search)

  template: template

angular
  .module(directiveName, [])
  .directive(directiveName, -> return directiveDefinition)