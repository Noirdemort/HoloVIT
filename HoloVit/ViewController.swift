//
//  ViewController.swift
//  HoloVit
//
//  Created by Noirdemort on 14/03/19.
//  Copyright © 2019 Noirdemort. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.automaticallyUpdatesLighting = true
        let scene = SCNScene(named: "art.scnassets/mb.dae")!
        
        // Set the scene to the view
        sceneView.scene = scene
        placeSuuKyi()
        placeSJT()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.planeDetection = .horizontal
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func placeSuuKyi(){
        let tempScene = SCNScene(named: "art.scnassets/suu_kyi.dae")!
        var allNodes: [SCNNode] = []
        
        let position = SCNVector3(0.7, 0, -0.7)
        let scale = SCNVector3(0.003,0.003,0.003)
        let allNodeObjects = ["pCube86","pCube85","pCube88","pCube83","pCube75","pCube3",
            "pCube2","pCylinder3","pCylinder16", "pPipe1", "pCube1", "pCube65", "pCylinder6"]
        
        for object in allNodeObjects{
            let node = tempScene.rootNode.childNode(withName: object, recursively: true)!
            node.position = position
            node.scale = scale
            allNodes.append(node)
        }
        
        for updatedNode in allNodes {
            sceneView.scene.rootNode.addChildNode(updatedNode)
        }
    }
    
    func placeSJT(){
        print("Place SJT")
    }
  
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    
    
  
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        sceneView.session.run(session.configuration!,
                              options: [.resetTracking,
                                        .removeExistingAnchors])
        viewWillAppear(true)
    }
}
