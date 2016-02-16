class TreeAppModule_TransformationMatrix extends TreeAppModule
    constructor: ->
        super()
        
        @name = 'TransformationMatrix'

        _ina = ( app ) =>
            app.data.focus.get() != app.selected_canvas_inst()?[ 0 ]?.cm.view_id

        @actions.push
            txt: "Build the transformation matrix between the two meshes"
            ico: "img/compute.png"
            fun: ( evt, app ) =>  
                items = app.data.selected_tree_items
                for path_item in items
                    item = path_item[ path_item.length - 1 ]
                    app.undo_manager.snapshot()
                    
                    # construction de la matrice de transformation
                    
                    # 1. récupération des coordonnées des points dans les points sets
                    P_a = new Lst
                    P_b = new Lst
                    if item._children[0]?._children?.length == item._children[1]?._children?.length and item._children[0]?._children?.length >0 and item._children[1]?._children?.length >0    # points sets non vides et avec le meme nb de points
                        for p in item._children[0]._children
                            P_a.push new Vec_3 p.point.point.pos.get()
                        for p in item._children[1]._children
                            P_b.push new Vec_3 p.point.point.pos.get()
                        
                        # 2. centroides
                        centroid_a = new Vec_3 
                        centroid_b = new Vec_3
                        centroid_a = [0,0,0]
                        centroid_b = [0,0,0]
                        
                        for pa in P_a
                            centroid_a = Vec_3.add centroid_a, pa.get()
                        for pb in P_b
                            centroid_b = Vec_3.add centroid_b, pb.get()
                        centroid_a = Vec_3.dis centroid_a, P_a.length
                        centroid_b = Vec_3.dis centroid_b, P_b.length

                        # 3. matrice de covariance H
                        H = new Mat_3
                        for k in [ 0 .. P_a.length-1 ]
                            H = Mat_3.add H, Vec_3.outprod ( Vec_3.sub P_a[k].get(), centroid_a ), ( Vec_3.sub P_b[k].get(), centroid_b )
                        H = Mat_3.mus (1/P_a.length), H
                        
                        # 4. SVD
                        SVD = numeric.svd H
                        U = SVD[ "U" ]
                        V = SVD[ "V" ]
                        S = SVD[ "S" ]

                        # 5. Matrice rotation
                        R = Mat_3.dot V, Mat_3.tra U
                        
                        # 6. ecart type points a
                        sigma2 = 0
                        for pa in P_a
                            sigma2 += Math.pow ( Vec_3.len ( Vec_3.sub pa.get(), centroid_a ) ), 2
    #                     for pb in P_b
    #                         sigma2 += Math.pow ( Vec_3.len ( Vec_3.sub pb.get(), centroid_b ) ), 2
                        sigma2 = sigma2 / P_a.length                    
    #                     sigma2 = sigma2 / P_b.length
                            
                        # 7. Special reflection case
                        det = numeric.det R
                        if det < 0
                            R[0][2] = R[0][2] * (-1)
                            R[1][2] = R[1][2] * (-1)
                            R[2][2] = R[2][2] * (-1)
                            det = numeric.det R
                            S[2] = S[2] * (-1)
                        
                        # 8. Scaling (scalar)
                        c = (1/sigma2) * Vec_3.sum S 
                        
                        cR = Mat_3.mus c, R
                        
                        # 9. translation
                        t = new Vec_3
                        t = [0,0,0]
                        t = Vec_3.add ( Mat_3.dot ( Mat_3.mus (-1), cR ), centroid_a ), centroid_b
                        
                        
    #                     # test fit
    #                     for point_item in item._children[0]._children
    #                         p = new Vec_3 point_item.point.point.pos.get()
    #                     
    #                         res = Vec_3.add ( Mat_3.dot cR, p ), t
    #                         
    #                         point_item.point.point.pos[0].set res[0]
    #                         point_item.point.point.pos[1].set res[1]
    #                         point_item.point.point.pos[2].set res[2]
                            
                        # assignation des attributs de MeshFitItem
                        item.transformation.rotation.l1.pos[0].set R[0][0]
                        item.transformation.rotation.l1.pos[1].set R[0][1]
                        item.transformation.rotation.l1.pos[2].set R[0][2]
                        item.transformation.rotation.l2.pos[0].set R[1][0]
                        item.transformation.rotation.l2.pos[1].set R[1][1]
                        item.transformation.rotation.l2.pos[2].set R[1][2]
                        item.transformation.rotation.l3.pos[0].set R[2][0]
                        item.transformation.rotation.l3.pos[1].set R[2][1]
                        item.transformation.rotation.l3.pos[2].set R[2][2]
                        
                        item.transformation.translation.pos[0].set t[0]
                        item.transformation.translation.pos[1].set t[1]
                        item.transformation.translation.pos[2].set t[2]
                        
                        item.transformation.scale.set c
                        
                        # valider la transformation
                        item._transfok.set true
                        item.transformation.rotation.l1._signal_change()
                        item.transformation.rotation.l2._signal_change()
                        item.transformation.rotation.l3._signal_change()
                        item.transformation.translation._signal_change()
                        item.transformation.scale._signal_change()