
#
# TreeItem pour la calibration. Il a comme enfant un ensemble de points et un modèle associé.
# Il permet d'afficher ou non les points dans un canvas.
#
class PointSetItem extends TreeItem
    constructor: ( name = "Point Set" ) ->
        super()
        
        @_name.set name
        @_viewable.set true     # visualisable dans le canvas
    
    accept_child: ( ch ) ->
        ch instanceof PointItem
    
    # affichage de tous les points de l'ensemble
    sub_canvas_items: ->        
        lst = []
        for point_item in @_children when point_item instanceof PointItem
            lst.push point_item.point   
        return lst
