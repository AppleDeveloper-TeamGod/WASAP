//
//  SplashController.swift
//  Wasap
//
//  Created by chongin on 11/18/24.
//

import UIKit

public final class SplashController {
    public static let shared = SplashController()
    var splashWindow: UIWindow? = nil
    private init() {}

    public func startSplash() {

        DispatchQueue.main.async {
            Log.print("Start Splash")
            guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
                self.splashWindow = UIWindow()
                Log.error("Splash Window Scene not found")
                return
            }

            self.splashWindow = UIWindow(windowScene: windowScene)
            self.splashWindow!.frame = windowScene.coordinateSpace.bounds
            self.splashWindow!.windowLevel = .alert + 1 // 다른 UI 위에 표시
            self.splashWindow!.backgroundColor = .clear

            let splashView = SplashView(frame: self.splashWindow!.bounds)
            splashView.backgroundColor = .gray500
            self.splashWindow!.addSubview(splashView)
            self.splashWindow!.isHidden = false
        }
    }

    public func finishSplash() {
        Log.print("Finish Splash")
        guard self.splashWindow != nil else { return }
        UIView.animate(withDuration: 2.0, delay: 1) {
            self.splashWindow?.alpha = 0.0
        } completion: { _ in
            self.splashWindow?.isHidden = true
            self.splashWindow?.removeFromSuperview()
            self.splashWindow = nil
        }
    }
}

import Lottie

private class SplashView: BaseView {
    private lazy var lottieAnimation: LottieAnimationView = {
        let animation = LottieAnimationView(name: "SplashAnimation")
        animation.loopMode = .playOnce
        animation.play()
        return animation
    }()

    func setViewHierarchy() {
        self.addSubViews(lottieAnimation)
    }

    func setConstraints() {
        self.lottieAnimation.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.height.equalToSuperview().multipliedBy(0.7)
            $0.bottom.equalToSuperview().inset(44)
            $0.centerX.equalToSuperview()
        }
    }
}
