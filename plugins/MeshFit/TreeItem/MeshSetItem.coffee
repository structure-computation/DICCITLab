
#
# TreeItem pour la calibration. Il a comme enfant un ensemble de points et un modèle associé.
# Il permet d'afficher ou non les points dans un canvas.
#
class MeshSetItem extends TreeItem
    constructor: ( name = "Meshes Set" ) ->
        super()
        
        @_name.set name
    
    accept_child: ( ch ) ->
        ch instanceof MeshItem
    

