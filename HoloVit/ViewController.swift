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
    
    var detectedOnce = false
    
    var blockPosition: [String: SCNVector3] = [:]
    var dataStorage: [String:String] = [:]
    var blockTextNode: [SCNNode] = []
    
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

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
     
        if !detectedOnce {
            guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
            placePlane(withPlaneAnchor: planeAnchor)
            placeSuuKyi(withPlaneAnchor: planeAnchor)
            updateText(text: "@220 Amp", atPosition: SCNVector3(x: planeAnchor.center.x, y: planeAnchor.center.y, z: planeAnchor.center.z))
            blockPosition["mb"] = SCNVector3(x: planeAnchor.center.x, y: planeAnchor.center.y, z: planeAnchor.center.z)
            sceneView.scene.rootNode.position = SCNVector3(x: planeAnchor.center.x, y: planeAnchor.center.y, z: planeAnchor.center.z)
            detectedOnce = true
        }
    }
    
    func updateText(text: String, atPosition: SCNVector3){
//        self.textNode.removeFromParentNode()
//        let textNode = SCNNode()
        let textGeometry = SCNText(string: text , extrusionDepth: 0.5)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(atPosition.x, atPosition.y+0.4, atPosition.z)
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)
        sceneView.scene.rootNode.addChildNode(textNode)
        blockTextNode.append(textNode)

    }
    
    func placePlane(withPlaneAnchor planeAnchor : ARPlaneAnchor){
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/base.jpg")
        let plane = SCNPlane(width: CGFloat(5), height: CGFloat(5))
        plane.materials = [gridMaterial]
        
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x : planeAnchor.center.x, y: planeAnchor.center.y-10, z: planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        planeNode.geometry = plane
        sceneView.scene.rootNode.addChildNode(planeNode)
    }
    
    func placeSuuKyi(withPlaneAnchor planeAnchor : ARPlaneAnchor){
        let tempScene = SCNScene(named: "art.scnassets/suu_kyi.dae")!
        var allNodes: [SCNNode] = []
        
        let position = SCNVector3(planeAnchor.center.x+0.7, planeAnchor.center.y, planeAnchor.center.z-0.7)
        let scale = SCNVector3(0.003,0.003,0.003)
        let allNodeObjects = ["pCube86","pCube85","pCube88","pCube83","pCube75","pCube3",
            "pCube2","pCylinder3","pCylinder16", "pPipe1", "pCube1", "pCube65", "pCylinder6"]
        
        blockPosition["skb"] = position
        for object in allNodeObjects{
            let node = tempScene.rootNode.childNode(withName: object, recursively: true)!
            node.position = position
            node.scale = scale
            allNodes.append(node)
        }
        
        for updatedNode in allNodes {
            sceneView.scene.rootNode.addChildNode(updatedNode)
        }
        updateText(text: "suu kyi data", atPosition: position)

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
    
    @IBOutlet weak var refreshing: UIActivityIndicatorView!
    
    @IBAction func refreshValues(_ sender: Any) {
        refreshing.startAnimating()
        let url = URL(string: "https://holoshield.herokuapp.com/get_data")!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let meta = String(data: data, encoding: .utf8)!
            var myStringArr = meta.components(separatedBy: "!#!")
            myStringArr.removeLast()
            for str in myStringArr{
                var electricalData = str.components(separatedBy: "$")
                self.dataStorage["\(electricalData[0])"] = "\(electricalData[1]) V, \(electricalData[2]) Amps"
            }

        }
        task.resume()
        for block in blockTextNode{
            block.removeFromParentNode()
        }
        for block in blockPosition{
            updateText(text: dataStorage[block.key] ?? "Data not available", atPosition: block.value)
        }
        refreshing.stopAnimating()
    }
    
    
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
