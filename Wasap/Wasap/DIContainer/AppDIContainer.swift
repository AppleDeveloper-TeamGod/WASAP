//
//  AppDIContainer.swift
//  Wasap
//
//  Created by chongin on 9/29/24.
//

import UIKit

final public class AppDIContainer {
    let apiClient: APIClient
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func makeWifiAutoConnectDIContainer() -> WifiAutoConnectDIContainer {
        return WifiAutoConnectDIContainer()
    }
}

final public class WifiAutoConnectDIContainer {

    // MARK: Repository
    public func makeImageAnalysisRepository() -> ImageAnalysisRepository {
        return DefaultImageAnalysisRepository()
    }

    public func makeWiFiConnectRepository() -> WiFiConnectRepository {
        return DefaultWiFiConnectRepository()
    }

    public func makeCameraRepository() -> CameraRepository {
        return DefaultCameraRepository()
    }

    public func makeGoToSettingRepository() -> GoToSettingRepository {
        return DefaultGoToSettingRepository()
    }

    // MARK: UseCase
    public func makeImageAnalysisUseCase(_ repository: ImageAnalysisRepository) -> ImageAnalysisUseCase {
        return DefaultImageAnalysisUseCase(imageAnalysisRepository: repository)
    }

    public func makeWiFiConnectUseCase(_ repository: WiFiConnectRepository) -> WiFiConnectUseCase {
        return DefaultWiFiConnectUseCase(repository: repository)
    }

    public func makeCameraUseCase(_ repository: CameraRepository) -> CameraUseCase {
        return DefaultCameraUseCase(repository: repository)
    }

    public func makeGoToSettingUseCase(_ repository: GoToSettingRepository) -> GoToSettingUseCase {
        return DefaultGoToSettingUseCase(repository: repository)
    }

    // MARK: ViewModel
    public func makeScanViewModel(imageAnalysisUseCase: ImageAnalysisUseCase, coordinatorcontroller: ScanCoordinatorController, image: UIImage) -> ScanViewModel {
        return ScanViewModel(imageAnalysisUseCase: imageAnalysisUseCase, coordinatorController: coordinatorcontroller, previewImage: image)
    }

    public func makeWifiReConnectViewModel(wifiConnectUseCase: WiFiConnectUseCase, coordinatorcontroller: WifiReConnectCoordinatorController, imageData: UIImage, ssid: String, password: String) -> WifiReConnectViewModel {
        return WifiReConnectViewModel(wifiConnectUseCase: wifiConnectUseCase, coordinatorController: coordinatorcontroller, image: imageData, ssid: ssid, password: password)
    }

    public func makeConnectingViewModel(wifiConnectUseCase: WiFiConnectUseCase, coordinatorcontroller: ConnectingCoordinatorController, imageData: UIImage, ssid: String, password: String) -> ConnectingViewModel {
        return ConnectingViewModel(wifiConnectUseCase: wifiConnectUseCase, coordinatorController: coordinatorcontroller,image: imageData, ssid: ssid, password: password)
    }

    public func makeCameraViewModel(cameraUseCase: CameraUseCase, imageAnalysisUseCase: ImageAnalysisUseCase, coordinatorcontroller: CameraCoordinatorController) -> CameraViewModel {
        return CameraViewModel(cameraUseCase: cameraUseCase, imageAnalysisUseCase: imageAnalysisUseCase, coordinatorController: coordinatorcontroller)
    }

    public func makeGoToSettingViewModel(goToSettingUseCase: GoToSettingUseCase, coordinatorcontroller: GoToSettingCoordinatorController,
                                         imageData: UIImage, ssid: String, password: String) -> GoToSettingViewModel {
        return GoToSettingViewModel(goToSettingUseCase: goToSettingUseCase, coordinatorController: coordinatorcontroller,
                                    imageData: imageData, ssid: ssid, password: password)
    }

    // MARK: ViewController
    public func makeScanViewController(_ viewModel: ScanViewModel) -> ScanViewController {
        return ScanViewController(viewModel: viewModel)
    }

    public func makeConnectingViewController(_ viewModel: ConnectingViewModel) -> ConnectingViewController {
        return ConnectingViewController(viewModel: viewModel)
    }

    public func makeWifiReConnectViewController(_ viewModel: WifiReConnectViewModel) -> WifiReConnectViewController {
        return WifiReConnectViewController(viewModel: viewModel)
    }

    public func makeCameraViewController(_ viewModel: CameraViewModel) -> CameraViewController {
        return CameraViewController(viewModel: viewModel)
    }

    public func makeGoToSettingViewController(_ viewModel: GoToSettingViewModel) -> GoToSettingViewController {
        return GoToSettingViewController(viewModel: viewModel)
    }
}
