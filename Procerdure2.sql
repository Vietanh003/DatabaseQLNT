--nhan vien*
use QL_NhaThuoc
CREATE PROCEDURE sp_ThemNhanVienMoi
    @Ho NVARCHAR(50),
    @Ten NVARCHAR(50),
    @NgaySinh DATE,
    @GioiTinh NVARCHAR(10),
    @DiaChi NVARCHAR(255),
    @ChucVu NVARCHAR(50),
    @NgayTuyenDung DATE,
    @MaNguoiDung INT=Null,
    @MaCaLamViec INT=Null,
    @LuongCoBan1Ca DECIMAL(18, 0) = NULL, -- Giá trị mặc định là NULL nếu không truyền vào
    @LuongTangCa1Gio DECIMAL(18, 0) = NULL -- Giá trị mặc định là NULL nếu không truyền vào
AS
BEGIN
    -- Thêm nhân viên vào bảng NhanVien
    INSERT INTO NhanVien
    (
        Ho, Ten, NgaySinh, GioiTinh, DiaChi, ChucVu, NgayTuyenDung, MaNguoiDung, MaCaLamViec, LuongCoBan1Ca, LuongTangCa1Gio
    )
    VALUES
    (
        @Ho, @Ten, @NgaySinh, @GioiTinh, @DiaChi, @ChucVu, @NgayTuyenDung, @MaNguoiDung, @MaCaLamViec, @LuongCoBan1Ca, @LuongTangCa1Gio
    );
    
    -- Trả về thông báo thành công
    SELECT 'Thêm nhân viên thành công' AS ThongBao;
END
GO

--- cap nhat*
use QL_NhaThuoc
CREATE PROCEDURE sp_CapNhatThongTinNhanVien
    @MaNhanVien INT,
    @Ho NVARCHAR(50) = NULL,
    @Ten NVARCHAR(50) = NULL,
    @NgaySinh DATE = NULL,
    @GioiTinh NVARCHAR(10) = NULL,
    @DiaChi NVARCHAR(255) = NULL,
    @ChucVu NVARCHAR(50) = NULL,
    @NgayTuyenDung DATE = NULL,
    @TrangThai NVARCHAR(50) = NULL,
    @MaNguoiDung INT = NULL,
    @MaCaLamViec INT = NULL,
    @LuongCoBan1Ca DECIMAL(18, 0) = NULL,
    @LuongTangCa1Gio DECIMAL(18, 0) = NULL
AS
BEGIN
    -- Kiểm tra tồn tại của nhân viên
    IF EXISTS (SELECT 1 FROM NhanVien WHERE MaNhanVien = @MaNhanVien)
    BEGIN
        -- Cập nhật thông tin nhân viên
        UPDATE NhanVien
        SET
            Ho = COALESCE(@Ho, Ho),
            Ten = COALESCE(@Ten, Ten),
            NgaySinh = COALESCE(@NgaySinh, NgaySinh),
            GioiTinh = COALESCE(@GioiTinh, GioiTinh),
            DiaChi = COALESCE(@DiaChi, DiaChi),
            ChucVu = COALESCE(@ChucVu, ChucVu),
            NgayTuyenDung = COALESCE(@NgayTuyenDung, NgayTuyenDung),
            TrangThai = COALESCE(@TrangThai, TrangThai),
            MaNguoiDung = COALESCE(@MaNguoiDung, MaNguoiDung),
            MaCaLamViec = COALESCE(@MaCaLamViec, MaCaLamViec),
            LuongCoBan1Ca = COALESCE(@LuongCoBan1Ca, LuongCoBan1Ca),
            LuongTangCa1Gio = COALESCE(@LuongTangCa1Gio, LuongTangCa1Gio)
        WHERE
            MaNhanVien = @MaNhanVien;
        
        -- Thông báo cập nhật thành công
        PRINT 'Cập nhật thông tin nhân viên thành công.';
    END
    ELSE
    BEGIN
        -- Thông báo nhân viên không tồn tại
        PRINT 'Nhân viên không tồn tại.';
    END
END
GO


----xoa*
CREATE PROCEDURE sp_XoaNhanVien
    @MaNhanVien INT
