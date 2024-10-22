use QL_NhaThuoc
--Trigger kiểm tra và cập nhật ghi chú thành "Đạt" nếu nhân viên làm đúng hoặc tốt hơn giờ làm việc quy định
CREATE TRIGGER trg_UpdateGhiChuIfOnTime
ON ChamCong
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaNhanVien INT, @MaCaLam INT, @ThoiGianVaoLam DATETIME, @ThoiGianRaVe DATETIME;
    DECLARE @ThoiGianBatDau TIME(7), @ThoiGianKetThuc TIME(7);

    -- Lấy thông tin thời gian vào làm, ra về và mã nhân viên từ bảng ChamCong
    SELECT @MaNhanVien = MaNhanVien, @ThoiGianVaoLam = ThoiGianVaoLam, @ThoiGianRaVe = ThoiGianRaVe
    FROM inserted;

    -- Lấy mã ca làm việc của nhân viên từ bảng NhanVien
    SELECT @MaCaLam = MaCaLamViec
    FROM NhanVien
    WHERE MaNhanVien = @MaNhanVien;

    -- Kiểm tra nếu nhân viên có ca làm việc
    IF @MaCaLam IS NOT NULL
    BEGIN
        -- Lấy thời gian bắt đầu và kết thúc của ca làm việc từ bảng CaLamViec
        SELECT @ThoiGianBatDau = ThoiGianBatDau, @ThoiGianKetThuc = ThoiGianKetThuc
        FROM CaLamViec
        WHERE MaCaLam = @MaCaLam;

        -- Kiểm tra điều kiện:
        -- - Thời gian vào làm <= 10 phút trước hoặc đúng giờ bắt đầu ca làm việc
        -- - Thời gian ra về >= hoặc đúng giờ kết thúc ca làm việc
        IF (@ThoiGianVaoLam <= DATEADD(MINUTE, -10, CAST(@ThoiGianBatDau AS DATETIME)) OR @ThoiGianVaoLam = CAST(@ThoiGianBatDau AS DATETIME))
           AND (@ThoiGianRaVe >= CAST(@ThoiGianKetThuc AS DATETIME))
        BEGIN
            -- Cập nhật ghi chú thành "Đạt"
            UPDATE ChamCong
            SET GhiChu = N'Đạt'
            WHERE MaNhanVien = @MaNhanVien
              AND ThoiGianVaoLam = @ThoiGianVaoLam;
        END
    END
END;

---tinh luong
--CREATE TRIGGER trg_CalculateLuongThucNhan
--ON Luong
--AFTER INSERT, UPDATE
--AS
--BEGIN
--    SET NOCOUNT ON;

--    -- Bảng tạm để lưu kết quả tính toán
--    DECLARE @LuongTinh TABLE (
--        MaLuong INT,
--        SoCaLamViec INT,
--        LuongThucNhan DECIMAL(18,2)
--    );

--    -- Tính toán SoCaLamViec và LuongThucNhan cho mỗi bản ghi được thêm hoặc cập nhật
--    INSERT INTO @LuongTinh (MaLuong, SoCaLamViec, LuongThucNhan)
--    SELECT 
--        I.MaLuong,
--        ISNULL(CC.SoCaLamViec, 0) AS SoCaLamViec,
--        (NV.LuongCoBan1Ca * ISNULL(CC.SoCaLamViec, 0)) + ISNULL(I.LuongThuong, 0) - ISNULL(I.KhauTru, 0) AS LuongThucNhan
--    FROM inserted I
--    INNER JOIN NhanVien NV ON I.MaNhanVien = NV.MaNhanVien
--    OUTER APPLY (
--        SELECT COUNT(*) AS SoCaLamViec
--        FROM ChamCong CC
--        WHERE CC.MaNhanVien = I.MaNhanVien
--          AND CC.GhiChu = N'Đạt'
--          AND YEAR(CC.NgayChamCong) = YEAR(I.LuongThang)
--          AND MONTH(CC.NgayChamCong) = MONTH(I.LuongThang)
--    ) CC;

