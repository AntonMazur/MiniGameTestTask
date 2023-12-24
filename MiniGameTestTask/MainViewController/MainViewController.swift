//
//  MainViewController.swift
//  MiniGameTestTask
//
//  Created by Anton Mazur on 22.12.2023.
//

import UIKit

final class MainViewController: UIViewController {
    private var circleView: UIView!
    private var obstacleTop: UIView!
    private var obstacleBottom: UIView!
    private var obstacleTopOriginPosition: CGFloat!
    private var obstacleBottomOriginPosition: CGFloat!
    private var circleSize: CGFloat = 50
    private var collisionCount = 0
    private var displayLink: CADisplayLink?
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startGame()
    }
    
    @IBAction private func increaseCircleSize() {
        circleSize += 10
        circleView.updateCircleFrame(with: CGRect(x: view.center.x - circleSize / 2, y: view.center.y - circleSize / 2, width: circleSize, height: circleSize))
    }
    
    @IBAction private func decreaseCircleSize() {
        guard circleSize > 20 else { return }
        circleSize -= 10
        circleView.updateCircleFrame(with: CGRect(x: view.center.x - circleSize / 2, y: view.center.y - circleSize / 2, width: circleSize, height: circleSize))
    }
    
    private func setupUI() {
        circleView = UIView(frame: CGRect(x: view.center.x - circleSize / 2, y: view.center.y - circleSize / 2, width: circleSize, height: circleSize))
        circleView.layer.cornerRadius = circleSize / 2
        circleView.backgroundColor = UIColor.green
        view.addSubview(circleView)
        
        let obstacleHeight: CGFloat = 20
        obstacleTop = UIView(frame: CGRect(x: view.frame.width, y: view.frame.height / 2 - 100, width: view.frame.width, height: obstacleHeight))
        obstacleBottom = UIView(frame: CGRect(x: view.frame.width, y: view.frame.height / 2 + 100, width: view.frame.width, height: obstacleHeight))
        [obstacleTop, obstacleBottom].forEach { obstacle in
            guard let obstacle else { return }
            obstacle.backgroundColor = .red
            obstacle.layer.cornerRadius = 5
            view.addSubview(obstacle)
        }
        obstacleTopOriginPosition = obstacleTop.frame.origin.x
        obstacleBottomOriginPosition = obstacleBottom.frame.origin.x
    }
    
    private func startGame() {
        displayLink = CADisplayLink(target: self, selector: #selector(checkCollision))
        displayLink?.add(to: .current, forMode: .default)
        
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            guard let self else { return }
            displayLink?.isPaused = false
            animateObstacles()
        }
        
        animateCircle()
    }
    
    private func endGame() {
        timer?.invalidate()
        timer = nil
        
        displayLink?.invalidate()
        displayLink = nil
        
        collisionCount = 0
        circleSize = 50
        circleView.layer.removeAnimation(forKey: "rotationAnimation")
        showRestartAlert()
    }
    
    @objc private func checkCollision() {
        let circleFrame = circleView.frame
        guard let obsctableTopFrame = obstacleTop.layer.presentation()?.frame,
              let obstacleBottomFrame = obstacleBottom.layer.presentation()?.frame,
              circleFrame.intersects(obsctableTopFrame) || circleFrame.intersects(obstacleBottomFrame)
        else { return }
        displayLink?.isPaused = true
        collisionCount += 1
        
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.error)
        
        let collisionLimit = 5
        if collisionCount >= collisionLimit {
            endGame()
        }
    }
    
    private func animateObstacles() {
        UIView.animate(withDuration: 3, animations: {
            self.obstacleTop.frame.origin.x = -self.obstacleTop.frame.width
            self.obstacleBottom.frame.origin.x = -self.obstacleBottom.frame.width
        }) { _ in
            self.obstacleTop.frame.origin.x = self.obstacleTopOriginPosition
            self.obstacleBottom.frame.origin.x = self.obstacleBottomOriginPosition
        }
    }
    
    private func animateCircle() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2)
        rotationAnimation.duration = 2
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = .greatestFiniteMagnitude
        circleView.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    private func showRestartAlert() {
        let alertController = UIAlertController(title: "Game over", message: "Please, restart the game", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self else { return }
            let newFrame = CGRect(x: view.center.x - circleSize / 2, y: view.center.y - circleSize / 2, width: circleSize, height: circleSize)
            circleView.updateCircleFrame(with: newFrame)
            startGame()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Extensions
private extension UIView {
    func updateCircleFrame(with newValue: CGRect) {
        frame = newValue
        layer.cornerRadius = newValue.height / 2
    }
}