AS
BEGIN
    DECLARE @MaNguoiDung INT;
    DECLARE @TrangThai NVARCHAR(50);

    -- Lấy thông tin trạng thái của nhân viên
    SELECT @MaNguoiDung = MaNguoiDung, @TrangThai = TrangThai 
    FROM NhanVien 
    WHERE MaNhanVien = @MaNhanVien;

    -- Kiểm tra trạng thái của nhân viên
    IF @TrangThai = N'Đã nghĩ'  
    BEGIN
        -- Xóa nhân viên
        DELETE FROM NhanVien WHERE MaNhanVien = @MaNhanVien;

        -- Cập nhật trạng thái người dùng thành 'Inactive'
        UPDATE NguoiDung
        SET TrangThai = 'Inactive'
        WHERE MaNguoiDung = @MaNguoiDung;
        RETURN 0;
    END
    ELSE
    BEGIN
        RETURN 2;
    END
END
GO

---khach hang
---them
CREATE PROCEDURE sp_ThemKhachHang
    @TenKhachHang NVARCHAR(255),
    @GioiTinh NVARCHAR(10),
    @DiaChi NVARCHAR(255),
    @NgaySinh DATE,
    @SoDienThoai NVARCHAR(20),
    @MaNguoiDung INT= Null
AS
BEGIN
    INSERT INTO KhachHang (TenKhachHang, GioiTinh, DiaChi, NgaySinh, SoDienThoai, MaNguoiDung)
    VALUES (@TenKhachHang, @GioiTinh, @DiaChi, @NgaySinh, @SoDienThoai, @MaNguoiDung);
END
GO
--- update
CREATE PROCEDURE sp_CapNhatThongTinKhachHang
    @MaKhachHang INT,           -- Mã khách hàng lấy từ thông tin đăng nhập
    @TenKhachHang NVARCHAR(255) = NULL,  -- Tên khách hàng (tùy chọn)
    @GioiTinh NVARCHAR(10) = NULL,       -- Giới tính (tùy chọn)
    @DiaChi NVARCHAR(255) = NULL,        -- Địa chỉ (tùy chọn)
    @NgaySinh DATE = NULL,               -- Ngày sinh (tùy chọn)
    @SoDienThoai NVARCHAR(20) = NULL     -- Số điện thoại (tùy chọn)
AS
BEGIN
    -- Kiểm tra nếu mã khách hàng tồn tại
    IF EXISTS (SELECT 1 FROM KhachHang WHERE MaKhachHang = @MaKhachHang)
    BEGIN
        -- Cập nhật thông tin khách hàng dựa trên các giá trị không NULL
        UPDATE KhachHang
        SET 
            TenKhachHang = ISNULL(@TenKhachHang, TenKhachHang),
            GioiTinh = ISNULL(@GioiTinh, GioiTinh),
            DiaChi = ISNULL(@DiaChi, DiaChi),
            NgaySinh = ISNULL(@NgaySinh, NgaySinh),
            SoDienThoai = ISNULL(@SoDienThoai, SoDienThoai)
        WHERE MaKhachHang = @MaKhachHang;

        -- Trả về thông báo thành công
        SELECT 'Cập nhật thông tin khách hàng thành công' AS ThongBao;
    END
    ELSE
    BEGIN
        -- Nếu không tìm thấy mã khách hàng
        SELECT 'Lỗi: Không tìm thấy khách hàng với mã này' AS ThongBao;
    END
END
GO
-- nguoi dung
--them nguoi dung

CREATE PROCEDURE sp_ThemNguoiDungKhachHang
    @TenNguoiDung NVARCHAR(255),   -- Tên người dùng
    @Password NVARCHAR(255),       -- Mật khẩu
    @Email NVARCHAR(255),          -- Email
    @SoDienThoai NVARCHAR(20),     -- Số điện thoại
    @TrangThai NVARCHAR(50) = 'Active', -- Trạng thái tài khoản, mặc định là 'Hoạt động'
    @NgayTao DATE = NULL           -- Ngày tạo tài khoản, mặc định là NULL, sẽ được gán giá trị sau
AS
BEGIN
    DECLARE @MaVaiTro INT;

    -- Nếu @NgayTao là NULL, thiết lập giá trị là ngày hiện tại
    IF @NgayTao IS NULL
    BEGIN
        SET @NgayTao = GETDATE();
    END

    -- Tìm mã vai trò cho khách hàng
    SELECT @MaVaiTro = MaVaiTro FROM VaiTro WHERE TenVaiTro = N'Khách hàng';
    
    -- Kiểm tra nếu không tìm thấy vai trò Khách hàng
    IF @MaVaiTro IS NULL
    BEGIN
        SELECT 'Lỗi: Không tìm thấy vai trò Khách hàng trong hệ thống' AS ThongBao;
        RETURN;
    END

    -- Thêm người dùng vào bảng NguoiDung với vai trò Khách hàng
    INSERT INTO NguoiDung (TenNguoiDung, Password, Email, SoDienThoai, MaVaiTro, TrangThai, NgayTao)
    VALUES (@TenNguoiDung, dbo.HashPassword(@Password), @Email, @SoDienThoai, @MaVaiTro, @TrangThai, @NgayTao);
    
    -- Trả về thông báo thành công
    SELECT 'Tạo tài khoản khách hàng thành công' AS ThongBao;
