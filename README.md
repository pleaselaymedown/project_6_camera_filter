# 📷 Project_6 Camera Filter

<br>

## 📌 1. Project Summary (프로젝트 요약)

Basys3 FPGA 보드와 OV7670 카메라 모듈을 사용하여 FPGA 내부에서 영상 필터를 적용한 뒤, VGA 모니터로 출력하는 프로젝트

<br>

## ✨ 2. Key Features (주요 기능)
- OV7670 카메라 모듈로 영상을 입력받아 VGA 모니터에 출력
- 5가지 필터 모드 선택

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

### ⚠️ 7.1 BRAM 사용량 증가로 인한 동작 불가 문제

**🔍 문제 상황**
* BRAM 사용량이 초과되어 정상적인 구현 및 동작이 불가

**❓ 원인 분석**
* 안정적인 영상 처리를 위해 `Double Buffer`를 사용
* MicroBlaze-V Local Memory가 `128KB`로 설정되어 BRAM 자원을 과도하게 사용

**❗ 해결 방법**
* 프레임 버퍼 구조를 `Double Buffer`에서 `Single Buffer`로 변경
* MicroBlaze-V의 Local Memory 크기를 `128KB`에서 `32KB`로 축소

**✅ 결과**
* BRAM 사용량이 감소하여 FPGA 내부 자원 부족 문제가 완화됨
* Single Buffer 구조에서도 카메라 입력과 VGA 출력이 정상적으로 동작함
* MicroBlaze-V Local Memory를 축소해도 카메라 설정 및 필터 제어에는 문제 없음을 확인

<br>


### ⚠️ 7.2 160×120 해상도 전환 실패 문제

**🔍 문제 상황**
* 카메라 출력 해상도를 `160×120`으로 낮추려고 했지만 영상이 정상적으로 축소되지 않고, 화면 일부가 잘려서 출력되거나, 색상이 무지개색처럼 깨지는 문제가 발생


**❓ 원인 분석**
* 카메라 설정값이 변경되면서 RGB 데이터 정렬이나 픽셀 수신 타이밍이 기존 캡처 로직과 맞지 않았다.

**❗ 해결 방법**
* `320×240` 해상도로 유지하고, 대신 FPGA 내부 캡처 로직에서 `2x Subsampling` 방식을 적용

**✅ 결과**
* 카메라에서 들어오는 픽셀 중 일부를 건너뛰어 저장함으로써 내부적으로 `160×120` 영상 데이터를 생성함
* 무지개색 깨짐 현상과 화면 잘림 문제가 줄어듦
<br>


### ⚠️ 7.3 화면 좌우 끝 세로줄 발생 문제

**🔍 문제 상황**
* VGA 화면의 좌측 또는 우측 끝에 희미한 흰 선이나 검은 세로줄이 나타나는 문제가 발생

**❓ 원인 분석**
* VGA 출력 시작 시점과 BRAM에서 픽셀 데이터를 읽어오는 시점 사이에 타이밍 차이 존재


**❗ 해결 방법**
* VGA Controller에서 픽셀 출력의 시작 시점을 `+3`만큼 조정하여 출력 시작 위치를 뒤로 밀어 초기화 시점의 불안정한 픽셀 데이터가 화면에 보이지 않도록 처리

**✅ 결과**
* 화면 좌측 또는 우측 끝에 보이던 흰 선과 검은 세로줄이 줄어들었다


<br>

## 🔧 8. Future Improvements (개선 사항)

- 원본 영상과 필터 적용 영상을 동시에 보여주는 분할 화면 모드 추가
- 추가 영상 필터 구현

