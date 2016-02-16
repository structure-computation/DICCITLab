class TreeAppModule_Transform extends TreeAppModule
    constructor: ->
        super()
        
        @name = 'Transform'

        _ina = ( app ) =>
            app.data.focus.get() != app.selected_canvas_inst()?[ 0 ]?.cm.view_id

        @actions.push
            txt: "Transform a mesh"
            ico: "img/run_compute.png"
            fun: ( evt, app ) =>  
                items = app.data.selected_tree_items
                for path_item in items
                    item = path_item[ path_item.length - 1 ]
                    app.undo_manager.snapshot()
                    
                    item._children[3]._output[0]._mesh.clear()       # clear du mesh de sortie
                    
                    if item._transfok?
                        for mesh_item in item._children[3]._children when mesh_item instanceof MeshItem
                            for el_type in mesh_item._mesh._elements        # prise en compte du type d'élement (T3, Q4,...)
                                if el_type.indices._size[1] > 0
                                    elements_typedarray = el_type.indices
                        
                            new_points = new Lst
                            
                            R = new Mat_3
                            R[0] = item.transformation.rotation.l1.pos.get()
                            R[1] = item.transformation.rotation.l2.pos.get()
                            R[2] = item.transformation.rotation.l3.pos.get()
                            
                            t = new Vec_3 item.transformation.translation.pos.get()
                            c = item.transformation.scale.get()                            
                            
                            for point in mesh_item._mesh.points 
                                p = point.pos.get()
                                transfo = Vec_3.add ( Mat_3.dot ( Mat_3.mus c, R ), p ), t.get()
                                transf_point = new Point transfo
                                new_points.push transf_point
                            
                            item._children[3]._output[0]._mesh.points = new_points
                            
                            if elements_typedarray._size[0] == 3
                                new_triangles = new Element_TriangleList
                                new_triangles.indices = elements_typedarray
                                item._children[3]._output[0]._mesh._elements.push new_triangles  
                            else if elements_typedarray._size[0] == 4
                                new_q4 = new Element_Q4List
                                new_q4.indices = elements_typedarray
                                new_q4.indices_tri = new_q4._get_indices
                                item._children[3]._output[0]._mesh._elements.push new_q4  
                                                        
                            item._children[3]._output[0]._mesh._signal_change()  # forcer le mesh de sortie à se synchroniser avec le hub (il est en cosmetic_attribute par defaut)

                            break   # on s'arrête au premier MeshItem rencontré dans le MeshCut