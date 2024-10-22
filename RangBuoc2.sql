USE QL_NhaThuoc
--- bảng người dùng
ALTER TABLE NguoiDung
ADD CONSTRAINT CK_NguoiDung_TrangThai CHECK (TrangThai IN ('Active', 'Inactive'));

ALTER TABLE NguoiDung
ADD CONSTRAINT CK_NguoiDung_Email CHECK (Email LIKE '%_@__%.__%');

ALTER TABLE NguoiDung
ADD CONSTRAINT CK_NguoiDung_SoDienThoai CHECK (LEN(SoDienThoai) BETWEEN 10 AND 15);

ALTER TABLE NguoiDung
ADD CONSTRAINT CK_NguoiDung_Password_Dai CHECK (LEN(Password) >= 8);
ALTER TABLE NguoiDung
ADD CONSTRAINT CK_NguoiDung_Password_So CHECK (Password LIKE '%[0-9]%');
ALTER TABLE NguoiDung
ADD CONSTRAINT CK_NguoiDung_Password_ChuHoa CHECK (Password LIKE '%[A-Z]%');
ALTER TABLE NguoiDung
ADD CONSTRAINT CK_NguoiDung_Password_ChuThuong CHECK (Password LIKE '%[a-z]%');
ALTER TABLE NguoiDung
ADD CONSTRAINT CK_NguoiDung_Password_KyTuDacBiet CHECK (Password LIKE '%[^a-zA-Z0-9]%');
use QL_NhaThuoc

-- hàm băm pass
CREATE FUNCTION dbo.HashPassword(@Password NVARCHAR(255))
RETURNS NVARCHAR(64)
AS
BEGIN
    RETURN CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', @Password), 2);
END;
SELECT dbo.HashPassword('NhathuocAnKhang24h');

---test
INSERT INTO NguoiDung (TenNguoiDung, Password, Email, SoDienThoai, MaVaiTro, TrangThai)
VALUES ('Nguyen Van A', dbo.HashPassword('matkhau123'), 'nguyenvana@example.com', '0909123456', 1, 'Active');
--- bảng nhân viên

ALTER TABLE NhanVien
ADD CONSTRAINT CK_NhanVien_NgaySinh CHECK (
    NgaySinh < GETDATE() -- Ngày sinh phải nhỏ hơn ngày hiện tại
    AND DATEDIFF(YEAR, NgaySinh, GETDATE()) BETWEEN 21 AND 40 -- Độ tuổi phải nằm trong khoảng từ 21 đến 40 tuổi
);

ALTER TABLE NhanVien
ADD CONSTRAINT CK_NhanVien_GioiTinh CHECK (GioiTinh IN ('Nam', 'Nữ'));

ALTER TABLE NhanVien
ADD CONSTRAINT CK_NhanVien_TrangThai CHECK (TrangThai IN (N'Đang làm', N'Đã nghĩ'));
ALTER TABLE [dbo].[NhanVien]
ADD CONSTRAINT DF_NhanVien_TrangThai DEFAULT N'Đang làm' FOR [TrangThai];


ALTER TABLE NhanVien
ADD CONSTRAINT CK_NhanVien_CaLamViec CHECK (MaCaLamViec IS NOT NULL OR TrangThai = N'Đã nghĩ');

ALTER TABLE NhanVien
ADD CONSTRAINT CK_NhanVien_ChucVu CHECK (ChucVu IN ('Nhân viên Kho', 'Nhân viên Bán Hàng'));

-- Ràng buộc lương cơ bản 1 ca không âm
ALTER TABLE [dbo].[NhanVien]
ADD CONSTRAINT CK_NhanVien_LuongCoBan1Ca
CHECK (LuongCoBan1Ca >= 0);

-- Ràng buộc lương tăng ca 1 giờ không âm
ALTER TABLE [dbo].[NhanVien]
ADD CONSTRAINT CK_NhanVien_LuongTangCa1Gio
CHECK (LuongTangCa1Gio >= 0);

-- khách hàng 

ALTER TABLE KhachHang
ADD CONSTRAINT CK_KhachHang_GioiTinh
CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác'));

ALTER TABLE KhachHang
ADD CONSTRAINT CK_KhachHang_NgaySinh
CHECK (NgaySinh <= GETDATE());

ALTER TABLE KhachHang
ADD CONSTRAINT CK_KhachHang_Diem
CHECK (Diem >= 0);