END
GO

--- cap nhat thong tin
CREATE PROCEDURE sp_CapNhatThongTinNguoiDung
    @MaNguoiDung INT,           -- Mã người dùng, lấy từ thông tin đăng nhập
    @TenNguoiDung NVARCHAR(255) = NULL,  -- Tên người dùng (tùy chọn)
    @Password NVARCHAR(255) = NULL,      -- Mật khẩu (tùy chọn)
    @Email NVARCHAR(255) = NULL,         -- Email (tùy chọn)
    @SoDienThoai NVARCHAR(20) = NULL  -- Số điện thoại (tùy chọn)
AS
BEGIN
    -- Kiểm tra xem mã người dùng có tồn tại không
    IF EXISTS (SELECT 1 FROM NguoiDung WHERE MaNguoiDung = @MaNguoiDung)
    BEGIN
        -- Cập nhật thông tin người dùng dựa trên các giá trị không NULL
        UPDATE NguoiDung
        SET 
            TenNguoiDung = ISNULL(@TenNguoiDung, TenNguoiDung),
            Password = ISNULL (dbo.HashPassword(@Password), Password),
            Email = ISNULL(@Email, Email),
            SoDienThoai = ISNULL(@SoDienThoai, SoDienThoai)
        WHERE MaNguoiDung = @MaNguoiDung;

        -- Trả về thông báo thành công
        SELECT 'Cập nhật thông tin người dùng thành công' AS ThongBao;
    END
    ELSE
    BEGIN
        -- Nếu không tìm thấy mã người dùng
        SELECT 'Lỗi: Không tìm thấy người dùng với mã này' AS ThongBao;
    END
END
GO

---ca lam viec
-- Stored Procedures cho bảng CaLamViec

---them 
CREATE PROCEDURE sp_ThemCaLamViec
    @ThoiGianBatDau TIME,
    @ThoiGianKetThuc TIME,
    @ThoiGianTao DATE,
    @GhiChuCongViec NVARCHAR(MAX),
    @GioNghiTrua TIME
AS
BEGIN
    INSERT INTO CaLamViec (ThoiGianBatDau, ThoiGianKetThuc, ThoiGianTao, GhiChuCongViec, GioNghiTrua)
    VALUES (@ThoiGianBatDau, @ThoiGianKetThuc, @ThoiGianTao, @GhiChuCongViec, @GioNghiTrua);
END
GO
---update 
CREATE PROCEDURE sp_CapNhatCaLamViec
    @MaCaLam INT,
    @ThoiGianBatDau TIME,
    @ThoiGianKetThuc TIME,
    @GhiChuCongViec NVARCHAR(MAX),
    @GioNghiTrua TIME
AS
BEGIN
    UPDATE CaLamViec
    SET ThoiGianBatDau = @ThoiGianBatDau,
        ThoiGianKetThuc = @ThoiGianKetThuc,
        GhiChuCongViec = @GhiChuCongViec,
        GioNghiTrua = @GioNghiTrua
    WHERE MaCaLam = @MaCaLam;
END
GO
---delete
CREATE PROCEDURE sp_XoaCaLamViec
    @MaCaLam INT
AS
BEGIN
    DELETE FROM CaLamViec WHERE MaCaLam = @MaCaLam;
END
GO
---- select ca lam viec
CREATE PROCEDURE sp_LayTatCaCaLamViec
AS
BEGIN
    SELECT * FROM CaLamViec;
END
GO
--- Stored Procedures cho bảng ChamCong
--- cham cong ra
CREATE PROCEDURE sp_ThemChamCongVao
    @MaNhanVien INT -- Mã nhân viên lấy từ phiên đăng nhập hiện tại
