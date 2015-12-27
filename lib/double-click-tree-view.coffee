'use strict'

class DoubleClickTreeView

  config:
    disableDblClickOnDirectories:
      type: 'boolean'
      default: false,
      title : 'Disable double click on directories'

  disableDblClickOnDirectories: false
  treeView : null

  activate: ->

    # Read configuration
    @disableDblClickOnDirectories =
      atom.config.get 'double-click-tree-view.disableDblClickOnDirectories'

    atom.packages.activatePackage('tree-view').then (treeViewPkg) =>
      @treeView = treeViewPkg.mainModule.createView ->
      @unsubscribeEntryClicked ->
      @subscribeClicks ->
      @subscribeUpdateConfigurations ->

    .catch (error) ->
      console.error error, error.stack

  deactivate: ->
    @unsubscribeClicks ->
    @subscribeEntryClicked ->

  subscribeUpdateConfigurations: ->
    atom.config.observe 'double-click-tree-view.disableDblClickOnDirectories',
      (newValue) =>
        if @disableDblClickOnDirectories isnt newValue
          @disableDblClickOnDirectories = newValue
          @unsubscribeClicks ->
          @subscribeClicks ->

  subscribeClicks: ->
    if @disableDblClickOnDirectories is true
      @subscribeSingleClick ->
    @subscribeDblClick ->

  subscribeSingleClick: ->
    @treeView.on 'click', '.directory.entry', (e) =>
      @draw e

  subscribeDblClick: ->
    @treeView.on 'dblclick', '.entry', (e) =>
      @draw e

  subscribeEntryClicked: ->
    @treeView.entryClicked = @treeView.originalEntryClicked
    @treeView.originalEntryClicked = null

  unsubscribeClicks: ->
    @unsubscribeDblClick ->
    @unsubscribeSingleClick ->

  unsubscribeDblClick: ->
     @treeView.off 'dblclick', '.entry'

  unsubscribeSingleClick: ->
    @treeView.off 'click', '.directory.entry'

  unsubscribeEntryClicked: ->
    @treeView.originalEntryClicked = @treeView.entryClicked
    @treeView.entryClicked = (e) ->
      false

  draw:(e) ->
    @treeView.openSelectedEntry(e.currentTarget)
    false

module.exports = new DoubleClickTreeView()
