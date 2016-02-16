# Item permettant de réaliser la transformation d'un maillage (rotation, translation, ...)



class MeshFitItem extends TreeItem
    constructor: ( name = "Mesh Fit" ) ->
        super()
        
        @add_child new PointSetItem "Points Set 1"         # ensemble 1
        @add_child new PointSetItem "Points Set 2"         # ensemble 2
        @add_child new MeshSetItem 
        @add_child new MeshTransfoItem 
                
        @_name.set name
        
        @add_attr
            _transfok: false
            transformation:
                rotation:
                    l1: new Point
                    l2: new Point
                    l3: new Point
                translation: new Point
                scale: new Val
        
        # refresh des noms et associations des points (au cas où on supprime manuellement un point)
        @bind =>
            if @_children[0]?._children?.has_been_modified() and @_children[0]?._children.length > 0
                for i in [0 .. @_children[ 0 ]._children.length-1]
                    @_children[ 0 ]._children[ i ]._name.set ("Point " + i)
                    
            else if @_children[1]?._children?.has_been_modified() and @_children[1]?._children.length > 0
                for i in [0 .. @_children[ 1 ]._children.length-1]
                    @_children[ 1 ]._children[ i ]._name.set ("Point " + i)
      

    # ajout d'un bouton permettant de réinitialiser la calibration   
    display_suppl_context_actions: ( context_action )  ->
        context_action.push new TreeAppModule_TransformationMatrix
        context_action.push new TreeAppModule_Transform
        context_action.push new TreeAppModule_PointReset
        
        
    accept_child: ( ch ) ->
        false
    
    # pour récupérer le modèle global (TreeAppData)
    is_app_data: ( item ) ->
        if item instanceof TreeAppData
            return true
        else
            return false
        
    # pour récupérer le modèle global (TreeAppData)
    get_app_data: ->
        it = @get_parents_that_check @is_app_data
        return it[ 0 ] 
    
    
    # ajout (clic droit) ou sélection (clic gauche) d'un point lors d'un clic souris
    on_mouse_down: ( cm, evt, pos, b ) ->
        app_data = @get_app_data()

        cm.undo_manager?.snapshot()
        if b == "LEFT" 
            test_select = @_select_point_by_clic cm, evt, pos, b          # point sous la souris ??
            if not test_select
                @_create_point_on_mesh_node cm, evt, pos, b     # création d'un point associé au maillage



    # affichage des points sélectionnés dans le canvas lorsque l'on les sélectionne dans la Scene 
    draw: (info) ->
        app_data = @get_app_data()
        sel_items = app_data.selected_tree_items[0]
        # on appelle la fonction quand on sélectionne un objet de l'arbre 
        if sel_items?.has_been_directly_modified() and sel_items.length >= 4     # TODO: 2e condition à revoir  
            # dé-sélection de tous les points
            for point_set in @_children when point_set instanceof PointSetItem
                for point_item in point_set._children when point_item instanceof PointItem
                    point_item.point._selected.clear()
            
            # si on a bien sélectionné un PointItem, on sélectionne les deux points correspondants (ayant le même nom) dans les deux ensembles 
            if sel_items[ sel_items.length - 1 ] instanceof PointItem
                point_item = sel_items[ sel_items.length - 1 ]
                name = point_item._name.get()
                for point_set in @_children when point_set instanceof PointSetItem
                    for point_item in point_set._children when point_item instanceof PointItem 
                        if point_item._name.get() == name
                            point_item.point._selected.push point_item.point.point                
                
                
    # fonction pour savoir si on est près d'un point d'un maillage par projection (si non: best= -1, si oui: best = indice du point du maillage)
    _closest_point_closer_than: ( proj, pos, dist ) ->
        best = -1
        for p, n in proj
            d = Math.sqrt Math.pow( pos[ 0 ] - p[ 0 ], 2 ) + Math.pow( pos[ 1 ] - p[ 1 ], 2 )
            if dist > d
                dist = d
                best = n
        return best      
    
    
    # ajout d'un point sur un noeud d'un maillage (MeshItem)
    _create_point_on_mesh_node: ( cm, evt, pos, b ) ->
        num_mesh = 0
        for mesh_item in @_children[2]._children
        
            proj = for p in mesh_item._mesh.points
                cm.cam_info.re_2_sc.proj p.pos.get()    # récupération des coordonées de tous les points du maillage

            best = @_closest_point_closer_than proj, pos, 10    # projection du lieu du clic sur ces coordonées
            
            # si on est sufisamment proche d'un point du maillage (à 10 (unités??) près)
            if best >= 0        
                # on récupère les coordonées du point correspondant (indice 'best')
                point = mesh_item._mesh.points[ best ]  
                point_val = [ point.pos[0].get(), point.pos[1].get(), point.pos[2].get() ]
            
                
                # on crée un nouveau PointItem aux coordonées du point du maillage et on l'ajoute à l'ensemble 1
                point_item = new PointItem ("Point " + @_children[ num_mesh ]._children.length), point_val
                @_children[ num_mesh ].add_child point_item   
                
                # selection du point crée seulement
                for pi in @_children[ num_mesh ]._children
                    pi.point._selected.clear()
                point_item.point._selected.push point_item.point.point
                
                break
            
            num_mesh += 1
            
    
    # sélection du point sous la souris et de celui correspondant dans l'autre ensemble de points
    _select_point_by_clic: ( cm, evt, pos, b ) ->
        # on parcourt tous les PointItem des deux ensembles
        for point_set in @_children when point_set instanceof PointSetItem
            for point_item in point_set._children when point_item instanceof PointItem 
            
                # si le point est proche du lieu du clic (fonction on_mouse_down de PointMesher)
                if point_item.point.on_mouse_down cm, evt, pos, b       
                    name = point_item._name.get()       # nom du point proche
                    
                    # on re-parcourt tous les PointItem des deux ensembles
                    for point_set in @_children when point_set instanceof PointSetItem
                        for point_item in point_set._children when point_item instanceof PointItem 
                        
                            # si le point a le même nom que celui du point proche, on le sélectionne
                            if point_item._name.get() == name
                                point_item.point._selected.push point_item.point.point
                            else
                                point_item.point._selected.clear()    
                    return name
                    break
