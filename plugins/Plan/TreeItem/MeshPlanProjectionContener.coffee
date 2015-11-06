#
class MeshPlanProjectionContener extends TreeItem
    constructor: ( name = "MeshPlanProjectionContener" ) ->
        super()
        
        @_name.set name
        @_viewable.set false
        
    accept_child: ( ch ) ->
      true