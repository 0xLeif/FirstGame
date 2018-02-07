//
//  GameViewController.swift
//  FirstGame
//
//  Created by Zach Eriksen on 1/23/18.
//  Copyright © 2018 oneleif. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
	var randomColor: UIColor {
		let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
		let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
		let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
		
		return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
	}
	var gameView: SCNView!
	var gameScene: SCNScene!
	var cameraNode: SCNNode!
	var spawnerNode: SCNNode!
	var creationDelay: TimeInterval = 0

    override func viewDidLoad() {
        super.viewDidLoad()
		func createGameView() {
			gameView = view as! SCNView
			gameView.delegate = self
			gameView.allowsCameraControl = true
			gameView.autoenablesDefaultLighting = true
		}
		func createGameScene() {
			gameScene = SCNScene()
			gameView.scene = gameScene
			gameView.isPlaying = true
		}
		func createGameCamera() {
			cameraNode = SCNNode()
			cameraNode.camera = SCNCamera()
			cameraNode.position = SCNVector3(x: 0, y: 5, z: 50)
			gameScene.rootNode.addChildNode(cameraNode)
		}
		func createSpawnerNode() {
			let geometry: SCNGeometry = SCNPyramid(width: 1, height: 1, length: 1)
			geometry.firstMaterial?.diffuse.contents = randomColor
			spawnerNode = SCNNode(geometry: geometry)
			gameScene.rootNode.addChildNode(spawnerNode)
		}
        createGameView()
		createGameScene()
		createGameCamera()
		createSpawnerNode()
    }
	
	fileprivate func createTarget() {
		// Store random color
		let materalColor = randomColor
		// Create Geometry
		let geometry: SCNGeometry = SCNTorus(ringRadius: CGFloat(arc4random_uniform(100)) / 100, pipeRadius: CGFloat(arc4random_uniform(100)) / 100)
		geometry.firstMaterial?.diffuse.contents = materalColor
		// Create Node
		let geometryNode = SCNNode(geometry: geometry)
		geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
		// Add node to scene
		gameScene.rootNode.addChildNode(geometryNode)
		// Create random Vector3 force
		let randomDirection: Float = arc4random_uniform(2) == 0 ? -1.0 : 1.0
		let force = SCNVector3Make(randomDirection, CFloat(arc4random_uniform(20) + 10), 0)
		// Apply Vector3 force to node
		geometryNode.physicsBody?.applyForce(force, at: SCNVector3(), asImpulse: true)
		// Update spawner node's color
		spawnerNode.geometry?.firstMaterial?.diffuse.contents = materalColor
	}
	
	fileprivate func removeChildOffscreen() {
		_ = gameScene.rootNode.childNodes.filter{ $0.presentation.position.y < -30 }.map{ $0.removeFromParentNode() }
	}
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}

extension GameViewController: SCNSceneRendererDelegate {
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first!
		
		let location = touch.location(in: gameView)
		
		let hitTest = gameView.hitTest(location, options: nil)
		
		if let hitObject = hitTest.first {
			let node = hitObject.node
			
			node.removeFromParentNode()
			guard let color = node.geometry?.firstMaterial?.diffuse.contents as? UIColor else {
				return
			}
			gameView.backgroundColor = color
		}
	}
	
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		if time > creationDelay {
			createTarget()
			creationDelay = time + 0.5
		}
		removeChildOffscreen()
	}
}
