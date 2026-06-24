# 📷 Project_6 Camera Filter

<br>

## 📌 1. Project Summary (프로젝트 요약)

Basys3 FPGA 보드와 OV7670 카메라 모듈을 사용하여 FPGA 내부에서 영상 필터를 적용한 뒤, VGA 모니터로 출력하는 프로젝트

<br>

## ✨ 2. Key Features (주요 기능)

- OV7670 카메라 영상 입력 처리
- RGB565 카메라 데이터를 RGB444 형식으로 변환
- BRAM을 이용한 프레임 버퍼 구성
- VGA 640x480 출력
- 화면 중앙에 320x240 카메라 영상 표시
- AXI Register를 이용한 필터 모드 선택
- 실시간 영상 필터 처리
- SCCB 통신을 이용한 OV7670 카메라 초기화

<br>

## 🛠️ 3. Tech Stack (기술 스택)

### 3.1 Language (사용언어)

<p>
  <img src="https://img.shields.io/badge/Verilog-HDL-blue?style=for-the-badge">
</p>

<br>

### 3.2 Development Environment (개발 환경)

<p>
  <img src="https://img.shields.io/badge/Vivado-2024.2-orange?style=for-the-badge">
  <img src="https://img.shields.io/badge/Block%20Design-Vivado-yellow?style=for-the-badge">
</p>


<br>

## 📂 4. Project Structure (프로젝트 구조)

```text
SoC_best_vga_rgb_2/
├── SoC_best_vga_rgb_2.xpr                         # Vivado 프로젝트 파일
├── SoC_best_vga_rgv_ver2_wrapper.xsa              # Hardware Export 파일
│
├── SoC_best_vga_rgb_2.srcs/
│   ├── sources_1/
│   │   ├── bd/
│   │   │   └── SoC_best_vga_rgv_ver2/
│   │   │       └── SoC_best_vga_rgv_ver2.bd        # Block Design 파일
│   │   │
│   │   └── imports/new/
│   │       └── rst_and.v                           # reset 제어 모듈
│   │
│   └── constrs_1/
│       └── imports/fpga/
│           └── Basys-3-Master.xdc                  # Basys3 핀 제약 파일
│
├── SoC_best_vga_rgb_2.gen/
│   └── sources_1/bd/SoC_best_vga_rgv_ver2/
│       └── ipshared/
│           ├── 1485/hdl/
│           │   ├── myip_ov7670_cfg_v2_0.v          # OV7670 설정 Custom IP
│           │   ├── myip_ov7670_cfg_v2_0_S00_AXI.v  # AXI4-Lite Register
│           │   └── sccb_ctrl.v                     # SCCB 통신 제어
│           │
│           ├── 2b4b/hdl/
│           │   └── myip_ov7670_capture_v1_0.v      # OV7670 영상 캡처 IP
│           │
│           ├── a03e/hdl/
│           │   └── myip_vga_controller_v1_0.v      # VGA 출력 컨트롤러 IP
│           │
│           └── d6fb/hdl/
│               ├── myip_filter_v1_0.v              # 영상 필터 Custom IP
│               ├── myip_filter_v1_0_S00_AXI.v      # 필터 선택 AXI Register
│               └── filter_ctrl.v                   # 필터 처리 로직
│
└── SoC_best_vga_rgb_2.runs/
    └── impl_1/
        └── SoC_best_vga_rgv_ver2_wrapper.bit       # FPGA Bitstream 파일
```

<br>

## 🧩 5. System Architecture (시스템 구조)

### 5.1 전체 동작 흐름

```text
OV7670 Camera
      │
      │ PCLK / VSYNC / HREF / DATA[7:0]
      ▼
OV7670 Capture IP
      │
      │ RGB444 Pixel Data
      ▼
BRAM Frame Buffer
      │
      │ Pixel Read
      ▼
Image Filter IP
      │
      │ Filtered RGB Data
      ▼
VGA Controller IP
      │
      │ RGB / HSYNC / VSYNC
      ▼
VGA Monitor
```

<br>

### 5.2 Block Design
.

<img src="./images/Block%20Diagram_Select_Filter.png" width="700">

<br>

## 🎬 7. Demonstration (시연 영상)

<br>

