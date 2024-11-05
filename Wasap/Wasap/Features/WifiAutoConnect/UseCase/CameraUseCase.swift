//
//  CameraUseCase.swift
//  Wasap
//
//  Created by chongin on 10/6/24.
//

import Foundation
import UIKit
import RxSwift
import AVFoundation

public protocol CameraUseCase {
    func configureCamera() -> Single<Void>
    func takePhoto(cropRect: CGRect) -> Single<UIImage>
    func getCapturePreviewLayer() -> Single<AVCaptureVideoPreviewLayer>
    func getCapturePreviewLayer() -> AVCaptureVideoPreviewLayer?
    func getPreviewImageDataStream() -> Observable<UIImage>
    func getQRDataStream() -> Observable<(qrString: String, corners: [CGPoint])?>
    func startRunning() -> Single<Void>
    func stopRunning()
    func zoom(_ factor: CGFloat)
}

final class DefaultCameraUseCase: CameraUseCase {
    private let repository: CameraRepository

    init(repository: CameraRepository) {
        self.repository = repository
    }

    func configureCamera() -> Single<Void> {
        Log.debug("Configure camera")
        return repository.configureCamera()
            .map { _ in () }
    }

    func takePhoto(cropRect: CGRect) -> Single<UIImage> {
        return repository.capturePhoto()
            .map { [weak self] in
                guard let image = UIImage(data: $0) else {
                    throw CameraErrors.imageConvertError
                }
                guard let croppedImage = self?.cropToPreviewLayer(originalImage: image) else {
                    throw CameraErrors.imageConvertError
                }
                return croppedImage
            }
    }

    func getCapturePreviewLayer() -> Single<AVCaptureVideoPreviewLayer> {
        return repository.getPreviewLayer()
    }

    func getCapturePreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return repository.getPreviewLayer()
    }

    func getPreviewImageDataStream() -> Observable<UIImage> {
        return repository.getPreviewImageStream()
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
    }

    func getQRDataStream() -> Observable<(qrString: String, corners: [CGPoint])?> {
        return repository.getQRDataStream()
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
    }

    func startRunning() -> Single<Void> {
        Log.debug("Start Running")
        return repository.startRunning()
    }

    func stopRunning() {
        repository.stopRunning()
    }

    func zoom(_ factor: CGFloat) {
        repository.zoom(factor)
    }

    private func cropToPreviewLayer(originalImage: UIImage) -> UIImage? {
        guard let cgImage = originalImage.cgImage else { return nil }

        guard let videoPreviewLayer = self.repository.getPreviewLayer() else {
            return nil
        }

        let outputRect = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: videoPreviewLayer.bounds)

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let previewRect = CGRect(x: outputRect.origin.x * width, y: outputRect.origin.y * height, width: outputRect.size.width * width, height: outputRect.size.height * height)
        let maskRect = modifyRect(originalRect: previewRect)

        Log.print(previewRect, maskRect)


        if let previewImage = cgImage.cropping(to: maskRect) {
            return UIImage(cgImage: previewImage, scale: 1.0, orientation: originalImage.imageOrientation)
        }

        return nil
    }

    private func modifyRect(originalRect: CGRect) -> CGRect {
        let newOriginX = originalRect.origin.x + originalRect.width * Dimension.Mask.topPadding
        let newOriginY = originalRect.origin.y + originalRect.height * Dimension.Mask.leftPadding

        // 좌표공간이 바뀐거 주의
        let newWidth = originalRect.width * Dimension.Mask.height
        let newHeight = originalRect.height * Dimension.Mask.width

        let modifiedRect = CGRect(
            x: newOriginX,
            y: newOriginY,
            width: newWidth,
            height: newHeight
        )

        return modifiedRect
    }
}
