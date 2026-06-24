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

## 🎬 6. Demonstration (시연 영상)

<br>

<a href="https://www.youtube.com/watch?v=QpY_T1iv3Es">
  <img src="./images/youtube.png" width="500">
</a>

### *이미지를 클릭하면 시연 영상으로 이동합니다.*


<br><br>


## 🎯 7. Troubleshooting (문제 해결 기록)

### 7.1 BRAM 사용량 증가로 인한 동작 불가 문제

**🔍 문제 상황**
* 초기 설계에서는 안정적인 영상 출력을 위해 프레임 버퍼를 `Double Buffer` 구조로 구성하였다.
* 또한 MicroBlaze-V의 Local Memory를 `128KB`로 설정하였다.
* 하지만 두 설정 모두 BRAM 사용량을 크게 증가시켜 FPGA 내부 자원이 부족해졌고, 정상적인 구현 및 동작이 어려웠다.

**❓ 원인 분석**
* `Double Buffer`는 화면 출력용 버퍼와 카메라 입력용 버퍼를 분리하여 안정적인 영상 처리가 가능하지만, 동일한 크기의 프레임 버퍼가 2개 필요하다.
* OV7670 영상 데이터를 저장하기 위한 BRAM 사용량이 증가한 상태에서 MicroBlaze-V Local Memory까지 `128KB`로 설정되어 BRAM 자원을 과도하게 사용하였다.
* Basys3 FPGA의 제한된 BRAM 용량 안에서 영상 프레임 버퍼와 프로세서 메모리를 동시에 크게 할당한 것이 원인이었다.

**❗ 해결 방법**

* 프레임 버퍼 구조를 `Double Buffer`에서 `Single Buffer`로 변경하였다.
* MicroBlaze-V의 Local Memory 크기를 `128KB`에서 `32KB`로 축소하였다.
* 영상 저장에 필요한 BRAM 사용량과 프로세서 메모리 사용량을 줄여 전체 자원 사용량을 낮추었다.

**✅ 결과**

* BRAM 사용량이 감소하여 FPGA 내부 자원 부족 문제가 완화되었다.
* Single Buffer 구조에서도 카메라 입력과 VGA 출력이 정상적으로 동작하였다.
* MicroBlaze-V Local Memory를 축소해도 카메라 설정 및 필터 제어에는 문제가 없었다.

<br>


### 7.2 160×120 해상도 전환 실패 문제

**🔍 문제 상황**

* 카메라 출력 해상도를 `160×120`으로 낮추려고 했지만 영상이 정상적으로 축소되지 않았다.
* 화면 일부가 잘려서 출력되거나, 색상이 다시 무지개색처럼 깨지는 문제가 발생하였다.


**❓ 원인 분석**

* OV7670 카메라 레지스터 설정을 직접 변경하여 해상도를 낮추는 과정에서 출력 포맷과 타이밍이 불안정해졌다.
* 카메라 설정값이 변경되면서 RGB 데이터 정렬이나 픽셀 수신 타이밍이 기존 캡처 로직과 맞지 않았다.
* 이로 인해 FPGA 내부에서 기대하는 데이터 형식과 실제 카메라 출력 데이터가 달라져 색상 깨짐과 화면 잘림 현상이 발생하였다.

**❗ 해결 방법**

* 카메라 설정은 안정적으로 동작하던 `320×240` 해상도로 유지하였다.
* 대신 FPGA 내부 캡처 로직에서 `2x Subsampling` 방식을 적용하였다.
* 즉, 카메라에서 들어오는 픽셀 중 일부를 건너뛰어 저장함으로써 내부적으로 `160×120` 영상 데이터를 생성하였다.

**✅ 결과**

* OV7670 카메라 설정을 무리하게 변경하지 않아 영상 입력이 안정적으로 유지되었다.
* FPGA 내부 로직만으로 해상도 축소 효과를 구현할 수 있었다.
* 무지개색 깨짐 현상과 화면 잘림 문제가 줄어들었다.

<br>


### 7.3 화면 좌우 끝 세로줄 발생 문제

**🔍 문제 상황**

* VGA 화면의 좌측 또는 우측 끝에 희미한 흰 선이나 검은 세로줄이 나타나는 문제가 발생하였다.
* 영상 자체는 출력되지만 화면 가장자리 부분에 불필요한 픽셀이 보였다.


**❓ 원인 분석**

* VGA 출력 시작 시점과 BRAM에서 픽셀 데이터를 읽어오는 시점 사이에 미세한 타이밍 차이가 있었다.
* BRAM read latency 또는 초기 픽셀 데이터가 안정화되기 전의 값이 화면 가장자리로 출력되었다.
* 이로 인해 화면 좌우 끝부분에 쓰레기 데이터가 세로줄처럼 표시되었다.


**❗ 해결 방법**

* VGA Controller에서 픽셀 출력의 가로 방향 시작 시점을 `+3`만큼 미세 조정하였다.
* 출력 시작 위치를 약간 뒤로 밀어 초기화 시점의 불안정한 픽셀 데이터가 화면에 보이지 않도록 처리하였다.
* 화면 가장자리의 쓰레기 데이터를 마스킹하는 방식으로 문제를 해결하였다.

**✅ 결과**

* 화면 좌측 또는 우측 끝에 보이던 흰 선과 검은 세로줄이 줄어들었다.
* 카메라 영상이 VGA 화면에 더 깔끔하게 출력되었다.
* VGA 출력 타이밍과 BRAM read 타이밍이 더 안정적으로 맞춰졌다.


<br>

## 🔧 8. Future Improvements (개선 사항)

- 버튼 또는 스위치를 이용한 필터 모드 변경 기능 추가
- UART 명령을 통한 필터 모드 제어 기능 추가
- Sobel, Sepia, Sharpen 등 추가 필터 구현
- RGB444보다 더 높은 색상 표현을 위한 RGB565 또는 RGB888 확장
- Double Buffering을 적용하여 화면 찢김 현상 개선
- VGA 출력에서 HDMI 출력으로 확장
- 원본 영상과 필터 적용 영상을 동시에 보여주는 분할 화면 모드 추가


