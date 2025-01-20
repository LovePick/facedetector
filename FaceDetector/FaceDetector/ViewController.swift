//
//  ViewController.swift
//  FaceDetector
//
//  Created by Supapon Pucknavin on 20/1/2568 BE.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var faceActionLabel: UILabel!
    
    let sceneView = ARSCNView(frame: UIScreen.main.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(sceneView)
        sceneView.delegate = self
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        self.view.bringSubviewToFront(faceActionLabel)
    }
    
    
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
}

extension ViewController: ARSessionDelegate {
    
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: any SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = sceneView.device else { return nil }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let faceNode = SCNNode(geometry: faceGeometry)
        faceNode.geometry?.firstMaterial?.fillMode = .lines
        faceGeometry?.firstMaterial?.transparency = 0.0
        return faceNode
    }
    
    func renderer(_ renderer: any SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        guard let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
        faceGeometry.update(from: faceAnchor.geometry)
        
        addMaskImageto(node: node)
        
        DispatchQueue.main.async {
            self.faceActionDetected(faceAnchor: faceAnchor)
        }
    }
    
}

extension ViewController {
    
    func faceActionDetected(faceAnchor: ARFaceAnchor) {
        let leftSmileValue = faceAnchor.blendShapes[.mouthSmileLeft] as! CGFloat
        let rightSmileValue = faceAnchor.blendShapes[.mouthSmileRight] as! CGFloat

        handleSmile(leftValue: leftSmileValue, rightValue: rightSmileValue)
    }
    
    func handleSmile(leftValue: CGFloat, rightValue: CGFloat) {
        let smileValue = (leftValue + rightValue)/2.0
        switch smileValue {
        case _ where smileValue > 0.5:
            faceActionLabel.text = "😁"
        case _ where smileValue > 0.2:
            faceActionLabel.text = "🙂"
        default:
            faceActionLabel.text = "😐"
        }
    }
    
    func addMaskImageto(node: SCNNode) {
        if node.childNode(withName: "mask", recursively: false) != nil {
            return
        }
        let image = UIImage(named: "IMG_1184")
        let maskNode = SCNNode(geometry: SCNPlane(width: 0.2, height: 0.3))
        maskNode.geometry?.firstMaterial?.diffuse.contents = image
        maskNode.position.y = 0.05
        
        maskNode.name = "mask"
        
        node.addChildNode(maskNode)
    }
}