[![Video](./images/youtube.png)](https://www.youtube.com/watch?v=QpY_T1iv3Es)

### *이미지를 클릭하면 시연 영상으로 이동합니다.*


<br>

필터별 결과 이미지를 넣고 싶으면 아래처럼 작성할 수 있습니다.

```md
<img src="./images/original.jpg" width="45%">
<img src="./images/grayscale.jpg" width="45%">
<br>
<img src="./images/invert.jpg" width="45%">
<img src="./images/edge.jpg" width="45%">
```

<br>

##  10. Troubleshooting (문제 해결 기록)

### 10.1 OV7670 초기화 전 영상 출력 문제

**🔍 문제 상황**

- FPGA에 bitstream을 올린 직후 VGA 화면에 정상적인 카메라 영상이 출력되지 않음
- 화면에 노이즈가 보이거나 색상이 깨져 보이는 문제가 발생함


**❓ 원인 분석**

- OV7670 카메라는 내부 레지스터 설정이 완료된 뒤 안정적인 영상 데이터를 출력함
- SCCB 초기화가 끝나기 전에 Capture IP가 동작하면 유효하지 않은 데이터가 BRAM에 저장될 수 있음


**❗ 해결 방법**

- OV7670 Config IP에서 초기화 완료 신호인 `init_done`을 출력하도록 구성
- `rst_and.v`를 통해 reset, clock locked, init_done 조건이 모두 만족된 뒤 Capture IP가 동작하도록 수정


**✅ 결과**

- 카메라 초기화가 완료된 이후부터 영상 캡처가 시작되어 VGA 출력이 안정화됨



### 10.2 VGA 화면 좌측 노이즈 픽셀 문제

**🔍 문제 상황**

- VGA 화면의 왼쪽 가장자리 부분에 깨진 픽셀이나 노이즈가 표시됨


**❓ 원인 분석**

- BRAM은 read 요청 후 데이터가 바로 나오지 않고 약간의 latency가 존재함
- VGA 출력 타이밍과 BRAM read timing이 완전히 맞지 않아 화면 시작 부분에서 픽셀 위치가 어긋남


**❗ 해결 방법**

- VGA 출력 시작 위치를 약간 보정
- BRAM read latency를 고려하여 출력 구간을 조정
- 화면 중앙 배치 좌표와 read address 생성 타이밍을 맞춤


**✅ 결과**

- 좌측 노이즈 픽셀이 줄어들고 카메라 영상이 VGA 화면 중앙에 안정적으로 표시됨


### 10.3 AXI Clock과 Pixel Clock 도메인 차이 문제

**🔍 문제 상황**

- AXI Register에서 필터 값을 변경했을 때 필터 적용이 불안정하게 보일 가능성이 있음


**❓ 원인 분석**

- 필터 선택 값은 AXI Clock 도메인에서 설정됨
- 실제 픽셀 필터 처리는 Pixel Clock 도메인에서 수행됨
- 서로 다른 Clock Domain의 신호를 바로 사용하면 메타스테빌리티 문제가 발생할 수 있음


**❗ 해결 방법**

- `filter_ctrl.v` 내부에서 필터 선택 신호를 Pixel Clock에 동기화
- 2-FF Synchronizer 구조를 적용하여 안정적으로 신호 전달


**✅ 결과**

- 필터 선택 값이 Pixel Clock 도메인에서 안정적으로 반영됨
- 필터 전환 시 영상 출력 안정성이 향상됨


### 10.4 OV7670 PCLK 비동기 타이밍 문제

**🔍 문제 상황**

- 카메라에서 들어오는 `PCLK`와 FPGA 내부 클럭이 서로 다른 클럭으로 동작함
- Vivado Timing Report에서 timing violation이 발생할 수 있음


**❓ 원인 분석**

- OV7670의 `PCLK`는 외부 카메라 모듈에서 들어오는 클럭임
- FPGA 내부 Clock Wizard에서 생성한 클럭과 동기 관계가 아니기 때문에 별도 클럭 도메인으로 취급해야 함


**❗ 해결 방법**

- XDC 파일에서 `PCLK`를 별도의 clock으로 정의
- 내부 클럭과 카메라 PCLK를 asynchronous clock group으로 분리

**✅ 결과**

- 불필요한 timing violation을 줄이고 카메라 입력 클럭과 내부 시스템 클럭을 명확히 분리함

<br>

## 🔧 11. Future Improvements (개선 사항)

- 버튼 또는 스위치를 이용한 필터 모드 변경 기능 추가
- UART 명령을 통한 필터 모드 제어 기능 추가
- Sobel, Sepia, Sharpen 등 추가 필터 구현
- RGB444보다 더 높은 색상 표현을 위한 RGB565 또는 RGB888 확장
- Double Buffering을 적용하여 화면 찢김 현상 개선
- VGA 출력에서 HDMI 출력으로 확장
- 원본 영상과 필터 적용 영상을 동시에 보여주는 분할 화면 모드 추가


