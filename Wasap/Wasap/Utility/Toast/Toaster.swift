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

    public func connect(to connectedViewController: UIViewController) {
        self.connectedViewController = connectedViewController
    }

    public func toast(_ message: String) {
        guard let connectedViewController else {
            Log.error("Error! No connected view")
            return
        }

        let toastView = ToastView(
            frame: CGRect(
                x: 10,
                y: 10,
                width: 200,
                height: 200
            )
        )

        toastView.toastLabel.text = message

        connectedViewController.view.addSubview(toastView)

        toastView.snp.makeConstraints {
            $0.top.equalTo(connectedViewController.view.safeAreaLayoutGuide).offset(24)
            $0.centerX.equalToSuperview()

            $0.height.greaterThanOrEqualToSuperview().multipliedBy(0.06)
        }

        UIView.animate(withDuration: 1.0, delay: 2.0) {
            toastView.alpha = 0.0
        } completion: { _ in
            toastView.removeFromSuperview()
        }
    }
}