AS
BEGIN
    -- Lấy thời gian hiện tại cho ThoiGianVaoLam và ngày hiện tại cho NgayChamCong
    DECLARE @ThoiGianVaoLam DATETIME = GETDATE();
    DECLARE @NgayChamCong DATE = CAST(GETDATE() AS DATE);

    -- Thêm một bản ghi mới vào bảng ChamCong với thời gian vào làm, và để trống thời gian ra về
    INSERT INTO ChamCong (MaNhanVien, ThoiGianVaoLam, ThoiGianRaVe, NgayChamCong)
    VALUES (@MaNhanVien, @ThoiGianVaoLam, NULL, @NgayChamCong);
END
GO
--- cham cong vao 
CREATE PROCEDURE sp_ChamCongRa
    @MaNhanVien INT -- Mã nhân viên lấy từ thông tin đăng nhập
AS
BEGIN
    -- Cập nhật thời gian ra về cho bản ghi chấm công gần nhất của nhân viên trong ngày hiện tại
    UPDATE ChamCong
    SET ThoiGianRaVe = GETDATE()
    WHERE MaNhanVien = @MaNhanVien
      AND NgayChamCong = CONVERT(DATE, GETDATE())
      AND ThoiGianRaVe IS NULL; -- Chỉ cập nhật nếu chưa có thời gian ra về
    
    -- Kiểm tra nếu không có bản ghi nào được cập nhật (ví dụ như chưa chấm công vào)
    IF @@ROWCOUNT = 0
    BEGIN
        SELECT 'Lỗi: Không tìm thấy bản ghi chấm công vào hoặc đã chấm công ra' AS ThongBao;
    END
    ELSE
    BEGIN
        SELECT 'Chấm công ra thành công' AS ThongBao;
    END
END
GO
---

---FAQ
CREATE PROCEDURE sp_ThemCauHoi
    @CauHoiThuongGap NVARCHAR(MAX),
    @CauTraLoiTuongUng NVARCHAR(MAX),
    @DanhMucCauHoi NVARCHAR(255),
    @NgayTaoCauHoi DATE
AS
BEGIN
    INSERT INTO FAQ (CauHoiThuongGap, CauTraLoiTuongUng, DanhMucCauHoi, NgayTaoCauHoi)
    VALUES (@CauHoiThuongGap, @CauTraLoiTuongUng, @DanhMucCauHoi, @NgayTaoCauHoi);
END
GO
----Cap nhat cau hoi
CREATE PROCEDURE sp_CapNhatCauHoi
    @MaCauHoi INT,
    @CauHoiThuongGap NVARCHAR(MAX),
    @CauTraLoiTuongUng NVARCHAR(MAX),
    @DanhMucCauHoi NVARCHAR(255),
    @NgayCapNhatCauHoi DATE
AS
BEGIN
    UPDATE FAQ
    SET CauHoiThuongGap = @CauHoiThuongGap,
        CauTraLoiTuongUng = @CauTraLoiTuongUng,
        DanhMucCauHoi = @DanhMucCauHoi,
        NgayCapNhatCauHoi = @NgayCapNhatCauHoi
    WHERE MaCauHoi = @MaCauHoi;
END
GO
--- xoa cau hoi
CREATE PROCEDURE sp_XoaCauHoi
    @MaCauHoi INT
AS
BEGIN
    DELETE FROM FAQ WHERE MaCauHoi = @MaCauHoi;
END
GO
--- ;lay tat ca cau hoi 
CREATE PROCEDURE sp_LayTatCaCauHoi
AS
BEGIN
    SELECT * FROM FAQ;
END
GO
---- tinh luong

