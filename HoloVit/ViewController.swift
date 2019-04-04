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
    var blockToBuilding: [String:[SCNNode]] = [:]
    var tempMap: [String: SCNNode] = [:]
    
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
            placeSJT(withPlaneAnchor: planeAnchor)
            placeSMV(withPlaneAnchor: planeAnchor)
            placeTT(withPlaneAnchor: planeAnchor)
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
        textNode.position = SCNVector3(atPosition.x, atPosition.y+0.15, atPosition.z)
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)
        sceneView.scene.rootNode.addChildNode(textNode)
        blockTextNode.append(textNode)
    }
    
    
    func updateTempText(text: String, atPosition: SCNVector3, building: String){
        //        self.textNode.removeFromParentNode()
        //        let textNode = SCNNode()
        let textGeometry = SCNText(string: text , extrusionDepth: 0.5)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(atPosition.x, atPosition.y+0.15, atPosition.z)
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)
        sceneView.scene.rootNode.addChildNode(textNode)
        tempMap[building] = textNode
    }
    
    
    func placePlane(withPlaneAnchor planeAnchor : ARPlaneAnchor){
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/white_wallpaper.jpg")
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
        
        var position = SCNVector3(planeAnchor.center.x+0.7, planeAnchor.center.y, planeAnchor.center.z-0.7)
        let scale = SCNVector3(0.003,0.003,0.003)
        let allNodeObjects = ["pCube86","pCube85","pCube88","pCube83","pCube75","pCube3",
            "pCube2","pCylinder3","pCylinder16", "pPipe1", "pCube1", "pCube65", "pCylinder6"]
        blockToBuilding["skb"] = []
        for object in allNodeObjects{
            let node = tempScene.rootNode.childNode(withName: object, recursively: true)!
            node.position = position
            node.scale = scale
            blockToBuilding["skb"]?.append(node)
            allNodes.append(node)
        }
        
        for updatedNode in allNodes {
            sceneView.scene.rootNode.addChildNode(updatedNode)
        }
        
        position.y += 0.2
        blockPosition["skb"] = position
        updateText(text: "suu kyi data", atPosition: position)

    }
    
    
    func placeSJT(withPlaneAnchor planeAnchor : ARPlaneAnchor){
        let tempScene = SCNScene(named: "art.scnassets/sjt.dae")!
        var allNodes: [SCNNode] = []
        
        let position = SCNVector3(planeAnchor.center.x-0.5, planeAnchor.center.y+0.1, planeAnchor.center.z-0.5)
        let scale = SCNVector3(0.001, 0.001, 0.001)
        let allNodeObjects = ["right", "windows", "Cylinder", "front_shed", "Cube_1_7", "Cube_3_5", "Cube_1_6", "Cube_2_6", "Cube_4_3", "Cube_3", "Cube_3_6", "Cube_1_7", "Cube_6", "Cube_2_2", "Cube_2_3"]
        blockToBuilding["sjt"] = []
        blockPosition["sjt"] = position
        for object in allNodeObjects{
            let node = tempScene.rootNode.childNode(withName: object, recursively: true)!
            node.position = position
            node.scale = scale
            node.eulerAngles.x = .pi/2
            blockToBuilding["sjt"]?.append(node)
            allNodes.append(node)
        }
        
        for updatedNode in allNodes {
            sceneView.scene.rootNode.addChildNode(updatedNode)
        }
        updateText(text: "sjt data", atPosition: position)
    }
    
    func placeSMV(withPlaneAnchor planeAnchor : ARPlaneAnchor){
        let tempScene = SCNScene(named: "art.scnassets/smv.dae")!
        var allNodes: [SCNNode] = []
        
        let position = SCNVector3(planeAnchor.center.x+0.9, planeAnchor.center.y, planeAnchor.center.z)
        let scale = SCNVector3(0.0003,0.0003,0.0003)
        let allNodeObjects = ["smv","Cube","Cube_1","Cube_2","Cube_3","Cube_4",
                              "Cube_5","Cube_6"]
        blockToBuilding["smv"] = []
        blockPosition["smv"] = position
        for object in allNodeObjects{
            let node = tempScene.rootNode.childNode(withName: object, recursively: true)!
            node.position = position
            node.scale = scale
            blockToBuilding["smv"]?.append(node)
            allNodes.append(node)
        }
        
        for updatedNode in allNodes {
            sceneView.scene.rootNode.addChildNode(updatedNode)
        }
        updateText(text: "smv data", atPosition: position)

    }
    
    func placeTT(withPlaneAnchor planeAnchor : ARPlaneAnchor){
        let tempScene = SCNScene(named: "art.scnassets/tt.dae")!
        var allNodes: [SCNNode] = []
        
        var position = SCNVector3(planeAnchor.center.x-0.2, planeAnchor.center.y, planeAnchor.center.z-1)
        let scale = SCNVector3(0.0001, 0.0001, 0.0001)
        let allNodeObjects = ["Object_1", "Object_2", "Object_3", "Object_4", "Object_5", "Object_6", "Object_7", "Object_8", "Object_9", "Object_10", "Object_11", "Object_12", "Object_13", "Object_14", "Object_15", "Object_16", "Object_17", "Object_18", "Object_19", "Object_20", "Object_21", "Object_22", "Object_23", "Object_24", "Object_25", "Object_26", "Object_27"]
        blockToBuilding["tt"] = []
        for object in allNodeObjects{
            let node = tempScene.rootNode.childNode(withName: object, recursively: true)!
            node.position = position
            node.scale = scale
            node.eulerAngles.x = .pi/2
            node.eulerAngles.y = -.pi/2
            node.eulerAngles.z = -.pi/2
            blockToBuilding["tt"]?.append(node)
            allNodes.append(node)
        }
        
        for updatedNode in allNodes {
            sceneView.scene.rootNode.addChildNode(updatedNode)
        }
        position.y += 0.2
        position.x += 0.3
        blockPosition["tt"] = position
        updateText(text: "tt data", atPosition: position)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        refreshing.startAnimating()
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, options: nil)
            if let tappednode = results.first?.node {
                //do something with tapped object
                print(tappednode)
                for block in blockToBuilding {
                    if block.value.contains(tappednode){
                        print(block.key)
                        var pos = blockPosition[block.key]
                        pos!.y += 0.3
                        
                        if tempMap.keys.contains(block.key) {
                            tempMap[block.key]?.removeFromParentNode()
                        }
                        
                        let url = URL(string: "https://holoshield.herokuapp.com/fetch_tmp/\(block.key)")!
                        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                            guard let data = data else { return }
                            let meta = String(data: data, encoding: .utf8)!
                            self.updateTempText(text: meta, atPosition: pos!, building: block.key)
                        }
                        task.resume()
                        
                    }
                }
            }

        }
        refreshing.stopAnimating()
    }
    
  
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view"s session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    @IBOutlet weak var refreshing: UIActivityIndicatorView!
    
    @IBOutlet weak var refreshButton: UIButton!
    
    @IBAction func refreshValues(_ sender: Any) {
        refreshButton.setTitle("Refreshing... ", for: .normal)
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
        refreshButton.setTitle("Refresh again!", for: .normal)

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
