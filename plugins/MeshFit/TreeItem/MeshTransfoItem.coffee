
class MeshTransfoItem extends TreeItem
    constructor: ( name = "Mesh Transformation" ) ->
        super()
               
        @add_output new MeshItem
        
        @_name.set name
     
        
    accept_child: ( ch ) ->
        ch instanceof MeshItem
    

