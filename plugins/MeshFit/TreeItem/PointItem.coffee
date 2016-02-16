
#
# TreeItem contenant un point affiché dans le canvas, aux coordonnées définies par le vecteur 3D paramètre 'pos' (liste de 3 valeurs)
#
class PointItem extends TreeItem
    constructor: ( name = "Point", pos ) ->
        super()
        
        @add_attr
            point: new PointMesher pos, 2, 6    # coordonnées, densité, rayon

        @_name.set name   
    
    accept_child: ( ch ) ->
        false
        
   