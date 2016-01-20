#
class ProjectionContener extends TreeItem
    constructor: ( name = "ProjectionContener" ) ->
        super()
        
        @_name.set name
        @_viewable.set false
        
    accept_child: ( ch ) ->
      true