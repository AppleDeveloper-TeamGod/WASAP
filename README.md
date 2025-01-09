# 🫧 찍기만 하면 바로 연결, WASAP!
> Wi-Fi 안내문 사진 촬영만으로, 타이핑 없이 누구나 쉽고 간편하게 네트워크에 연결할 수 있는 앱

|앱 & 팀 이름|WASAP 와쌉 & team GOD 팀갓|
|:--:|:--|
|로고|<img width="70" alt="" src="https://github.com/user-attachments/assets/82dccfda-062a-4ecd-9198-f6e3b7860f72"> <img width="70" alt="" src="https://github.com/user-attachments/assets/cc717347-2cc4-4eba-82a6-bfec7e31c0aa">|
|기간|2024. 09. 02 ~ 2024. 12. 05|
|상태|앱스토어 배포 완료 및 업데이트 진행 중(v1.2.3)|
|참여 인원|6명(PM 1명 + iOS 개발 3명 + 디자인 2명)|
|기술 스택|UIKit, RxSwift, AVFoundation, Vision, RegexBuilder, Testing, MultipeerConnectivity|
|아키텍처|MVVM+C|
|앱스토어|[WASAP - 찍기만 하면 바로 연결!](https://apps.apple.com/kr/app/wasap-%EC%B0%8D%EA%B8%B0%EB%A7%8C-%ED%95%98%EB%A9%B4-%EB%B0%94%EB%A1%9C-%EC%97%B0%EA%B2%B0/id6736962310)|

<br/>


### 📱 앱 미리보기
https://github.com/user-attachments/assets/88812406-d627-436e-994a-39dd8c95d547

<br/>

### 📁 폴더 구조
```
WASAP
├── DIContainer - 모든 것을 알고 있는 전지전능한 의존성 주입기
├── Features
│   └── {피쳐 이름} - 큰 단위의 피쳐를 정의합니다.
│       (각 피쳐마다)
│       ├── View - 뷰들을 정의합니다.
│       ├── ViewModel - 뷰모델을 정의합니다.
│       ├── ViewController - 뷰 컴트롤러를 정의합니다.
│       ├── UseCase - 유스케이스들을 정의합니다.
│       ├── Repository - 레포지토리들을 정의합니다.
│       └── Coordinator - 화면 단위인 코디네이터를 정의합니다.
│
├── Global - 프로젝트 전반적으로 필요한 기본 파일들이 들어갑니다.
│   └── Base - MVVM+C 패턴에 활용되는 요소의 기본 구현체가 들어갑니다.
├── Log - 로그를 찍는 피쳐. 추후 Core 모듈로 이동할 가능성 높습니다.
├── Network - 네트워크 관련 로직들이 들어갑니다.
├── Utility - extension 등 전반적으로 사용되는 부가 기능들을 정의합니다.
└── Entity - DTO, VO, enum 등 모델을 정의합니다.

WasapTests - 테스트를 관리합니다.
└── Features - 피쳐마다 테스트를 관리합니다.
    └── {피쳐 이름}
```


<br/>

### 📦 WifiAutoConnet 피쳐 내 유즈케이스 설명
- Camera - 실시간 카메라 스트림, 줌, 촬영, 이미지 사이즈 크롭을 담당합니다.
- ImageAnalysis - OCR, 바운딩박스 좌표 관리, SSID/PW 추출을 담당합니다. 
- WifiConnect - 와이파이 연결 시도 및 결과 처리를 담당합니다.
- GoToSetting - 와이파이 재연결 모두 실패 시 설정앱으로 인도합니다. 
- WifiShare - 동행자 와이파이 정보 공유를 담당합니다.

<br/>

### 🌿 가치
<img width="200" alt="" src="https://github.com/user-attachments/assets/73011d08-4655-4e16-97c6-839978c92845"> <img width="200" alt="" src="https://github.com/user-attachments/assets/2a1e8987-5940-459f-a0df-152b685f5275"> <img width="200" alt="" src="https://github.com/user-attachments/assets/9077548f-255c-4b72-88c4-e31087c3451d"> <img width="200" alt="" src="https://github.com/user-attachments/assets/1efc6f4a-396b-4fae-b10b-fde091295ce1">

<br/>
