//
//  Toaster.swift
//  Wasap
//
//  Created by chongin on 11/9/24.
//

import UIKit
import SnapKit

public final class Toaster {
    public static let shared = Toaster()
    private init() {}

    private weak var connectedViewController: UIViewController?

    private var toastQueue = DispatchQueue(label: "ToastQueue", qos: .background)
    private var importantToastQueue = DispatchQueue(label: "ImportantToastQueue", qos: .userInitiated)
    private var toastSemaphore = DispatchSemaphore(value: 1)

    public func connect(to connectedViewController: UIViewController) {
        self.connectedViewController = connectedViewController
    }

    public func importantToast(_ message: String, duration: TimeInterval = 1.0, delay: TimeInterval = 2.0) {
        guard let connectedViewController else {
            Log.error("Error! No connected view")
            return
        }

        importantToastQueue.async {
            self.toastSemaphore.wait()
            let toastTaskItem = DispatchWorkItem {
                let toastView = ToastView()

                toastView.toastLabel.text = message

                toastView.toastLabel.textColor = .orange

                connectedViewController.view.addSubview(toastView)

                toastView.snp.makeConstraints {
                    $0.top.equalTo(connectedViewController.view.safeAreaLayoutGuide).offset(24)
                    $0.centerX.equalToSuperview()

                    $0.height.greaterThanOrEqualToSuperview().multipliedBy(0.05)
                }

                UIView.animate(withDuration: duration, delay: delay) {
                    toastView.alpha = 0.0
                } completion: { _ in
                    toastView.removeFromSuperview()
                    self.toastSemaphore.signal()
                }
            }
            DispatchQueue.main.async(execute: toastTaskItem)
        }
    }

    public func toast(_ message: String, duration: TimeInterval = 1.0, delay: TimeInterval = 2.0, top: Int = 24) {
        guard let connectedViewController else {
            Log.error("Error! No connected view")
            return
        }

        toastQueue.async {
            switch self.toastSemaphore.wait(timeout: .now() + 10) { // 10초 넘게 기다리면 실행하지 않고 폐기.
            case .success:
                break
            case .timedOut:
                return
            }
            let toastTaskItem = DispatchWorkItem {
                let toastView = ToastView()

                toastView.toastLabel.text = message

                connectedViewController.view.addSubview(toastView)

                toastView.snp.makeConstraints {
                    $0.top.equalTo(connectedViewController.view.safeAreaLayoutGuide).offset(top)
                    $0.centerX.equalToSuperview()

                    $0.height.greaterThanOrEqualToSuperview().multipliedBy(0.05)
                }

                UIView.animate(withDuration: duration, delay: delay) {
                    toastView.alpha = 0.0
                } completion: { _ in
                    toastView.removeFromSuperview()
                    self.toastSemaphore.signal()
                }
            }
            DispatchQueue.main.async(execute: toastTaskItem)
        }
    }
}
