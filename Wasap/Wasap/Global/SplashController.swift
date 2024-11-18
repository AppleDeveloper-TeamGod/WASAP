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
            self.splashWindow!.backgroundColor = .blue.withAlphaComponent(0.5)

            let splashView = SplashView(frame: self.splashWindow!.bounds)
            self.splashWindow!.addSubview(splashView)
            self.splashWindow!.isHidden = false
        }
    }

    public func finishSplash() {
        Log.print("Finish Splash")
        UIView.animate(withDuration: 2.0, delay: 1) {
            self.splashWindow?.isHidden = true
        } completion: { _ in
            self.splashWindow?.removeFromSuperview()
        }
    }
}

import Lottie

private class SplashView: BaseView {
    private lazy var lottieAnimation: LottieAnimationView = {
        let animation = LottieAnimationView(name: "OnBoarding2")
        animation.loopMode = .loop
        animation.play()
        return animation
    }()

    func setViewHierarchy() {
        self.addSubViews(lottieAnimation)
    }

    func setConstraints() {
        self.lottieAnimation.snp.makeConstraints {
            $0.width.equalTo(265)
            $0.height.equalTo(self.lottieAnimation.snp.width)
            $0.center.equalToSuperview()
        }
    }
}