CREATE PROCEDURE sp_ThemLuongNhanVien
    @MaNhanVien INT,              -- Mã nhân viên cần tính lương
    @LuongThang DATE,             -- Tháng lương (yyyy-MM-dd)
    @KhauTru DECIMAL(15, 2) = 0,  -- Khấu trừ (tùy chọn, mặc định là 0)
    @LuongThuong DECIMAL(18, 0) = 0, -- Lương thưởng (tùy chọn, mặc định là 0)
    @GhiChu NVARCHAR(255) = NULL  -- Ghi chú (tùy chọn)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SoCaLamViec INT;
    DECLARE @LuongThucNhan DECIMAL(15, 2);
    DECLARE @LuongCoBan1Ca DECIMAL(18, 0);
    DECLARE @LuongTangCa1Gio DECIMAL(18, 0);
    
    -- Lấy thông tin lương cơ bản và lương tăng ca từ bảng NhanVien
    SELECT 
        @LuongCoBan1Ca = LuongCoBan1Ca, 
        @LuongTangCa1Gio = LuongTangCa1Gio
    FROM NhanVien
    WHERE MaNhanVien = @MaNhanVien;

    -- Kiểm tra nếu nhân viên không tồn tại
    IF @LuongCoBan1Ca IS NULL
    BEGIN
        RAISERROR('Mã nhân viên không tồn tại.', 16, 1);
        RETURN;
    END

    -- Tính số ca làm việc trong tháng (chỉ tính các ca ghi chú là 'Đạt')
    SELECT @SoCaLamViec = COUNT(*)
    FROM ChamCong
    WHERE MaNhanVien = @MaNhanVien
      AND GhiChu = N'Đạt'
      AND YEAR(NgayChamCong) = YEAR(@LuongThang)
      AND MONTH(NgayChamCong) = MONTH(@LuongThang);

    -- Tính lương thực nhận
    SET @LuongThucNhan = (@LuongCoBan1Ca * @SoCaLamViec) + @LuongThuong - @KhauTru;

    -- Thêm vào bảng Luong
    INSERT INTO Luong (MaNhanVien, KhauTru, LuongThucNhan, NgayTraLuong, GhiChu, SoCaLamViec, LuongThang, LuongThuong)
    VALUES (@MaNhanVien, @KhauTru, @LuongThucNhan, GETDATE(), @GhiChu, @SoCaLamViec, @LuongThang, @LuongThuong);

    -- Trả về thông báo thành công
    SELECT 'Lương cho nhân viên đã được tính và thêm thành công.' AS ThongBao;
END
GO
--- cap nhat luong
CREATE PROCEDURE sp_CapNhatLuong
    @MaLuong INT,              -- Mã lương cần cập nhật
    @MaNhanVien INT,           -- Mã nhân viên
    @KhauTru DECIMAL(15, 2),   -- Số tiền khấu trừ
    @LuongThuong DECIMAL(18, 0),-- Số tiền thưởng (nếu có)
    @NgayTraLuong DATE,        -- Ngày trả lương
    @GhiChu NVARCHAR(255),     -- Ghi chú
    @LuongThang DATE           -- Tháng lương cần cập nhật
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra xem bản ghi lương có tồn tại không
    IF EXISTS (SELECT 1 FROM Luong WHERE MaLuong = @MaLuong AND MaNhanVien = @MaNhanVien AND LuongThang = @LuongThang)
    BEGIN
        -- Cập nhật thông tin lương cho nhân viên
        UPDATE Luong
        SET
            KhauTru = @KhauTru,
            LuongThuong = @LuongThuong,
            NgayTraLuong = @NgayTraLuong,
            GhiChu = @GhiChu
        WHERE MaLuong = @MaLuong 
          AND MaNhanVien = @MaNhanVien
          AND LuongThang = @LuongThang;

        -- Cập nhật lại LuongThucNhan sau khi thay đổi KhauTru và LuongThuong
        UPDATE Luong
        SET LuongThucNhan = (NV.LuongCoBan1Ca * L.SoCaLamViec) + ISNULL(LuongThuong, 0) - ISNULL(KhauTru, 0)
        FROM Luong L
        INNER JOIN NhanVien NV ON L.MaNhanVien = NV.MaNhanVien
        WHERE L.MaLuong = @MaLuong 
          AND L.MaNhanVien = @MaNhanVien
          AND L.LuongThang = @LuongThang;
          
        PRINT 'Cập nhật lương thành công!';
    END
    ELSE
    BEGIN
        -- Nếu bản ghi lương không tồn tại, thông báo lỗi
        PRINT 'Không tìm thấy bản ghi lương của nhân viên trong tháng này.';
    END
END
GO

--- thêm người dùng nhân viên*
CREATE PROCEDURE sp_ThemNguoiDungNhanVien
    @TenNguoiDung NVARCHAR(255),   -- Tên người dùng
    @Email NVARCHAR(255),          -- Email
    @SoDienThoai NVARCHAR(20),     -- Số điện thoại
    @TrangThai NVARCHAR(50) = 'Active', -- Trạng thái tài khoản, mặc định là 'Active'
    @NgayTao DATE = NULL           -- Ngày tạo tài khoản, mặc định là NULL, sẽ được gán giá trị sau
