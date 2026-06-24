# 📷 Project_6 Camera Filter

<br>

## 📌 1. Project Summary (프로젝트 요약)

Basys3 FPGA 보드와 OV7670 카메라 모듈을 사용하여 FPGA 내부에서 영상 필터를 적용한 뒤, VGA 모니터로 출력하는 프로젝트

<br>

## ✨ 2. Key Features (주요 기능)
- OV7670 카메라 모듈로 영상을 입력받아 VGA 모니터에 출력
- BRAM을 이용하여 카메라 영상 데이터를 저장하고 출력
- 5가지 필터 모드 선택

<br>

## 🛠️ 3. Tech Stack (기술 스택)

### 3.1 Language (사용언어)

<p>
  <img src="https://img.shields.io/badge/Verilog-blue?style=for-the-badge">
</p>

<br>

### 3.2 Development Environment (개발 환경)

<p>
  <img src="https://img.shields.io/badge/Vivado-orange?style=for-the-badge">
  <img src="https://img.shields.io/badge/Vitis-blueviolet?style=for-the-badge">
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
## 🔌 6. Custom IP Description (커스텀 IP 설명)
<br>

### 6.1 Custom IP Summary

| Custom IP             | 역할                         |
| --------------------- | -------------------------- |
| `myip_ov7670_cfg`     |  OV7670 카메라 레지스터 초기화        |
| `myip_ov7670_capture` |  OV7670 영상 데이터 수신 및 BRAM 저장 |
| `myip_vga_controller` |  VGA 640×480 출력 타이밍 생성      |
| `myip_filter`         |  실시간 영상 필터 처리               |

<br>

---

### 6.2 OV7670 Config IP

OV7670 카메라의 내부 레지스터를 설정하기 위한 Custom IP이다.
MicroBlaze-V가 AXI4-Lite Register에 카메라 설정값을 저장하면, IP 내부의 `sccb_ctrl` 모듈이 SCCB 통신을 통해 OV7670 카메라에 설정값을 전송한다.


<br>

**Register Map**

| Address  | Register         | 설명                                         |
| -------- | ---------------- | ------------------------------------------ |
| `0x00`   | Control / Status | `[0] start`, `[5:1] num_regs`, `[31] done` |
| `0x04 ~` | Config Register  | `[23:16] reg_addr`, `[7:0] reg_data`       |

<br>


### 6.3 OV7670 Capture IP

OV7670 카메라에서 들어오는 영상 데이터를 수신하여 BRAM에 저장하는 Custom IP이다.
카메라의 `PCLK`, `VSYNC`, `HREF`, `DATA[7:0]` 신호를 이용해 픽셀 데이터를 읽고, RGB565 형식의 데이터를 RGB444 형식으로 변환한다.

<br>


**입출력 신호**

| 신호           | 방향     | 설명                 |
| ------------ | ------ | ------------------ |
| `pclk`       | Input  | OV7670 Pixel Clock |
| `vsync`      | Input  | 프레임 동기 신호          |
| `href`       | Input  | 유효 픽셀 구간 신호        |
| `d[7:0]`     | Input  | 카메라 데이터            |
| `addr[16:0]` | Output | BRAM Write Address |
| `dout[11:0]` | Output | RGB444 픽셀 데이터      |
| `we`         | Output | BRAM Write Enable  |

<br>

**RGB 변환 방식**

```text
OV7670 입력 데이터 : RGB565
FPGA 내부 저장 데이터 : RGB444
```

```verilog
dout[11:8] <= d_reg[7:4];                 // R 4bit
dout[ 7:4] <= {d_reg[2:0], d_delayed[7]}; // G 4bit
dout[ 3:0] <= d_delayed[4:1];             // B 4bit
```

<br>

---

### 6.4 VGA Controller IP

BRAM에서 읽어온 픽셀 데이터를 VGA 신호로 변환하여 모니터에 출력하는 Custom IP이다.
`25MHz` Pixel Clock을 기준으로 VGA `640×480 @ 60Hz` 타이밍을 생성하고, `320×240` 카메라 영상을 화면 중앙에 표시한다.

<br>

**동작 흐름**

```text
BRAM Read Address 생성
    ↓
BRAM에서 픽셀 데이터 읽기
    ↓
Filter IP에서 필터 처리
    ↓
VGA Controller로 RGB 데이터 전달
    ↓
VGA 모니터 출력
```

<br>


### 6.5 Image Filter IP

BRAM에서 읽은 카메라 픽셀 데이터를 VGA Controller로 보내기 전에 필터 처리하는 Custom IP이다.
MicroBlaze-V가 AXI4-Lite Register에 `filter_sel` 값을 쓰면, 해당 값에 따라 실시간으로 필터 모드가 변경된다.

<br>

**Register Map**

| Address | Register          | 설명       |
| ------- | ----------------- | -------- |
| `0x00`  | `filter_sel[2:0]` | 필터 모드 선택 |

<br>

**Filter Mode**

| filter_sel | 필터 모드       | 설명                             |
| ---------- | ----------- | ------------------------------ |
| `0`        | Original    | 원본 영상 출력                       |
| `1`        | Grayscale   | `(R + 2G + B) / 4` 방식의 흑백 변환   |
| `2`        | Invert      | RGB 색상 반전                      |
| `3`        | Brightness  | 각 RGB 채널에 `+4` 적용              |
| `4`        | Edge Detect | 현재 라인과 이전 라인의 픽셀 차이를 이용한 엣지 검출 |
| `5`        | Blur        | 현재 라인과 이전 라인의 평균값을 이용한 블러 처리   |

<br>

```


| Reset 신호       | 사용 대상                  | 조건                          |
| -------------- | ---------------------- | --------------------------- |
| `rstn_basic`   | VGA Controller 등 기본 모듈 | `rstn & locked`             |
| `rstn_capture` | OV7670 Capture IP      | `rstn & locked & init_done` |

<br>

이를 통해 카메라 설정이 끝나기 전에 Capture IP가 먼저 동작하는 문제를 방지하였다.

<br>


### 5.2 Block Design

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

