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
    func takePhoto(with captureRect: CGRect?) -> Single<UIImage>
    func getCapturePreviewLayer() -> Single<AVCaptureVideoPreviewLayer>
    func getCapturePreviewLayer() -> AVCaptureVideoPreviewLayer?
    func getPreviewImageDataStream() -> Observable<UIImage>
    func getQRDataStream() -> Observable<(qrString: String, corners: [CGPoint])?>
    func startRunning() -> Single<Void>
    func stopRunning()
    func getMinMaxZoomFactor() -> (min: CGFloat?, max: CGFloat?)
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

    func takePhoto(with captureRect: CGRect?) -> Single<UIImage> {
        return repository.capturePhoto()
            .map { [weak self] in
                guard let image = UIImage(data: $0) else {
                    throw CameraErrors.imageConvertError
                }
                guard let captureRect else {
                    return image
                }
                guard let croppedImage = self?.cropImage(originalImage: image, captureRect: captureRect) else {
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
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
    }

    func getQRDataStream() -> Observable<(qrString: String, corners: [CGPoint])?> {
        return repository.getQRDataStream()
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
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

    func getMinMaxZoomFactor() -> (min: CGFloat?, max: CGFloat?) {
        return (repository.getMinZoomFactor(), repository.getMaxZoomFactor())
    }

    private func cropImage(originalImage: UIImage, captureRect: CGRect) -> UIImage? {
        guard let cgImage = originalImage.cgImage else { return nil }

        guard let videoPreviewLayer = self.repository.getPreviewLayer() else {
            return nil
        }

        let convertedRect = videoPreviewLayer
            .metadataOutputRectConverted(fromLayerRect: captureRect)
            .insetByPercentage(0.1)

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let outputRect = CGRect(x: convertedRect.origin.x * width, y: convertedRect.origin.y * height, width: convertedRect.size.width * width, height: convertedRect.size.height * height)

        let resizedOutputRect = resizeRectToAspectRatio(outputRect, aspectRatio: 345 / 224)

        if let previewImage = cgImage.cropping(to: resizedOutputRect) {
            return UIImage(cgImage: previewImage, scale: 1.0, orientation: originalImage.imageOrientation)
        }

        return nil
    }

    private func resizeRectToAspectRatio(_ rect: CGRect, aspectRatio: CGFloat) -> CGRect {
        let originalWidth = rect.width
        let originalHeight = rect.height
        let originalAspectRatio = originalWidth / originalHeight

        var newWidth: CGFloat
        var newHeight: CGFloat

        // 새로운 CGRect가 원본 CGRect를 완전히 포함하도록 만듭니다.
        if originalAspectRatio > aspectRatio {
            // 원본의 가로가 더 넓으면 높이를 늘려야 함
            newWidth = originalWidth
            newHeight = originalWidth / aspectRatio
        } else {
            // 원본의 세로가 더 넓으면 가로를 늘려야 함
            newWidth = originalHeight * aspectRatio
            newHeight = originalHeight
        }

        let newX = rect.origin.x - (newWidth - originalWidth) / 2
        let newY = rect.origin.y - (newHeight - originalHeight) / 2

        return CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
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
