# DE10-Standard FPGA Engineering Knowledge Base (EKB)

Board: **Terasic DE10-Standard** — Intel (Altera) **Cyclone V SoC 5CSXFC6D6F31C6N**
Chương trình: Altera University Program
Trạng thái: 🚧 Foundation Pack (Gói 1) hoàn tất — chuẩn bị Gói 2 (Handbook Skeleton)

## 1. Đây là gì?

Đây không phải một báo cáo Word đơn lẻ, mà là một **kho tài liệu kỹ thuật có cấu trúc (EKB)**
theo mô hình các tập đoàn công nghệ dùng để quản lý tài liệu phần cứng/firmware: mô-đun hóa,
theo dõi bằng Git, có "Single Source of Truth" cho mọi hình ảnh và mã nguồn.

## 2. Cấu trúc thư mục

```
DE10-Standard_FPGA_EKB/
├── 00_Project_Management/     # Quản lý dự án — BẮT ĐẦU ĐỌC TỪ ĐÂY
│   ├── Revision History.docx          # Quy ước version + nhật ký sửa đổi
│   ├── Document Control.docx          # Quy ước đặt tên, lưu trữ, quyền hạn
│   ├── Roadmap.docx                   # Lộ trình 6 Phase (A-F)
│   ├── Engineering Decision Log.docx  # ADR — quyết định kỹ thuật
│   ├── Change Log.docx                # Nhật ký thay đổi (Keep a Changelog)
│   ├── Meeting Notes.docx             # Biên bản họp mentor
│   ├── Progress Dashboard.xlsx        # (Gói sau)
│   └── TODO.xlsx                      # (Gói sau)
│
├── 01_Architecture_Baseline/
│   └── Universal_FPGA_Engineering_Handbook_Architecture_Baseline.docx
│       # Tài liệu kiến trúc GỐC — mọi Volume phải tuân theo file này
│
├── 02_Handbook/                # 6 Volume — sẽ tạo ở Gói 2
├── 03_Resources/                # Datasheet, Schematic, Quartus Reports
├── 04_Projects/                 # Mã nguồn thật: LED, UART, SPI, VGA, HPS...
├── 05_References/               # Tài liệu Intel/ARM/IEEE tham khảo
├── 06_Knowledge_Graph/          # Ma trận phụ thuộc kiến thức
├── 07_Engineering_Assets/       # Block diagram, icon, style guide, template
├── 08_Review/                   # Mentor Checklist, Self-Assessment, Release Notes
└── README.md                    # File này
```

## 3. Bắt đầu từ đâu?

1. Đọc **Document Control.docx** — hiểu quy ước đặt tên & lưu trữ trước khi tạo bất kỳ file nào.
2. Đọc **Architecture Baseline.docx** — đây là "hiến pháp kỹ thuật" của toàn bộ EKB (chuẩn code,
   cấu trúc project, ma trận yêu cầu nội dung cho từng Volume).
3. Xem **Roadmap.docx** để biết đang ở Phase nào.
4. Mỗi khi sửa đổi nội dung → cập nhật **Revision History.docx** + **Change Log.docx**.
5. Mỗi khi đưa ra quyết định kỹ thuật quan trọng → viết ADR trong **Engineering Decision Log.docx**.
6. Sau mỗi buổi họp mentor → ghi lại trong **Meeting Notes.docx**.

## 4. Clone & sử dụng repo (Git)

```bash
git clone <URL_REPO_CUA_BAN> DE10-Standard_FPGA_EKB
cd DE10-Standard_FPGA_EKB
```

Quy ước commit message:
```
[<Module>][<version>] <mô tả ngắn>
# Ví dụ:
[Volume-II][v1.2.0] Thêm chương Clock Domain Crossing
[PM][v0.1.0] Khởi tạo Foundation Pack
```

`.gitignore` đề xuất (xem chi tiết trong Document Control.docx mục 6):
```
_scratch/
*.tmp.docx
~$*.docx
db/
incremental_db/
```

## 5. Toolchain cần cài (xem chi tiết Architecture Baseline mục 6)

- Quartus Prime Lite (hỗ trợ Cyclone V)
- ModelSim-Intel FPGA Edition (đi kèm Quartus)
- SoC EDS (Embedded Design Suite) — cho phần HPS/Linux
- Driver USB-Blaster
- Tera Term / PuTTY (UART console)

## 6. Lộ trình (tóm tắt — chi tiết xem Roadmap.docx)

| Gói | Nội dung | Trạng thái |
|---|---|---|
| Gói 1 — Foundation Pack | 8 file quản lý dự án + baseline kiến trúc | ✅ Hoàn tất |
| Gói 2 — Handbook Skeleton | Khung 6 Volume (cover, TOC, chapter, checklist) | ⬜ Chưa bắt đầu |
| Gói 3 — Resources Pack | Template đọc datasheet/schematic/timing | ⬜ Chưa bắt đầu |
| Gói 4 — Project Pack | Template LED/UART/SPI/VGA/Platform Designer/HPS | ⬜ Chưa bắt đầu |
| Gói 5 — Review Pack | Mentor Checklist, Self-Assessment, Release | ⬜ Chưa bắt đầu |

## 7. Liên hệ / Chủ dự án

- Chủ dự án: (điền tên bạn)
- Mentor: (điền tên mentor)
- Chương trình: Thực tập — Altera University Program, board DE10-Standard