ALTER TABLE KhachHang
ADD CONSTRAINT DF_KhachHang_Diem
DEFAULT 0 FOR Diem;

ALTER TABLE KhachHang
ADD CONSTRAINT CK_KhachHang_SoDienThoai
CHECK (SoDienThoai LIKE '[0-9]%');

--- cham cong

ALTER TABLE ChamCong
ADD CONSTRAINT CK_ChamCong_ThoiGianVaoRa
CHECK (ThoiGianRaVe >= ThoiGianVaoLam);

ALTER TABLE ChamCong
ADD CONSTRAINT CK_ChamCong_ThoiGianVaoLam CHECK (CAST(ThoiGianVaoLam AS DATE) = NgayChamCong);

ALTER TABLE ChamCong
ADD CONSTRAINT CK_ChamCong_ThoiGianRaVe CHECK (CAST(ThoiGianRaVe AS DATE) = NgayChamCong);

ALTER TABLE ChamCong
ADD CONSTRAINT CK_ChamCong_NgayChamCong CHECK (NgayChamCong <= GETDATE());

ALTER TABLE ChamCong
ADD CONSTRAINT CK_ChamCong_ThoiGianVaoLam_HienTai CHECK (ThoiGianVaoLam <= GETDATE());

ALTER TABLE ChamCong
ADD CONSTRAINT CK_ChamCong_ThoiGianRaVe_HienTai CHECK (ThoiGianRaVe <= GETDATE());

ALTER TABLE ChamCong
ADD CONSTRAINT CK__ChamCong_GhiChu
CHECK (GhiChu IN (N'Đạt', N'Không Đạt'));

ALTER TABLE ChamCong
ADD CONSTRAINT DF_ChamCong_GhiChu DEFAULT N'Không Đạt' FOR GhiChu;

---Luong

ALTER TABLE Luong
ADD CONSTRAINT CK_Luong_KhauTru
CHECK (KhauTru >= 0);

ALTER TABLE Luong
ADD CONSTRAINT CK_Luong_LuongThucNhan
CHECK (LuongThucNhan >= 0);

ALTER TABLE Luong
ADD CONSTRAINT CK_Luong_SoCaLamViec CHECK (SoCaLamViec > 0);

ALTER TABLE Luong
ADD CONSTRAINT CK_Luong_LuongThang CHECK (LuongThang <= GETDATE());

ALTER TABLE Luong
ADD CONSTRAINT CK_Luong_NgayTraLuong CHECK (NgayTraLuong >= GETDATE());

---FAQ
ALTER TABLE FAQ
ADD CONSTRAINT CK_FAQ_CauHoiThuongGap CHECK (LEN(LTRIM(RTRIM(CauHoiThuongGap))) > 0);

ALTER TABLE FAQ
ADD CONSTRAINT CK_FAQ_CauTraLoiTuongUng CHECK (LEN(LTRIM(RTRIM(CauTraLoiTuongUng))) > 0);

ALTER TABLE FAQ
ADD CONSTRAINT CK_FAQ_NgayCapNhatCauHoi CHECK (NgayCapNhatCauHoi IS NULL OR NgayCapNhatCauHoi >= NgayTaoCauHoi);

ALTER TABLE FAQ
ADD CONSTRAINT CK_FAQ_DanhMucCauHoi_KhongRong CHECK (LEN(LTRIM(RTRIM(DanhMucCauHoi))) > 0);

ALTER TABLE FAQ
ADD CONSTRAINT CK_FAQ_DanhMucCauHoi CHECK (DanhMucCauHoi IN ('Tìm kiếm thuốc', 'Tư vấn sức khỏe', 'Tương tác thuốc', 'Câu Hỏi Khác'));


-- Ca lam viec 
ALTER TABLE CaLamViec
ADD CONSTRAINT CK_CaLamViec_ThoiGianKetThuc CHECK (ThoiGianKetThuc > ThoiGianBatDau);

ALTER TABLE CaLamViec
ADD CONSTRAINT CK_CaLamViec_GioNghiTrua CHECK (GioNghiTrua IS NULL OR (GioNghiTrua > ThoiGianBatDau AND GioNghiTrua < ThoiGianKetThuc));

ALTER TABLE CaLamViec
ADD CONSTRAINT CK_CaLamViec_ThoiGianTao CHECK (ThoiGianTao <= GETDATE());