--    -- Cập nhật SoCaLamViec và LuongThucNhan trong bảng Luong
--    UPDATE L
--    SET 
--        L.SoCaLamViec = T.SoCaLamViec,
--        L.LuongThucNhan = T.LuongThucNhan
--    FROM Luong L
--    INNER JOIN @LuongTinh T ON L.MaLuong = T.MaLuong;
--END;
------ bảng người dùng

--CREATE TRIGGER trg_PreventDeleteActiveUser
--ON NguoiDung
--INSTEAD OF DELETE
--AS
--BEGIN
--    SET NOCOUNT ON;

--    -- Không cho phép xóa người dùng có trạng thái là 'Active'
--    IF EXISTS (
--        SELECT 1 
--        FROM deleted 
--        WHERE TrangThai = 'Active'
--    )
--    BEGIN
--        RAISERROR('Không thể xóa người dùng có trạng thái "Active".', 16, 1);
--        RETURN;
--    END

--    -- Thực hiện xóa nếu không có người dùng "Active"
--    DELETE FROM NguoiDung
--    WHERE MaNguoiDung IN (SELECT MaNguoiDung FROM deleted);
--END;

--CREATE TRIGGER trg_SetNgayTao
--ON NguoiDung
--AFTER INSERT
--AS
--BEGIN
--    SET NOCOUNT ON;

--    -- Cập nhật cột NgayTao với ngày hiện tại sau khi thêm mới
--    UPDATE NguoiDung
--    SET NgayTao = GETDATE()
--    FROM inserted i
--    WHERE NguoiDung.MaNguoiDung = i.MaNguoiDung;
--END;

----- bảng thanh toán
--CREATE TRIGGER trg_UpdateDiemKhachHang
--ON ThanhToan
--AFTER INSERT, UPDATE
--AS
--BEGIN
--    SET NOCOUNT ON;

--    -- Chỉ xử lý khi trạng thái thanh toán là "Thành công"
--    UPDATE KhachHang
--    SET Diem = Diem + CAST(dh.TongTien / 100 AS INT)
--    FROM KhachHang kh
--    INNER JOIN DonHang dh ON dh.MaDonHang = inserted.MaDonHang
--    INNER JOIN inserted ON inserted.MaDonHang = dh.MaDonHang
--    WHERE inserted.TrangThaiThanhToan = N'Thành công'
--    AND kh.MaKhachHang = (
--        SELECT MaKhachHang FROM DonHang WHERE MaDonHang = inserted.MaDonHang
--    );
--END;

----Trigger cập nhật TrangThai của NguoiDung khi NhanVien hoặc KhachHang bị xóa
--CREATE TRIGGER trg_DeleteNhanVien
--ON NhanVien
--AFTER DELETE
--AS
--BEGIN
--    DECLARE @MaNguoiDung INT;
    
--    SELECT @MaNguoiDung = d.MaNguoiDung
--    FROM DELETED d;

--    -- Cập nhật trạng thái người dùng thành 'Inactive' khi nhân viên bị xóa
--    UPDATE NguoiDung
--    SET TrangThai = 'Inactive'
--    WHERE MaNguoiDung = @MaNguoiDung;
--END
--GO
CREATE TRIGGER trg_DeleteKhachHang
ON KhachHang
AFTER DELETE
AS
BEGIN
    DECLARE @MaNguoiDung INT;
    
    SELECT @MaNguoiDung = d.MaNguoiDung
    FROM DELETED d;

    -- Cập nhật trạng thái người dùng thành 'Inactive' khi khách hàng bị xóa
    UPDATE NguoiDung
    SET TrangThai = 'Inactive'
    WHERE MaNguoiDung = @MaNguoiDung;
END
GO
---trigger nguoi dung
CREATE TRIGGER trg_UpdateNgayTaoNguoiDung
ON NguoiDung
AFTER UPDATE
AS
BEGIN
    DECLARE @MaNguoiDung INT;
    
    SELECT @MaNguoiDung = i.MaNguoiDung
    FROM INSERTED i;

    -- Cập nhật ngày tạo thành ngày hiện tại nếu có thay đổi thông tin
    UPDATE NguoiDung
    SET NgayTao = GETDATE()
    WHERE MaNguoiDung = @MaNguoiDung;
END
GO