AS
BEGIN
    DECLARE @MaVaiTro INT;
    DECLARE @MatKhauMacDinh NVARCHAR(255) = 'NhathuocAnKhang24h'; -- Mật khẩu mặc định

    -- Nếu @NgayTao là NULL, thiết lập giá trị là ngày hiện tại
    IF @NgayTao IS NULL
    BEGIN
        SET @NgayTao = GETDATE();
    END

    -- Tìm mã vai trò cho nhân viên
    SELECT @MaVaiTro = MaVaiTro FROM VaiTro WHERE TenVaiTro = N'Nhân viên';
    
  
    IF @MaVaiTro IS NULL
    BEGIN
        SELECT 'Lỗi: Không tìm thấy vai trò Nhân viên trong hệ thống' AS ThongBao;
        RETURN;
    END

  
    INSERT INTO NguoiDung (TenNguoiDung, Password, Email, SoDienThoai, MaVaiTro, TrangThai, NgayTao)
    VALUES (@TenNguoiDung, dbo.HashPassword(@MatKhauMacDinh), @Email, @SoDienThoai, @MaVaiTro, @TrangThai, @NgayTao);
   
    SELECT 'Tạo tài khoản nhân viên thành công' AS ThongBao;
END
GO

---them vo
CREATE PROCEDURE sp_CapNhatNguoiDungNhanVien 
    @MaNguoiDung INT,                -- Mã người dùng (nhân viên)
    @TenNguoiDung NVARCHAR(255) = NULL,  -- Tên người dùng (tùy chọn)
    @Email NVARCHAR(255) = NULL,         -- Email (tùy chọn)
    @SoDienThoai NVARCHAR(20) = NULL,    -- Số điện thoại (tùy chọn)
    @TrangThai NVARCHAR(50) = NULL       -- Trạng thái (tùy chọn)
AS
BEGIN
    DECLARE @MaVaiTro INT;

    -- Kiểm tra xem người dùng có vai trò là "Nhân viên" hay không
    SELECT @MaVaiTro = MaVaiTro 
    FROM NguoiDung 
    WHERE MaNguoiDung = @MaNguoiDung;

    -- Lấy mã vai trò "Nhân viên"
    IF EXISTS (SELECT 1 FROM VaiTro WHERE TenVaiTro = N'Nhân viên' AND MaVaiTro = @MaVaiTro)
    BEGIN
        -- Cập nhật thông tin người dùng là nhân viên
        UPDATE NguoiDung
        SET 
            TenNguoiDung = ISNULL(@TenNguoiDung, TenNguoiDung),
            Email = ISNULL(@Email, Email),
            SoDienThoai = ISNULL(@SoDienThoai, SoDienThoai),
            TrangThai = ISNULL(@TrangThai, TrangThai)
        WHERE MaNguoiDung = @MaNguoiDung;

        -- Trả về thông báo thành công
        SELECT 'Cập nhật thông tin nhân viên thành công' AS ThongBao;
    END
    ELSE
    BEGIN
        -- Nếu người dùng không có vai trò là "Nhân viên"
        SELECT 'Lỗi: Người dùng không phải là nhân viên hoặc không tồn tại' AS ThongBao;
    END
END
GO
CREATE PROCEDURE sp_XoaNguoiDungNhanVien
    @MaNguoiDung INT
AS
BEGIN
    IF EXISTS (SELECT 1 
               FROM NguoiDung 
               WHERE MaNguoiDung = @MaNguoiDung 
               AND MaVaiTro = 2 
               AND TrangThai = 'Inactive')
    BEGIN
        -- Xóa người dùng thỏa mãn điều kiện
        DELETE FROM NguoiDung
        WHERE MaNguoiDung = @MaNguoiDung;

        
        RETURN 1;
    END
    ELSE
    BEGIN
       
        RETURN 0;
    END
END;
use QL_NhaThuoc
CREATE PROCEDURE sp_ResetMatKhauNguoiDung
    @MaNguoiDung INT,
    @MatKhauMoi NVARCHAR(255) = 'NhathuocAnKhang24h', 
    @MaVaiTro INT = 2 
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra xem người dùng có tồn tại và có vai trò phù hợp hay không
    IF EXISTS (SELECT 1 FROM NguoiDung WHERE MaNguoiDung = @MaNguoiDung AND MaVaiTro = @MaVaiTro)
    BEGIN
        -- Cập nhật mật khẩu người dùng
        UPDATE NguoiDung
        SET Password = dbo.HashPassword(@MatKhauMoi)
        WHERE MaNguoiDung =@MaNguoiDung;

        PRINT 'Reset mật khẩu thành công.';
    END
    ELSE
    BEGIN
        -- Nếu người dùng không tồn tại hoặc không có vai trò phù hợp
        PRINT 'Không thể reset mật khẩu. Có thể vai trò hoặc người dùng không hợp lệ.';
    END
END
