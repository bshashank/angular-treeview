angular-treeview
================

minimal tree view control with search / filter functionality for AngularJS


See example.html for example usage and performance demo with large tree

Usage:

  <div tree-view tree="tree" ng-model="selectedItem" search-model="search"></div>

Format for the tree:
  tree = [
    {
      'text': 'rootNode1',
      'nodes': [
        {
          'text': 'leafNode1'
        },
        {
          'text': 'leafNode2',
          'value': 'ln2',
          'nodes': []
        }
      ]
    },
    {
      'text': 'rootNode2',
      'nodes': [
        {
          'text': 'rootNode3',
          'nodes': [
            {
              'text': 'leafNode3'
            }
          ]
        }
      ]
    }
  ]


TODO:
 - optimize dom structure
 - accept strings for leaf nodes in tree object
 - multi-select
 - hover model
 - option for internal node select
