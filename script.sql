USE [QL_NhaThuoc]
GO
/****** Object:  User [Admin]    Script Date: 10/18/2024 11:41:55 PM ******/
CREATE USER [Admin] FOR LOGIN [Admin] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_KiemTraChiTietDonHang]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_KiemTraChiTietDonHang] (@MaChiTiet INT)
RETURNS BIT
AS
BEGIN
    DECLARE @Valid BIT;
    SELECT @Valid = CASE 
                    WHEN (SoLuong > 0 AND Gia > 0) 
                    THEN 1 
                    ELSE 0 
                    END
    FROM ChiTietDonHang
    WHERE MaChiTiet = @MaChiTiet;
    
    RETURN @Valid;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_KiemTraPhanQuyen]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_KiemTraPhanQuyen] (@MaVaiTro INT, @MaQuyen INT)
RETURNS BIT
AS
BEGIN
    DECLARE @HasAccess BIT;
    SELECT @HasAccess = CASE 
                        WHEN EXISTS (SELECT 1 FROM PhanQuyen WHERE MaVaiTro = @MaVaiTro AND MaQuyen = @MaQuyen) 
                        THEN 1 
                        ELSE 0 
                        END;
    RETURN @HasAccess;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_KiemTraTrangThaiThanhToan]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_KiemTraTrangThaiThanhToan] (@MaDonHang INT)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @TrangThai NVARCHAR(50);
    SELECT @TrangThai = CASE 
                        WHEN EXISTS (SELECT 1 FROM ThanhToan WHERE MaDonHang = @MaDonHang AND TrangThaiThanhToan = 'Đã thanh toán') 
                        THEN 'Đã thanh toán' 
                        ELSE 'Chưa thanh toán' 
                        END;
    RETURN @TrangThai;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_LayTenQuyen]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_LayTenQuyen] (@MaQuyen INT)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @TenQuyen NVARCHAR(50);
    SELECT @TenQuyen = TenQuyen
    FROM QuyenTruyCap
    WHERE MaQuyen = @MaQuyen;
    
    RETURN @TenQuyen;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_LayTenVaiTro]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_LayTenVaiTro] (@MaVaiTro INT)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @TenVaiTro NVARCHAR(50);
    SELECT @TenVaiTro = TenVaiTro
    FROM VaiTro
    WHERE MaVaiTro = @MaVaiTro;
    
    RETURN @TenVaiTro;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_PhanTramKhauTru]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Trả về phần trăm khấu trừ cho một phiếu nhập dựa trên tổng số lượng hàng nhập.
CREATE FUNCTION [dbo].[fn_PhanTramKhauTru]
(
    @MaPhieuNhap INT
)
RETURNS DECIMAL(5, 2)
AS
BEGIN
    DECLARE @TongSoLuong INT, @PhanTramKhauTru DECIMAL(5, 2);

    SELECT @TongSoLuong = SUM(SoLuong)
    FROM ChiTietPhieuNhap
    WHERE MaPhieuNhap = @MaPhieuNhap;

    IF @TongSoLuong > 1000
        SET @PhanTramKhauTru = 10.0; 
    ELSE
        SET @PhanTramKhauTru = 5.0;  

    RETURN @PhanTramKhauTru;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_SoLuongTonKho]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Trả về số lượng hiện tại của một sản phẩm trong kho
CREATE FUNCTION [dbo].[fn_SoLuongTonKho]
(
    @MaThuoc INT
)
RETURNS INT
AS
BEGIN
    DECLARE @SoLuongTon INT;

    SELECT @SoLuongTon = SoLuongHienTai
    FROM TonKho
    WHERE MaThuoc = @MaThuoc;

    RETURN @SoLuongTon;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ThuocHetHan]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Trả về danh sách các thuốc có hạn sử dụng trước ngày hiện tại.
CREATE FUNCTION [dbo].[fn_ThuocHetHan]
()
RETURNS @ThuocHetHan TABLE
(
    MaThuoc INT,
    TenThuoc NVARCHAR(255),
    HanSuDung DATE
)
AS
BEGIN
    INSERT INTO @ThuocHetHan
    SELECT MaThuoc, TenThuoc, HanSuDung
    FROM Thuoc
    WHERE HanSuDung < GETDATE();

    RETURN;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_TinhTongGiaTriGioHang]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_TinhTongGiaTriGioHang] (@MaGioHang INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TongGiaTri DECIMAL(10, 2);
    SELECT @TongGiaTri = SUM(SoLuong * DonGia)
    FROM GioHang
    WHERE MaGioHang = @MaGioHang;
    
    RETURN @TongGiaTri;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_TinhTongSoLuongSanPham]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_TinhTongSoLuongSanPham] (@MaDonHang INT)
RETURNS INT
AS
BEGIN
    DECLARE @TongSoLuong INT;
    SELECT @TongSoLuong = SUM(SoLuong)
    FROM ChiTietDonHang
    WHERE MaDonHang = @MaDonHang;
    
    RETURN @TongSoLuong;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_TinhTongTienDonHang]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_TinhTongTienDonHang] (@MaDonHang INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TongTien DECIMAL(10, 2);
    SELECT @TongTien = SUM(c.SoLuong * c.Gia)
    FROM ChiTietDonHang c
    WHERE c.MaDonHang = @MaDonHang;
    
    RETURN @TongTien;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_TongTienPhieuNhap]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_TongTienPhieuNhap]
(
    @MaPhieuNhap INT
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @TongTien DECIMAL(18, 2);

    SELECT @TongTien = SUM(SoLuong * DonGia)
    FROM ChiTietPhieuNhap
    WHERE MaPhieuNhap = @MaPhieuNhap;

    RETURN @TongTien;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_TongTienPhieuXuat]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fn_TongTienPhieuXuat]
(
    @MaPhieuXuat INT
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @TongTien DECIMAL(18, 2);

    SELECT @TongTien = SUM(SoLuong * DonGia)
    FROM ChiTietPhieuXuat
    WHERE MaPhieuXuat = @MaPhieuXuat;

    RETURN @TongTien;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_TrangThaiTonKho]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Trả về trạng thái "Cảnh báo" nếu số lượng tồn dưới mức cảnh báo, hoặc "Bình thường" nếu không.
CREATE FUNCTION [dbo].[fn_TrangThaiTonKho]
(
    @MaThuoc INT
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @SoLuongTon INT, @SoLuongCanhBao INT, @TrangThai NVARCHAR(50);

    SELECT @SoLuongTon = SoLuongHienTai, @SoLuongCanhBao = SoLuongCanhBao
    FROM TonKho
    WHERE MaThuoc = @MaThuoc;

    IF @SoLuongTon < @SoLuongCanhBao
        SET @TrangThai = N'Cảnh báo';
    ELSE
        SET @TrangThai = N'Bình thường';

    RETURN @TrangThai;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[HashPassword]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[HashPassword](@Password NVARCHAR(255))
RETURNS NVARCHAR(64)
AS
BEGIN
    RETURN CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', @Password), 2);
END
GO
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__EFMigrationsHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CaLamViec]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CaLamViec](
	[MaCaLam] [int] IDENTITY(1,1) NOT NULL,
	[ThoiGianBatDau] [time](7) NULL,
	[ThoiGianKetThuc] [time](7) NULL,
	[ThoiGianTao] [date] NULL,
	[GhiChuCongViec] [nvarchar](max) NULL,
	[GioNghiTrua] [time](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaCaLam] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ChamCong]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChamCong](
	[MaChamCong] [int] IDENTITY(1,1) NOT NULL,
	[MaNhanVien] [int] NOT NULL,
	[ThoiGianVaoLam] [datetime] NULL,
	[ThoiGianRaVe] [datetime] NULL,
	[NgayChamCong] [date] NOT NULL,
	[GhiChu] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK__ChamCong__307331A15F10C452] PRIMARY KEY CLUSTERED 
(
	[MaChamCong] ASC,
	[MaNhanVien] ASC,
	[NgayChamCong] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ChiTietDonHang]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChiTietDonHang](
	[MaChiTiet] [int] IDENTITY(1,1) NOT NULL,
	[MaDonHang] [int] NOT NULL,
	[SoLuong] [int] NOT NULL,
	[MaThuoc] [int] NOT NULL,
	[Gia] [decimal](18, 0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MaChiTiet] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ChiTietPN]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChiTietPN](
	[MaChiTietPN] [int] IDENTITY(1,1) NOT NULL,
	[MaThuoc] [int] NOT NULL,
	[SoLuong] [int] NOT NULL,
	[DonGiaXuat] [decimal](18, 0) NOT NULL,
	[MaTonKho] [int] NOT NULL,
	[MaPhieuNhap] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MaChiTietPN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_ChiTietPN_MaThuoc_MaPhieuNhap] UNIQUE NONCLUSTERED 
(
	[MaThuoc] ASC,
	[MaPhieuNhap] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ChiTietPX]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChiTietPX](
	[MaChiTietPX] [int] IDENTITY(1,1) NOT NULL,
	[MaPhieuXuat] [int] NOT NULL,
	[DonGiaXuat] [decimal](18, 0) NOT NULL,
	[SoLuong] [int] NOT NULL,
	[MaTonKho] [int] NOT NULL,
	[DonVi] [nvarchar](10) NOT NULL,
	[MaThuoc] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MaChiTietPX] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_ChiTietPX_MaThuoc_MaPhieuXuat] UNIQUE NONCLUSTERED 
(
	[MaThuoc] ASC,
	[MaPhieuXuat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DonHang]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DonHang](
	[MaDonHang] [int] IDENTITY(1,1) NOT NULL,
	[TongTien] [decimal](10, 2) NOT NULL,
	[GhiChu] [nvarchar](max) NULL,
	[NgayDatHang] [date] NOT NULL,
	[NgayCapNhat] [date] NULL,
	[DiaChi] [nvarchar](255) NOT NULL,
	[NgayGiaoHang] [date] NOT NULL,
	[TrangThai] [nvarchar](50) NOT NULL,
	[MaNhanVien] [int] NOT NULL,
	[MaKhachHang] [int] NOT NULL,
 CONSTRAINT [PK__DonHang__129584AD8F05CCBB] PRIMARY KEY CLUSTERED 
(
	[MaDonHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FAQ]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FAQ](
	[MaCauHoi] [int] NOT NULL,
	[CauHoiThuongGap] [nvarchar](max) NULL,
	[CauTraLoiTuongUng] [nvarchar](max) NULL,
	[DanhMucCauHoi] [nvarchar](255) NULL,
	[NgayTaoCauHoi] [date] NULL,
	[NgayCapNhatCauHoi] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaCauHoi] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GioHang]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GioHang](
	[MaGioHang] [int] IDENTITY(1,1) NOT NULL,
	[SoLuong] [int] NOT NULL,
	[DonGia] [decimal](18, 0) NOT NULL,
	[TongTien] [decimal](18, 0) NOT NULL,
	[MaThuoc] [int] NOT NULL,
	[DonVi] [nvarchar](10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MaGioHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HinhAnh]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HinhAnh](
	[MaHinh] [int] IDENTITY(1,1) NOT NULL,
	[UrlAnh] [nvarchar](max) NULL,
	[MaThuoc] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaHinh] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KhachHang]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KhachHang](
	[MaKhachHang] [int] NOT NULL,
	[TenKhachHang] [nvarchar](255) NOT NULL,
	[GioiTinh] [nvarchar](10) NOT NULL,
	[DiaChi] [nvarchar](255) NOT NULL,
	[NgaySinh] [date] NOT NULL,
	[SoDienThoai] [nvarchar](20) NOT NULL,
	[MaNguoiDung] [int] NULL,
	[Diem] [int] NOT NULL,
 CONSTRAINT [PK__KhachHan__88D2F0E5FB3D1819] PRIMARY KEY CLUSTERED 
(
	[MaKhachHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LoaiSanPham]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoaiSanPham](
	[MaLoaiSanPham] [int] IDENTITY(1,1) NOT NULL,
	[TenLoai] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaLoaiSanPham] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Luong]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Luong](
	[MaLuong] [int] IDENTITY(1,1) NOT NULL,
	[MaNhanVien] [int] NOT NULL,
	[KhauTru] [decimal](15, 2) NOT NULL,
	[LuongThucNhan] [decimal](15, 2) NOT NULL,
	[NgayTraLuong] [date] NOT NULL,
	[GhiChu] [nvarchar](255) NOT NULL,
	[SoCaLamViec] [int] NOT NULL,
	[LuongThang] [date] NOT NULL,
	[LuongThuong] [decimal](18, 0) NULL,
 CONSTRAINT [PK__Luong__6609A48DBF719780] PRIMARY KEY CLUSTERED 
(
	[MaLuong] ASC,
	[MaNhanVien] ASC,
	[LuongThang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NguoiDung]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NguoiDung](
	[MaNguoiDung] [int] IDENTITY(1,1) NOT NULL,
	[TenNguoiDung] [nvarchar](255) NOT NULL,
	[Password] [nvarchar](255) NOT NULL,
	[Email] [nvarchar](255) NOT NULL,
	[SoDienThoai] [nvarchar](20) NOT NULL,
	[MaVaiTro] [int] NOT NULL,
	[TrangThai] [nvarchar](50) NOT NULL,
	[NgayTao] [date] NOT NULL,
 CONSTRAINT [PK__NguoiDun__C539D7625E27EED9] PRIMARY KEY CLUSTERED 
(
	[MaNguoiDung] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NhanVien]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NhanVien](
	[MaNhanVien] [int] IDENTITY(1,1) NOT NULL,
	[Ho] [nvarchar](50) NOT NULL,
	[Ten] [nvarchar](50) NOT NULL,
	[NgaySinh] [date] NOT NULL,
	[GioiTinh] [nvarchar](10) NOT NULL,
	[DiaChi] [nvarchar](255) NOT NULL,
	[ChucVu] [nvarchar](50) NOT NULL,
	[NgayTuyenDung] [date] NOT NULL,
	[TrangThai] [nvarchar](50) NOT NULL,
	[MaNguoiDung] [int] NULL,
	[MaCaLamViec] [int] NOT NULL,
	[LuongCoBan1Ca] [decimal](18, 0) NULL,
	[LuongTangCa1Gio] [decimal](18, 0) NULL,
 CONSTRAINT [PK__NhanVien__77B2CA472CF2237E] PRIMARY KEY CLUSTERED 
(
	[MaNhanVien] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PhanQuyen]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PhanQuyen](
	[MaVaiTro] [int] NULL,
	[MaQuyen] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PhieuNhap]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PhieuNhap](
	[MaPhieuNhap] [int] IDENTITY(1,1) NOT NULL,
	[MaNhanVien] [int] NOT NULL,
	[TongTien] [decimal](18, 0) NOT NULL,
	[NgayNhap] [date] NULL,
	[GhiChu] [nvarchar](10) NULL,
	[NhaCungCap] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MaPhieuNhap] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_PhieuNhap_MaPhieuNhap] UNIQUE NONCLUSTERED 
(
	[MaPhieuNhap] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PhieuXuat]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PhieuXuat](
	[MaPhieuXuat] [int] IDENTITY(1,1) NOT NULL,
	[NgayXuat] [date] NULL,
	[MaNhanVien] [int] NOT NULL,
	[TongTien] [decimal](18, 0) NOT NULL,
	[GhiChu] [nvarchar](255) NULL,
	[NoiNhan] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaPhieuXuat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_PhieuXuat_MaPhieuXuat] UNIQUE NONCLUSTERED 
(
	[MaPhieuXuat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[QuyenTruyCap]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuyenTruyCap](
	[MaQuyen] [int] IDENTITY(1,1) NOT NULL,
	[TenQuyen] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MaQuyen] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SaoLuuVaPhucHoi]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SaoLuuVaPhucHoi](
	[MaSaoLuu] [int] IDENTITY(1,1) NOT NULL,
	[MaNhanVien] [int] NULL,
	[ThoiGianSaoLuu] [datetime] NULL,
	[ThoiGianPhucHoi] [datetime] NULL,
	[TrangThaiSaoLuu] [nvarchar](50) NULL,
	[DiaChi] [nvarchar](255) NULL,
	[TenFileSaoLuu] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaSaoLuu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ThanhToan]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ThanhToan](
	[MaThanhToan] [int] IDENTITY(1,1) NOT NULL,
	[MaDonHang] [int] NOT NULL,
	[PhuongThucThanhToan] [nvarchar](50) NOT NULL,
	[TrangThaiThanhToan] [nvarchar](50) NOT NULL,
	[NgayThanhToan] [date] NULL,
	[SoTien] [decimal](15, 2) NOT NULL,
	[MaQR] [nvarchar](255) NULL,
	[GhiChu] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaThanhToan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Thuoc]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Thuoc](
	[MaThuoc] [int] IDENTITY(1,1) NOT NULL,
	[TenThuoc] [nvarchar](255) NULL,
	[HanSuDung] [date] NULL,
	[DonGia] [decimal](18, 0) NOT NULL,
	[SoLuongTon] [int] NULL,
	[MaLoaiSanPham] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaThuoc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Thuoc_MaThuoc] UNIQUE NONCLUSTERED 
(
	[MaThuoc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TonKho]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TonKho](
	[MaTonKho] [int] IDENTITY(1,1) NOT NULL,
	[SoLuongTon] [int] NOT NULL,
	[SoLuongCanhBao] [int] NOT NULL,
	[SoLuongHienTai] [int] NOT NULL,
	[SoLuongToiDa] [int] NOT NULL,
	[TrangThai] [nvarchar](50) NULL,
	[NgayGioCapNhat] [datetime] NULL,
	[MaThuoc] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MaTonKho] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VaiTro]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VaiTro](
	[MaVaiTro] [int] IDENTITY(1,1) NOT NULL,
	[TenVaiTro] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MaVaiTro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CaLamViec] ADD  DEFAULT (getdate()) FOR [ThoiGianTao]
GO
ALTER TABLE [dbo].[ChamCong] ADD  CONSTRAINT [DF__ChamCong__NgayCh__7E37BEF6]  DEFAULT (getdate()) FOR [NgayChamCong]
GO
ALTER TABLE [dbo].[ChamCong] ADD  CONSTRAINT [DF_ChamCong_GhiChu]  DEFAULT (N'Không Đạt') FOR [GhiChu]
GO
ALTER TABLE [dbo].[DonHang] ADD  CONSTRAINT [DF__DonHang__NgayDat__4BAC3F29]  DEFAULT (getdate()) FOR [NgayDatHang]
GO
ALTER TABLE [dbo].[DonHang] ADD  CONSTRAINT [DF__DonHang__NgayCap__4CA06362]  DEFAULT (NULL) FOR [NgayCapNhat]
GO
ALTER TABLE [dbo].[DonHang] ADD  CONSTRAINT [DF__DonHang__NgayGia__4D94879B]  DEFAULT (NULL) FOR [NgayGiaoHang]
GO
ALTER TABLE [dbo].[FAQ] ADD  DEFAULT (getdate()) FOR [NgayTaoCauHoi]
GO
ALTER TABLE [dbo].[FAQ] ADD  DEFAULT (NULL) FOR [NgayCapNhatCauHoi]
GO
ALTER TABLE [dbo].[KhachHang] ADD  CONSTRAINT [DF_KhachHang_Diem]  DEFAULT ((0)) FOR [Diem]
GO
ALTER TABLE [dbo].[Luong] ADD  CONSTRAINT [DF__Luong__NgayTraLu__02084FDA]  DEFAULT (getdate()) FOR [NgayTraLuong]
GO
ALTER TABLE [dbo].[NguoiDung] ADD  CONSTRAINT [DF__NguoiDung__NgayT__3D5E1FD2]  DEFAULT (getdate()) FOR [NgayTao]
GO
ALTER TABLE [dbo].[NhanVien] ADD  CONSTRAINT [DF__NhanVien__NgayTu__46E78A0C]  DEFAULT (getdate()) FOR [NgayTuyenDung]
GO
ALTER TABLE [dbo].[PhieuNhap] ADD  DEFAULT (getdate()) FOR [NgayNhap]
GO
ALTER TABLE [dbo].[PhieuXuat] ADD  DEFAULT (getdate()) FOR [NgayXuat]
GO
ALTER TABLE [dbo].[SaoLuuVaPhucHoi] ADD  DEFAULT (getdate()) FOR [ThoiGianSaoLuu]
GO
ALTER TABLE [dbo].[ThanhToan] ADD  DEFAULT (getdate()) FOR [NgayThanhToan]
GO
ALTER TABLE [dbo].[Thuoc] ADD  CONSTRAINT [DF_Thuoc_SoLuongTon]  DEFAULT ((0)) FOR [SoLuongTon]
GO
ALTER TABLE [dbo].[TonKho] ADD  DEFAULT (getdate()) FOR [NgayGioCapNhat]
GO
ALTER TABLE [dbo].[ChamCong]  WITH CHECK ADD  CONSTRAINT [FK_ChamCong_NhanVien] FOREIGN KEY([MaNhanVien])
REFERENCES [dbo].[NhanVien] ([MaNhanVien])
GO
ALTER TABLE [dbo].[ChamCong] CHECK CONSTRAINT [FK_ChamCong_NhanVien]
GO
ALTER TABLE [dbo].[ChiTietDonHang]  WITH CHECK ADD  CONSTRAINT [FK_ChiTietDonHang_MaDonHang] FOREIGN KEY([MaDonHang])
REFERENCES [dbo].[DonHang] ([MaDonHang])
GO
ALTER TABLE [dbo].[ChiTietDonHang] CHECK CONSTRAINT [FK_ChiTietDonHang_MaDonHang]
GO
ALTER TABLE [dbo].[ChiTietDonHang]  WITH CHECK ADD  CONSTRAINT [FK_ChiTietDonHang_MaThuoc] FOREIGN KEY([MaThuoc])
REFERENCES [dbo].[Thuoc] ([MaThuoc])
GO
ALTER TABLE [dbo].[ChiTietDonHang] CHECK CONSTRAINT [FK_ChiTietDonHang_MaThuoc]
GO
ALTER TABLE [dbo].[ChiTietPN]  WITH CHECK ADD  CONSTRAINT [FK_ChiTietPN_MaPhieuNhap] FOREIGN KEY([MaPhieuNhap])
REFERENCES [dbo].[PhieuNhap] ([MaPhieuNhap])
GO
ALTER TABLE [dbo].[ChiTietPN] CHECK CONSTRAINT [FK_ChiTietPN_MaPhieuNhap]
GO
ALTER TABLE [dbo].[ChiTietPN]  WITH CHECK ADD  CONSTRAINT [FK_ChiTietPN_MaThuoc] FOREIGN KEY([MaThuoc])
REFERENCES [dbo].[Thuoc] ([MaThuoc])
GO
ALTER TABLE [dbo].[ChiTietPN] CHECK CONSTRAINT [FK_ChiTietPN_MaThuoc]
GO
ALTER TABLE [dbo].[ChiTietPN]  WITH CHECK ADD  CONSTRAINT [FK_ChiTietPN_MaTonKho] FOREIGN KEY([MaTonKho])
REFERENCES [dbo].[TonKho] ([MaTonKho])
GO
ALTER TABLE [dbo].[ChiTietPN] CHECK CONSTRAINT [FK_ChiTietPN_MaTonKho]
GO
ALTER TABLE [dbo].[ChiTietPX]  WITH CHECK ADD  CONSTRAINT [FK_ChiTietPX_MaPhieuXuat] FOREIGN KEY([MaPhieuXuat])
REFERENCES [dbo].[PhieuXuat] ([MaPhieuXuat])
GO
ALTER TABLE [dbo].[ChiTietPX] CHECK CONSTRAINT [FK_ChiTietPX_MaPhieuXuat]
GO
ALTER TABLE [dbo].[ChiTietPX]  WITH CHECK ADD  CONSTRAINT [FK_ChiTietPX_MaThuoc] FOREIGN KEY([MaThuoc])
REFERENCES [dbo].[Thuoc] ([MaThuoc])
GO
ALTER TABLE [dbo].[ChiTietPX] CHECK CONSTRAINT [FK_ChiTietPX_MaThuoc]
GO
ALTER TABLE [dbo].[ChiTietPX]  WITH CHECK ADD  CONSTRAINT [FK_ChiTietPX_MaTonKho] FOREIGN KEY([MaTonKho])
REFERENCES [dbo].[TonKho] ([MaTonKho])
GO
ALTER TABLE [dbo].[ChiTietPX] CHECK CONSTRAINT [FK_ChiTietPX_MaTonKho]
GO
ALTER TABLE [dbo].[DonHang]  WITH CHECK ADD  CONSTRAINT [FK_DonHang_KhachHang] FOREIGN KEY([MaKhachHang])
REFERENCES [dbo].[KhachHang] ([MaKhachHang])
GO
ALTER TABLE [dbo].[DonHang] CHECK CONSTRAINT [FK_DonHang_KhachHang]
GO
ALTER TABLE [dbo].[DonHang]  WITH CHECK ADD  CONSTRAINT [FK_DonHang_MaNhanVien] FOREIGN KEY([MaNhanVien])
REFERENCES [dbo].[NhanVien] ([MaNhanVien])
GO
ALTER TABLE [dbo].[DonHang] CHECK CONSTRAINT [FK_DonHang_MaNhanVien]
GO
ALTER TABLE [dbo].[GioHang]  WITH CHECK ADD  CONSTRAINT [FK_GioHang_MaThuoc] FOREIGN KEY([MaThuoc])
REFERENCES [dbo].[Thuoc] ([MaThuoc])
GO
ALTER TABLE [dbo].[GioHang] CHECK CONSTRAINT [FK_GioHang_MaThuoc]
GO
ALTER TABLE [dbo].[HinhAnh]  WITH CHECK ADD  CONSTRAINT [FK_HinhAnh_MaThuoc] FOREIGN KEY([MaThuoc])
REFERENCES [dbo].[Thuoc] ([MaThuoc])
GO
ALTER TABLE [dbo].[HinhAnh] CHECK CONSTRAINT [FK_HinhAnh_MaThuoc]
GO
ALTER TABLE [dbo].[KhachHang]  WITH CHECK ADD  CONSTRAINT [FK_KhachHang_MaNguoiDung] FOREIGN KEY([MaNguoiDung])
REFERENCES [dbo].[NguoiDung] ([MaNguoiDung])
GO
ALTER TABLE [dbo].[KhachHang] CHECK CONSTRAINT [FK_KhachHang_MaNguoiDung]
GO
ALTER TABLE [dbo].[Luong]  WITH CHECK ADD  CONSTRAINT [FK_Luong_MaNhanVien] FOREIGN KEY([MaNhanVien])
REFERENCES [dbo].[NhanVien] ([MaNhanVien])
GO
ALTER TABLE [dbo].[Luong] CHECK CONSTRAINT [FK_Luong_MaNhanVien]
GO
ALTER TABLE [dbo].[NguoiDung]  WITH CHECK ADD  CONSTRAINT [FK_NguoiDung_MaVaiTro] FOREIGN KEY([MaVaiTro])
REFERENCES [dbo].[VaiTro] ([MaVaiTro])
GO
ALTER TABLE [dbo].[NguoiDung] CHECK CONSTRAINT [FK_NguoiDung_MaVaiTro]
GO
ALTER TABLE [dbo].[NhanVien]  WITH CHECK ADD  CONSTRAINT [FK_NhanVien_MaCaLamViec] FOREIGN KEY([MaCaLamViec])
REFERENCES [dbo].[CaLamViec] ([MaCaLam])
GO
ALTER TABLE [dbo].[NhanVien] CHECK CONSTRAINT [FK_NhanVien_MaCaLamViec]
GO
ALTER TABLE [dbo].[NhanVien]  WITH CHECK ADD  CONSTRAINT [FK_NhanVien_MaNguoiDung] FOREIGN KEY([MaNguoiDung])
REFERENCES [dbo].[NguoiDung] ([MaNguoiDung])
GO
ALTER TABLE [dbo].[NhanVien] CHECK CONSTRAINT [FK_NhanVien_MaNguoiDung]
GO
ALTER TABLE [dbo].[PhanQuyen]  WITH CHECK ADD  CONSTRAINT [FK_PhanQuyen_Quyen] FOREIGN KEY([MaQuyen])
REFERENCES [dbo].[QuyenTruyCap] ([MaQuyen])
GO
ALTER TABLE [dbo].[PhanQuyen] CHECK CONSTRAINT [FK_PhanQuyen_Quyen]
GO
ALTER TABLE [dbo].[PhanQuyen]  WITH CHECK ADD  CONSTRAINT [FK_PhanQuyen_VaiTro] FOREIGN KEY([MaVaiTro])
REFERENCES [dbo].[VaiTro] ([MaVaiTro])
GO
ALTER TABLE [dbo].[PhanQuyen] CHECK CONSTRAINT [FK_PhanQuyen_VaiTro]
GO
ALTER TABLE [dbo].[PhieuNhap]  WITH CHECK ADD  CONSTRAINT [FK_PhieuNhap_MaNhanVien] FOREIGN KEY([MaNhanVien])
REFERENCES [dbo].[NhanVien] ([MaNhanVien])
GO
ALTER TABLE [dbo].[PhieuNhap] CHECK CONSTRAINT [FK_PhieuNhap_MaNhanVien]
GO
ALTER TABLE [dbo].[PhieuXuat]  WITH CHECK ADD  CONSTRAINT [FK_PhieuXuat_MaNhanVien] FOREIGN KEY([MaNhanVien])
REFERENCES [dbo].[NhanVien] ([MaNhanVien])
GO
ALTER TABLE [dbo].[PhieuXuat] CHECK CONSTRAINT [FK_PhieuXuat_MaNhanVien]
GO
ALTER TABLE [dbo].[SaoLuuVaPhucHoi]  WITH CHECK ADD  CONSTRAINT [FK_SaoLuuVaPhucHoi_MaNhanVien] FOREIGN KEY([MaNhanVien])
REFERENCES [dbo].[NhanVien] ([MaNhanVien])
GO
ALTER TABLE [dbo].[SaoLuuVaPhucHoi] CHECK CONSTRAINT [FK_SaoLuuVaPhucHoi_MaNhanVien]
GO
ALTER TABLE [dbo].[ThanhToan]  WITH CHECK ADD  CONSTRAINT [FK_ThanhToan_MaDonHang] FOREIGN KEY([MaDonHang])
REFERENCES [dbo].[DonHang] ([MaDonHang])
GO
ALTER TABLE [dbo].[ThanhToan] CHECK CONSTRAINT [FK_ThanhToan_MaDonHang]
GO
ALTER TABLE [dbo].[Thuoc]  WITH CHECK ADD  CONSTRAINT [FK_Thuoc_MaLoaiSanPham] FOREIGN KEY([MaLoaiSanPham])
REFERENCES [dbo].[LoaiSanPham] ([MaLoaiSanPham])
GO
ALTER TABLE [dbo].[Thuoc] CHECK CONSTRAINT [FK_Thuoc_MaLoaiSanPham]
GO
ALTER TABLE [dbo].[TonKho]  WITH CHECK ADD  CONSTRAINT [FK_TonKho_MaThuoc] FOREIGN KEY([MaThuoc])
REFERENCES [dbo].[Thuoc] ([MaThuoc])
GO
ALTER TABLE [dbo].[TonKho] CHECK CONSTRAINT [FK_TonKho_MaThuoc]
GO
ALTER TABLE [dbo].[CaLamViec]  WITH CHECK ADD  CONSTRAINT [CK_CaLamViec_GioNghiTrua] CHECK  (([GioNghiTrua] IS NULL OR [GioNghiTrua]>[ThoiGianBatDau] AND [GioNghiTrua]<[ThoiGianKetThuc]))
GO
ALTER TABLE [dbo].[CaLamViec] CHECK CONSTRAINT [CK_CaLamViec_GioNghiTrua]
GO
ALTER TABLE [dbo].[CaLamViec]  WITH CHECK ADD  CONSTRAINT [CK_CaLamViec_ThoiGianKetThuc] CHECK  (([ThoiGianKetThuc]>[ThoiGianBatDau]))
GO
ALTER TABLE [dbo].[CaLamViec] CHECK CONSTRAINT [CK_CaLamViec_ThoiGianKetThuc]
GO
ALTER TABLE [dbo].[CaLamViec]  WITH CHECK ADD  CONSTRAINT [CK_CaLamViec_ThoiGianTao] CHECK  (([ThoiGianTao]<=getdate()))
GO
ALTER TABLE [dbo].[CaLamViec] CHECK CONSTRAINT [CK_CaLamViec_ThoiGianTao]
GO
ALTER TABLE [dbo].[ChamCong]  WITH CHECK ADD  CONSTRAINT [CK__ChamCong_GhiChu] CHECK  (([GhiChu]=N'Không Đạt' OR [GhiChu]=N'Đạt'))
GO
ALTER TABLE [dbo].[ChamCong] CHECK CONSTRAINT [CK__ChamCong_GhiChu]
GO
ALTER TABLE [dbo].[ChamCong]  WITH CHECK ADD  CONSTRAINT [CK_ChamCong_NgayChamCong] CHECK  (([NgayChamCong]<=getdate()))
GO
ALTER TABLE [dbo].[ChamCong] CHECK CONSTRAINT [CK_ChamCong_NgayChamCong]
GO
ALTER TABLE [dbo].[ChamCong]  WITH CHECK ADD  CONSTRAINT [CK_ChamCong_ThoiGianRaVe] CHECK  ((CONVERT([date],[ThoiGianRaVe])=[NgayChamCong]))
GO
ALTER TABLE [dbo].[ChamCong] CHECK CONSTRAINT [CK_ChamCong_ThoiGianRaVe]
GO
ALTER TABLE [dbo].[ChamCong]  WITH CHECK ADD  CONSTRAINT [CK_ChamCong_ThoiGianRaVe_HienTai] CHECK  (([ThoiGianRaVe]<=getdate()))
GO
ALTER TABLE [dbo].[ChamCong] CHECK CONSTRAINT [CK_ChamCong_ThoiGianRaVe_HienTai]
GO
ALTER TABLE [dbo].[ChamCong]  WITH CHECK ADD  CONSTRAINT [CK_ChamCong_ThoiGianVaoLam] CHECK  ((CONVERT([date],[ThoiGianVaoLam])=[NgayChamCong]))
GO
ALTER TABLE [dbo].[ChamCong] CHECK CONSTRAINT [CK_ChamCong_ThoiGianVaoLam]
GO
ALTER TABLE [dbo].[ChamCong]  WITH CHECK ADD  CONSTRAINT [CK_ChamCong_ThoiGianVaoLam_HienTai] CHECK  (([ThoiGianVaoLam]<=getdate()))
GO
ALTER TABLE [dbo].[ChamCong] CHECK CONSTRAINT [CK_ChamCong_ThoiGianVaoLam_HienTai]
GO
ALTER TABLE [dbo].[ChamCong]  WITH CHECK ADD  CONSTRAINT [CK_ChamCong_ThoiGianVaoRa] CHECK  (([ThoiGianRaVe]>=[ThoiGianVaoLam]))
GO
ALTER TABLE [dbo].[ChamCong] CHECK CONSTRAINT [CK_ChamCong_ThoiGianVaoRa]
GO
ALTER TABLE [dbo].[ChiTietDonHang]  WITH CHECK ADD  CONSTRAINT [Gia] CHECK  (([Gia]>(0)))
GO
ALTER TABLE [dbo].[ChiTietDonHang] CHECK CONSTRAINT [Gia]
GO
ALTER TABLE [dbo].[ChiTietPN]  WITH CHECK ADD  CONSTRAINT [CK_ChiTietPN_DonGiaXuat] CHECK  (([DonGiaXuat]>=(0)))
GO
ALTER TABLE [dbo].[ChiTietPN] CHECK CONSTRAINT [CK_ChiTietPN_DonGiaXuat]
GO
ALTER TABLE [dbo].[ChiTietPN]  WITH CHECK ADD  CONSTRAINT [CK_ChiTietPN_SoLuong] CHECK  (([SoLuong]>=(0)))
GO
ALTER TABLE [dbo].[ChiTietPN] CHECK CONSTRAINT [CK_ChiTietPN_SoLuong]
GO
ALTER TABLE [dbo].[ChiTietPX]  WITH CHECK ADD  CONSTRAINT [CK_ChiTietPX_DonGiaXuat] CHECK  (([DonGiaXuat]>=(0)))
GO
ALTER TABLE [dbo].[ChiTietPX] CHECK CONSTRAINT [CK_ChiTietPX_DonGiaXuat]
GO
ALTER TABLE [dbo].[ChiTietPX]  WITH CHECK ADD  CONSTRAINT [CK_ChiTietPX_SoLuong] CHECK  (([SoLuong]>=(0)))
GO
ALTER TABLE [dbo].[ChiTietPX] CHECK CONSTRAINT [CK_ChiTietPX_SoLuong]
GO
ALTER TABLE [dbo].[DonHang]  WITH CHECK ADD  CONSTRAINT [TrangThai] CHECK  (([TrangThai]='Ðã giao' OR [TrangThai]='Ðang giao'))
GO
ALTER TABLE [dbo].[DonHang] CHECK CONSTRAINT [TrangThai]
GO
ALTER TABLE [dbo].[FAQ]  WITH CHECK ADD  CONSTRAINT [CK_FAQ_CauHoiThuongGap] CHECK  ((len(ltrim(rtrim([CauHoiThuongGap])))>(0)))
GO
ALTER TABLE [dbo].[FAQ] CHECK CONSTRAINT [CK_FAQ_CauHoiThuongGap]
GO
ALTER TABLE [dbo].[FAQ]  WITH CHECK ADD  CONSTRAINT [CK_FAQ_CauTraLoiTuongUng] CHECK  ((len(ltrim(rtrim([CauTraLoiTuongUng])))>(0)))
GO
ALTER TABLE [dbo].[FAQ] CHECK CONSTRAINT [CK_FAQ_CauTraLoiTuongUng]
GO
ALTER TABLE [dbo].[FAQ]  WITH CHECK ADD  CONSTRAINT [CK_FAQ_DanhMucCauHoi] CHECK  (([DanhMucCauHoi]='Câu H?i Khác' OR [DanhMucCauHoi]='Tuong tác thu?c' OR [DanhMucCauHoi]='Tu v?n s?c kh?e' OR [DanhMucCauHoi]='Tìm ki?m thu?c'))
GO
ALTER TABLE [dbo].[FAQ] CHECK CONSTRAINT [CK_FAQ_DanhMucCauHoi]
GO
ALTER TABLE [dbo].[FAQ]  WITH CHECK ADD  CONSTRAINT [CK_FAQ_DanhMucCauHoi_KhongRong] CHECK  ((len(ltrim(rtrim([DanhMucCauHoi])))>(0)))
GO
ALTER TABLE [dbo].[FAQ] CHECK CONSTRAINT [CK_FAQ_DanhMucCauHoi_KhongRong]
GO
ALTER TABLE [dbo].[FAQ]  WITH CHECK ADD  CONSTRAINT [CK_FAQ_NgayCapNhatCauHoi] CHECK  (([NgayCapNhatCauHoi] IS NULL OR [NgayCapNhatCauHoi]>=[NgayTaoCauHoi]))
GO
ALTER TABLE [dbo].[FAQ] CHECK CONSTRAINT [CK_FAQ_NgayCapNhatCauHoi]
GO
ALTER TABLE [dbo].[GioHang]  WITH CHECK ADD  CONSTRAINT [CK_DonGia_GioHang] CHECK  (([DonGia]>(0)))
GO
ALTER TABLE [dbo].[GioHang] CHECK CONSTRAINT [CK_DonGia_GioHang]
GO
ALTER TABLE [dbo].[GioHang]  WITH CHECK ADD  CONSTRAINT [CK_SoLuong_GioHang] CHECK  (([SoLuong]>(0)))
GO
ALTER TABLE [dbo].[GioHang] CHECK CONSTRAINT [CK_SoLuong_GioHang]
GO
ALTER TABLE [dbo].[HinhAnh]  WITH CHECK ADD  CONSTRAINT [CK_HinhAnh_UrlAnh] CHECK  (([UrlAnh]<>N''))
GO
ALTER TABLE [dbo].[HinhAnh] CHECK CONSTRAINT [CK_HinhAnh_UrlAnh]
GO
ALTER TABLE [dbo].[KhachHang]  WITH CHECK ADD  CONSTRAINT [CK_KhachHang_Diem] CHECK  (([Diem]>=(0)))
GO
ALTER TABLE [dbo].[KhachHang] CHECK CONSTRAINT [CK_KhachHang_Diem]
GO
ALTER TABLE [dbo].[KhachHang]  WITH CHECK ADD  CONSTRAINT [CK_KhachHang_GioiTinh] CHECK  (([GioiTinh]=N'Nữ' OR [GioiTinh]=N'Nam'))
GO
ALTER TABLE [dbo].[KhachHang] CHECK CONSTRAINT [CK_KhachHang_GioiTinh]
GO
ALTER TABLE [dbo].[KhachHang]  WITH CHECK ADD  CONSTRAINT [CK_KhachHang_NgaySinh] CHECK  (([NgaySinh]<=getdate()))
GO
ALTER TABLE [dbo].[KhachHang] CHECK CONSTRAINT [CK_KhachHang_NgaySinh]
GO
ALTER TABLE [dbo].[KhachHang]  WITH CHECK ADD  CONSTRAINT [CK_KhachHang_SoDienThoai] CHECK  (([SoDienThoai] like '[0-9]%'))
GO
ALTER TABLE [dbo].[KhachHang] CHECK CONSTRAINT [CK_KhachHang_SoDienThoai]
GO
ALTER TABLE [dbo].[Luong]  WITH CHECK ADD  CONSTRAINT [CK_Luong_KhauTru] CHECK  (([KhauTru]>=(0)))
GO
ALTER TABLE [dbo].[Luong] CHECK CONSTRAINT [CK_Luong_KhauTru]
GO
ALTER TABLE [dbo].[Luong]  WITH CHECK ADD  CONSTRAINT [CK_Luong_LuongThang] CHECK  (([LuongThang]<=getdate()))
GO
ALTER TABLE [dbo].[Luong] CHECK CONSTRAINT [CK_Luong_LuongThang]
GO
ALTER TABLE [dbo].[Luong]  WITH CHECK ADD  CONSTRAINT [CK_Luong_LuongThucNhan] CHECK  (([LuongThucNhan]>=(0)))
GO
ALTER TABLE [dbo].[Luong] CHECK CONSTRAINT [CK_Luong_LuongThucNhan]
GO
ALTER TABLE [dbo].[Luong]  WITH CHECK ADD  CONSTRAINT [CK_Luong_NgayTraLuong] CHECK  (([NgayTraLuong]>=getdate()))
GO
ALTER TABLE [dbo].[Luong] CHECK CONSTRAINT [CK_Luong_NgayTraLuong]
GO
ALTER TABLE [dbo].[Luong]  WITH CHECK ADD  CONSTRAINT [CK_Luong_SoCaLamViec] CHECK  (([SoCaLamViec]>(0)))
GO
ALTER TABLE [dbo].[Luong] CHECK CONSTRAINT [CK_Luong_SoCaLamViec]
GO
ALTER TABLE [dbo].[NguoiDung]  WITH CHECK ADD  CONSTRAINT [CK_NguoiDung_Email] CHECK  (([Email] like '%_@__%.__%'))
GO
ALTER TABLE [dbo].[NguoiDung] CHECK CONSTRAINT [CK_NguoiDung_Email]
GO
ALTER TABLE [dbo].[NguoiDung]  WITH CHECK ADD  CONSTRAINT [CK_NguoiDung_Password_ChuHoa] CHECK  (([Password] like '%[A-Z]%'))
GO
ALTER TABLE [dbo].[NguoiDung] CHECK CONSTRAINT [CK_NguoiDung_Password_ChuHoa]
GO
ALTER TABLE [dbo].[NguoiDung]  WITH CHECK ADD  CONSTRAINT [CK_NguoiDung_Password_ChuThuong] CHECK  (([Password] like '%[a-z]%'))
GO
ALTER TABLE [dbo].[NguoiDung] CHECK CONSTRAINT [CK_NguoiDung_Password_ChuThuong]
GO
ALTER TABLE [dbo].[NguoiDung]  WITH CHECK ADD  CONSTRAINT [CK_NguoiDung_Password_Dai] CHECK  ((len([Password])>=(8)))
GO
ALTER TABLE [dbo].[NguoiDung] CHECK CONSTRAINT [CK_NguoiDung_Password_Dai]
GO
ALTER TABLE [dbo].[NguoiDung]  WITH CHECK ADD  CONSTRAINT [CK_NguoiDung_Password_So] CHECK  (([Password] like '%[0-9]%'))
GO
ALTER TABLE [dbo].[NguoiDung] CHECK CONSTRAINT [CK_NguoiDung_Password_So]
GO
ALTER TABLE [dbo].[NguoiDung]  WITH CHECK ADD  CONSTRAINT [CK_NguoiDung_SoDienThoai] CHECK  ((len([SoDienThoai])>=(10) AND len([SoDienThoai])<=(15)))
GO
ALTER TABLE [dbo].[NguoiDung] CHECK CONSTRAINT [CK_NguoiDung_SoDienThoai]
GO
ALTER TABLE [dbo].[NguoiDung]  WITH CHECK ADD  CONSTRAINT [CK_NguoiDung_TrangThai] CHECK  (([TrangThai]='Inactive' OR [TrangThai]='Active'))
GO
ALTER TABLE [dbo].[NguoiDung] CHECK CONSTRAINT [CK_NguoiDung_TrangThai]
GO
ALTER TABLE [dbo].[NhanVien]  WITH CHECK ADD  CONSTRAINT [CK_NhanVien_CaLamViec] CHECK  (([MaCaLamViec] IS NOT NULL OR [TrangThai]='Ðã ngh?'))
GO
ALTER TABLE [dbo].[NhanVien] CHECK CONSTRAINT [CK_NhanVien_CaLamViec]
GO
ALTER TABLE [dbo].[NhanVien]  WITH CHECK ADD  CONSTRAINT [CK_NhanVien_ChucVu] CHECK  (([ChucVu]='Nhân viên Bán Hàng' OR [ChucVu]='Nhân viên Kho'))
GO
ALTER TABLE [dbo].[NhanVien] CHECK CONSTRAINT [CK_NhanVien_ChucVu]
GO
ALTER TABLE [dbo].[NhanVien]  WITH CHECK ADD  CONSTRAINT [CK_NhanVien_GioiTinh] CHECK  (([GioiTinh]='N?' OR [GioiTinh]='Nam'))
GO
ALTER TABLE [dbo].[NhanVien] CHECK CONSTRAINT [CK_NhanVien_GioiTinh]
GO
ALTER TABLE [dbo].[NhanVien]  WITH CHECK ADD  CONSTRAINT [CK_NhanVien_LuongCoBan1Ca] CHECK  (([LuongCoBan1Ca]>=(0)))
GO
ALTER TABLE [dbo].[NhanVien] CHECK CONSTRAINT [CK_NhanVien_LuongCoBan1Ca]
GO
ALTER TABLE [dbo].[NhanVien]  WITH CHECK ADD  CONSTRAINT [CK_NhanVien_LuongTangCa1Gio] CHECK  (([LuongTangCa1Gio]>=(0)))
GO
ALTER TABLE [dbo].[NhanVien] CHECK CONSTRAINT [CK_NhanVien_LuongTangCa1Gio]
GO
ALTER TABLE [dbo].[NhanVien]  WITH CHECK ADD  CONSTRAINT [CK_NhanVien_NgaySinh] CHECK  (([NgaySinh]<getdate() AND (datediff(year,[NgaySinh],getdate())>=(21) AND datediff(year,[NgaySinh],getdate())<=(40))))
GO
ALTER TABLE [dbo].[NhanVien] CHECK CONSTRAINT [CK_NhanVien_NgaySinh]
GO
ALTER TABLE [dbo].[NhanVien]  WITH CHECK ADD  CONSTRAINT [CK_NhanVien_TrangThai] CHECK  (([TrangThai]='Ðã ngh?' OR [TrangThai]='Ðang làm'))
GO
ALTER TABLE [dbo].[NhanVien] CHECK CONSTRAINT [CK_NhanVien_TrangThai]
GO
ALTER TABLE [dbo].[PhieuNhap]  WITH CHECK ADD  CONSTRAINT [CK_PhieuNhap_NgayNhap] CHECK  (([NgayNhap]<=getdate()))
GO
ALTER TABLE [dbo].[PhieuNhap] CHECK CONSTRAINT [CK_PhieuNhap_NgayNhap]
GO
ALTER TABLE [dbo].[PhieuNhap]  WITH CHECK ADD  CONSTRAINT [CK_PhieuNhap_TongTien] CHECK  (([TongTien]>=(0)))
GO
ALTER TABLE [dbo].[PhieuNhap] CHECK CONSTRAINT [CK_PhieuNhap_TongTien]
GO
ALTER TABLE [dbo].[PhieuXuat]  WITH CHECK ADD  CONSTRAINT [CK_PhieuXuat_NgayXuat] CHECK  (([NgayXuat]<=getdate()))
GO
ALTER TABLE [dbo].[PhieuXuat] CHECK CONSTRAINT [CK_PhieuXuat_NgayXuat]
GO
ALTER TABLE [dbo].[PhieuXuat]  WITH CHECK ADD  CONSTRAINT [CK_PhieuXuat_TongTien] CHECK  (([TongTien]>=(0)))
GO
ALTER TABLE [dbo].[PhieuXuat] CHECK CONSTRAINT [CK_PhieuXuat_TongTien]
GO
ALTER TABLE [dbo].[QuyenTruyCap]  WITH CHECK ADD  CONSTRAINT [CK_TenQuyen] CHECK  ((len([TenQuyen])>(0)))
GO
ALTER TABLE [dbo].[QuyenTruyCap] CHECK CONSTRAINT [CK_TenQuyen]
GO
ALTER TABLE [dbo].[ThanhToan]  WITH CHECK ADD  CONSTRAINT [SoTien] CHECK  (([SoTien]>(0)))
GO
ALTER TABLE [dbo].[ThanhToan] CHECK CONSTRAINT [SoTien]
GO
ALTER TABLE [dbo].[ThanhToan]  WITH CHECK ADD  CONSTRAINT [TrangThaiThanhToan] CHECK  (([TrangThaiThanhToan]='Ðã thanh toán' OR [TrangThaiThanhToan]='Chua thanh toán'))
GO
ALTER TABLE [dbo].[ThanhToan] CHECK CONSTRAINT [TrangThaiThanhToan]
GO
ALTER TABLE [dbo].[Thuoc]  WITH CHECK ADD  CONSTRAINT [CK_Thuoc_DonGia] CHECK  (([DonGia]>(0)))
GO
ALTER TABLE [dbo].[Thuoc] CHECK CONSTRAINT [CK_Thuoc_DonGia]
GO
ALTER TABLE [dbo].[Thuoc]  WITH CHECK ADD  CONSTRAINT [CK_Thuoc_SoLuongTon] CHECK  (([SoLuongTon]>=(0)))
GO
ALTER TABLE [dbo].[Thuoc] CHECK CONSTRAINT [CK_Thuoc_SoLuongTon]
GO
ALTER TABLE [dbo].[Thuoc]  WITH CHECK ADD  CONSTRAINT [CK_Thuoc_TenThuoc] CHECK  (([TenThuoc]<>N''))
GO
ALTER TABLE [dbo].[Thuoc] CHECK CONSTRAINT [CK_Thuoc_TenThuoc]
GO
ALTER TABLE [dbo].[TonKho]  WITH CHECK ADD  CONSTRAINT [CK_TonKho_SoLuongCanhBao] CHECK  (([SoLuongCanhBao]>=(0)))
GO
ALTER TABLE [dbo].[TonKho] CHECK CONSTRAINT [CK_TonKho_SoLuongCanhBao]
GO
ALTER TABLE [dbo].[TonKho]  WITH CHECK ADD  CONSTRAINT [CK_TonKho_SoLuongHienTai] CHECK  (([SoLuongHienTai]<=[SoLuongToiDa]))
GO
ALTER TABLE [dbo].[TonKho] CHECK CONSTRAINT [CK_TonKho_SoLuongHienTai]
GO
ALTER TABLE [dbo].[TonKho]  WITH CHECK ADD  CONSTRAINT [CK_TonKho_SoLuongToiDa] CHECK  (([SoLuongToiDa]>=(0)))
GO
ALTER TABLE [dbo].[TonKho] CHECK CONSTRAINT [CK_TonKho_SoLuongToiDa]
GO
ALTER TABLE [dbo].[TonKho]  WITH CHECK ADD  CONSTRAINT [CK_TonKho_TrangThai] CHECK  (([TrangThai]=N'Đầy Hàng' OR [TrangThai]=N'Hết Hàng' OR [TrangThai]=N'Bình Thường'))
GO
ALTER TABLE [dbo].[TonKho] CHECK CONSTRAINT [CK_TonKho_TrangThai]
GO
ALTER TABLE [dbo].[VaiTro]  WITH CHECK ADD  CONSTRAINT [CK_TenVaiTro] CHECK  ((len([TenVaiTro])>(0)))
GO
ALTER TABLE [dbo].[VaiTro] CHECK CONSTRAINT [CK_TenVaiTro]
GO
/****** Object:  StoredProcedure [dbo].[AddChiTietDonHang]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddChiTietDonHang]
    @MaDonHang INT,
    @MaThuoc INT,
    @SoLuong INT,
    @Gia DECIMAL(18, 0)
AS
BEGIN
    INSERT INTO ChiTietDonHang (MaDonHang, MaThuoc, SoLuong, Gia)
    VALUES (@MaDonHang, @MaThuoc, @SoLuong, @Gia);
END;
GO
/****** Object:  StoredProcedure [dbo].[AddDonHang]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddDonHang]
	@MaKhachHang INT,
    @TongTien DECIMAL(10, 2),
    @GhiChu NVARCHAR(MAX),
    @DiaChi NVARCHAR(255),
    @MaNhanVien INT
AS
BEGIN
    INSERT INTO DonHang (MaKhachHang,TongTien, GhiChu, NgayDatHang, DiaChi, TrangThai, MaNhanVien)
    VALUES (@MakhachHang,@TongTien, @GhiChu, GETDATE(), @DiaChi, 'Đang giao', @MaNhanVien);
END;
GO
/****** Object:  StoredProcedure [dbo].[AddGioHang]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddGioHang]
    @SoLuong INT,
    @DonGia DECIMAL(18, 0),
    @MaThuoc INT,
    @DonVi NVARCHAR(10)
AS
BEGIN
    INSERT INTO GioHang (SoLuong, DonGia, TongTien, MaThuoc, DonVi)
    VALUES (@SoLuong, @DonGia, @SoLuong * @DonGia, @MaThuoc, @DonVi);
END;
GO
/****** Object:  StoredProcedure [dbo].[AddPhanQuyen]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddPhanQuyen]
    @MaVaiTro INT,
    @MaQuyen INT
AS
BEGIN
    INSERT INTO PhanQuyen (MaVaiTro, MaQuyen) VALUES (@MaVaiTro, @MaQuyen);
END;
GO
/****** Object:  StoredProcedure [dbo].[AddQuyenTruyCap]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddQuyenTruyCap]
    @TenQuyen NVARCHAR(50)
AS
BEGIN
    INSERT INTO QuyenTruyCap (TenQuyen) VALUES (@TenQuyen);
END;
GO
/****** Object:  StoredProcedure [dbo].[AddThanhToan]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddThanhToan]
    @MaDonHang INT,
    @PhuongThucThanhToan NVARCHAR(50),
    @TrangThaiThanhToan NVARCHAR(50),
    @SoTien DECIMAL(15, 2),
    @MaQR NVARCHAR(255) = NULL,
    @GhiChu NVARCHAR(255) = NULL
AS
BEGIN
    INSERT INTO ThanhToan (MaDonHang, PhuongThucThanhToan, TrangThaiThanhToan, SoTien, MaQR, GhiChu)
    VALUES (@MaDonHang, @PhuongThucThanhToan, @TrangThaiThanhToan, @SoTien, @MaQR, @GhiChu);
END;
GO
/****** Object:  StoredProcedure [dbo].[AddVaiTro]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddVaiTro]
    @TenVaiTro NVARCHAR(50)
AS
BEGIN
    INSERT INTO VaiTro (TenVaiTro) VALUES (@TenVaiTro);
END;
GO
/****** Object:  StoredProcedure [dbo].[DeleteDonHang]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteDonHang]
    @MaDonHang INT
AS
BEGIN
    DELETE FROM DonHang WHERE MaDonHang = @MaDonHang;
END;
GO
/****** Object:  StoredProcedure [dbo].[DeleteGioHang]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteGioHang]
    @MaGioHang INT
AS
BEGIN
    DELETE FROM GioHang WHERE MaGioHang = @MaGioHang;
END;
GO
/****** Object:  StoredProcedure [dbo].[DeletePhanQuyen]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeletePhanQuyen]
    @MaVaiTro INT,
    @MaQuyen INT
AS
BEGIN
    DELETE FROM PhanQuyen WHERE MaVaiTro = @MaVaiTro AND MaQuyen = @MaQuyen;
END;
GO
/****** Object:  StoredProcedure [dbo].[DeleteQuyenTruyCap]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteQuyenTruyCap]
    @MaQuyen INT
AS
BEGIN
    DELETE FROM QuyenTruyCap WHERE MaQuyen = @MaQuyen;
END;
GO
/****** Object:  StoredProcedure [dbo].[DeleteVaiTro]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteVaiTro]
    @MaVaiTro INT
AS
BEGIN
    DELETE FROM VaiTro WHERE MaVaiTro = @MaVaiTro;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_CapNhatCaLamViec]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CapNhatCaLamViec]
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
/****** Object:  StoredProcedure [dbo].[sp_CapNhatCauHoi]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CapNhatCauHoi]
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
/****** Object:  StoredProcedure [dbo].[sp_CapNhatChiTietPhieuNhap]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CapNhatChiTietPhieuNhap]
    @MaChiTietPhieuNhap INT,
    @SoLuong INT,
    @DonGia DECIMAL(18, 0)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ChiTietPhieuNhap WHERE MaChiTietPhieuNhap = @MaChiTietPhieuNhap)
        BEGIN
            UPDATE ChiTietPhieuNhap
            SET SoLuong = @SoLuong, DonGia = @DonGia
            WHERE MaChiTietPhieuNhap = @MaChiTietPhieuNhap;
            PRINT 'Cập nhật chi tiết phiếu nhập thành công!';
        END
        ELSE
        BEGIN
            PRINT 'Chi tiết phiếu nhập không tồn tại!';
        END
    END TRY
    BEGIN CATCH
        PRINT 'Lỗi xảy ra: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_CapNhatLoaiSanPham]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CapNhatLoaiSanPham]
    @MaLoaiSanPham INT,
    @TenLoaiSanPham NVARCHAR(255)
AS
BEGIN
    -- Kiểm tra xem loại sản phẩm có tồn tại hay không
    IF NOT EXISTS (SELECT 1 FROM LoaiSanPham WHERE MaLoaiSanPham = @MaLoaiSanPham)
    BEGIN
        PRINT 'Loại sản phẩm không tồn tại!';
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Cập nhật loại sản phẩm
        UPDATE LoaiSanPham
        SET TenLoai = @TenLoaiSanPham
        WHERE MaLoaiSanPham = @MaLoaiSanPham;

        PRINT 'Cập nhật loại sản phẩm thành công!';

        COMMIT; -- Commit nếu không có lỗi
    END TRY
    BEGIN CATCH
        -- Rollback khi có lỗi
        ROLLBACK;
        PRINT 'Có lỗi xảy ra. Giao dịch bị hủy!';
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_CapNhatLuong]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CapNhatLuong]
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
/****** Object:  StoredProcedure [dbo].[sp_CapNhatNhanVien]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CapNhatNhanVien]
    @MaNhanVien INT,
    @Ho NVARCHAR(50),
    @Ten NVARCHAR(50),
    @NgaySinh DATE,
    @GioiTinh NVARCHAR(10),
    @DiaChi NVARCHAR(255),
    @ChucVu NVARCHAR(50),
    @NgayTuyenDung DATE,
    @TrangThai NVARCHAR(50),
    @LuongCoBan1Ca DECIMAL(18, 0)= Null,
    @LuongTangCa1Gio DECIMAL(18, 0)= null
AS
BEGIN
    UPDATE NhanVien
    SET Ho = @Ho,
        Ten = @Ten,
        NgaySinh = @NgaySinh,
        GioiTinh = @GioiTinh,
        DiaChi = @DiaChi,
        ChucVu = @ChucVu,
        NgayTuyenDung = @NgayTuyenDung,
        TrangThai = @TrangThai,
        LuongCoBan1Ca = @LuongCoBan1Ca,
        LuongTangCa1Gio = @LuongTangCa1Gio
    WHERE MaNhanVien = @MaNhanVien;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_CapNhatPhieuNhap]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CapNhatPhieuNhap]
    @MaPhieuNhap INT,
    @NgayNhap DATE,
    @MaNhaCungCap INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM PhieuNhap WHERE MaPhieuNhap = @MaPhieuNhap)
        BEGIN
            UPDATE PhieuNhap
            SET NgayNhap = @NgayNhap
            WHERE MaPhieuNhap = @MaPhieuNhap;
            PRINT 'Cập nhật phiếu nhập thành công!';
        END
        ELSE
        BEGIN
            PRINT 'Phiếu nhập không tồn tại!';
        END
    END TRY
    BEGIN CATCH
        PRINT 'Lỗi xảy ra: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_CapNhatThongTinKhachHang]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CapNhatThongTinKhachHang]
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
/****** Object:  StoredProcedure [dbo].[sp_CapNhatThongTinNguoiDung]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CapNhatThongTinNguoiDung]
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
/****** Object:  StoredProcedure [dbo].[sp_CapNhatThuoc]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CapNhatThuoc]
    @MaThuoc INT,
    @TenThuoc NVARCHAR(255),
    @HanSuDung DATE,
    @DonGia DECIMAL(18, 0),
    @SoLuongTon INT
AS
BEGIN
    -- Kiểm tra xem thuốc có tồn tại hay không
    IF NOT EXISTS (SELECT 1 FROM Thuoc WHERE MaThuoc = @MaThuoc)
    BEGIN
        PRINT 'Thuốc không tồn tại!';
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Cập nhật thông tin thuốc
        UPDATE Thuoc
        SET TenThuoc = @TenThuoc,
            HanSuDung = @HanSuDung,
            DonGia = @DonGia,
            SoLuongTon = @SoLuongTon
        WHERE MaThuoc = @MaThuoc;

        PRINT 'Cập nhật thuốc thành công!';

        COMMIT; -- Commit nếu không có lỗi
    END TRY
    BEGIN CATCH
        -- Rollback khi có lỗi
        ROLLBACK;
        PRINT 'Có lỗi xảy ra. Giao dịch bị hủy!';
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_CapNhatTonKho]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CapNhatTonKho]
    @MaTonKho INT,
    @SoLuongTon INT,
    @SoLuongCanhBao INT,
    @SoLuongHienTai INT,
    @SoLuongToiDa INT,
    @TrangThai NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM TonKho WHERE MaTonKho = @MaTonKho)
        BEGIN
            UPDATE TonKho
            SET SoLuongTon = @SoLuongTon, SoLuongCanhBao = @SoLuongCanhBao, SoLuongHienTai = @SoLuongHienTai,
                SoLuongToiDa = @SoLuongToiDa, TrangThai = @TrangThai
            WHERE MaTonKho = @MaTonKho;
            PRINT 'Cập nhật tồn kho thành công!';
        END
        ELSE
        BEGIN
            PRINT 'Tồn kho không tồn tại!';
        END
    END TRY
    BEGIN CATCH
        PRINT 'Lỗi xảy ra: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ChamCongRa]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ChamCongRa]
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
/****** Object:  StoredProcedure [dbo].[sp_LayDanhSachChiTietPhieuNhap]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_LayDanhSachChiTietPhieuNhap]
AS
BEGIN
    BEGIN TRY
        SELECT * FROM ChiTietPhieuNhap;
    END TRY
    BEGIN CATCH
        PRINT 'Lỗi xảy ra: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_LayDanhSachHinhAnh]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Lấy danh sách Hình Ảnh
CREATE PROCEDURE [dbo].[sp_LayDanhSachHinhAnh]
AS
BEGIN
    BEGIN TRY
        SELECT * FROM HinhAnh;
    END TRY
    BEGIN CATCH
        PRINT 'Lỗi xảy ra: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_LayDanhSachLoaiSanPham]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_LayDanhSachLoaiSanPham]
AS
BEGIN
    BEGIN TRY
        SELECT * FROM LoaiSanPham;
    END TRY
    BEGIN CATCH
        PRINT 'Lỗi xảy ra: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_LayDanhSachPhieuNhap]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_LayDanhSachPhieuNhap]
AS
BEGIN
    BEGIN TRY
        SELECT * FROM PhieuNhap;
    END TRY
    BEGIN CATCH
        PRINT 'Lỗi xảy ra: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_LayDanhSachThuoc]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_LayDanhSachThuoc]
AS
BEGIN
    BEGIN TRY
        SELECT * FROM Thuoc;
    END TRY
    BEGIN CATCH
        PRINT 'Lỗi xảy ra: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_LayDanhSachTonKho]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_LayDanhSachTonKho]
AS
BEGIN
    BEGIN TRY
        SELECT * FROM TonKho;
    END TRY
    BEGIN CATCH
        PRINT 'Lỗi xảy ra: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_LayTatCaCaLamViec]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_LayTatCaCaLamViec]
AS
BEGIN
    SELECT * FROM CaLamViec;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_LayTatCaCauHoi]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_LayTatCaCauHoi]
AS
BEGIN
    SELECT * FROM FAQ;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_ThemCaLamViec]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ThemCaLamViec]
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
/****** Object:  StoredProcedure [dbo].[sp_ThemCauHoi]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ThemCauHoi]
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
/****** Object:  StoredProcedure [dbo].[sp_ThemChamCongVao]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ThemChamCongVao]
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
/****** Object:  StoredProcedure [dbo].[sp_ThemChiTietPhieuNhap]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ThemChiTietPhieuNhap]
    @MaPhieuNhap INT,
    @MaThuoc INT,
    @SoLuong INT,
    @DonGia DECIMAL(18, 0)
AS
BEGIN
    BEGIN TRY
        INSERT INTO ChiTietPhieuNhap (MaPhieuNhap, MaThuoc, SoLuong, DonGia)
        VALUES (@MaPhieuNhap, @MaThuoc, @SoLuong, @DonGia);
        PRINT 'Thêm chi tiết phiếu nhập thành công!';
    END TRY
    BEGIN CATCH
        PRINT 'Lỗi xảy ra: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ThemHinhAnh]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ThemHinhAnh]
    @UrlAnh NVARCHAR(MAX),
    @MaThuoc INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO HinhAnh (UrlAnh, MaThuoc)
        VALUES (@UrlAnh, @MaThuoc);
        PRINT 'Thêm hình ảnh thành công!';
    END TRY
    BEGIN CATCH
        PRINT 'Lỗi xảy ra: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ThemKhachHang]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ThemKhachHang]
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
/****** Object:  StoredProcedure [dbo].[sp_ThemLoaiSanPham]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ThemLoaiSanPham]
    @TenLoaiSanPham NVARCHAR(255)
AS
BEGIN
    -- Kiểm tra xem loại sản phẩm có tồn tại hay không
    IF EXISTS (SELECT 1 FROM LoaiSanPham WHERE TenLoai = @TenLoaiSanPham)
    BEGIN
        PRINT 'Loại sản phẩm đã tồn tại!';
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Thêm loại sản phẩm mới
        INSERT INTO LoaiSanPham (TenLoai)
        VALUES (@TenLoaiSanPham);

        PRINT 'Thêm loại sản phẩm thành công!';

        COMMIT; -- Commit nếu không có lỗi
    END TRY
    BEGIN CATCH
        -- Rollback khi có lỗi
        ROLLBACK;
        PRINT 'Có lỗi xảy ra. Giao dịch bị hủy!';
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ThemLuongNhanVien]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ThemLuongNhanVien]
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
/****** Object:  StoredProcedure [dbo].[sp_ThemNguoiDungKhachHang]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ThemNguoiDungKhachHang]
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
/****** Object:  StoredProcedure [dbo].[sp_ThemNguoiDungNhanVien]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ThemNguoiDungNhanVien]
    @TenNguoiDung NVARCHAR(255),   -- Tên người dùng
    @Password NVARCHAR(255),       -- Mật khẩu
    @Email NVARCHAR(255),          -- Email
    @SoDienThoai NVARCHAR(20),     -- Số điện thoại
    @TrangThai NVARCHAR(50) = 'Active', -- Trạng thái tài khoản, mặc định là 'Active'
    @NgayTao DATE = NULL           -- Ngày tạo tài khoản, mặc định là NULL, sẽ được gán giá trị sau
AS
BEGIN
    DECLARE @MaVaiTro INT;

    -- Nếu @NgayTao là NULL, thiết lập giá trị là ngày hiện tại
    IF @NgayTao IS NULL
    BEGIN
        SET @NgayTao = GETDATE();
    END

    -- Tìm mã vai trò cho nhân viên
    SELECT @MaVaiTro = MaVaiTro FROM VaiTro WHERE TenVaiTro = N'Nhân viên';
    
    -- Kiểm tra nếu không tìm thấy vai trò Nhân viên
    IF @MaVaiTro IS NULL
    BEGIN
        SELECT 'Lỗi: Không tìm thấy vai trò Nhân viên trong hệ thống' AS ThongBao;
        RETURN;
    END

    -- Thêm người dùng vào bảng NguoiDung với vai trò Nhân viên
    INSERT INTO NguoiDung (TenNguoiDung, Password, Email, SoDienThoai, MaVaiTro, TrangThai, NgayTao)
    VALUES (@TenNguoiDung, dbo.HashPassword(@Password), @Email, @SoDienThoai, @MaVaiTro, @TrangThai, @NgayTao);
    
    -- Trả về thông báo thành công
    SELECT 'Tạo tài khoản nhân viên thành công' AS ThongBao;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_ThemNhanVien]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ThemNhanVien]
    @Ho NVARCHAR(50),
    @Ten NVARCHAR(50),
    @NgaySinh DATE,
    @GioiTinh NVARCHAR(10),
    @DiaChi NVARCHAR(255),
    @ChucVu NVARCHAR(50),
    @NgayTuyenDung DATE,
    @TrangThai NVARCHAR(50),
    @MaNguoiDung INT,
    @MaCaLamViec INT,
    @LuongCoBan1Ca DECIMAL(18, 0) = NULL, -- Giá trị mặc định là NULL nếu không truyền vào
    @LuongTangCa1Gio DECIMAL(18, 0) = NULL -- Giá trị mặc định là NULL nếu không truyền vào
AS
BEGIN
    -- Thêm nhân viên vào bảng NhanVien
    INSERT INTO NhanVien
    (
        Ho, Ten, NgaySinh, GioiTinh, DiaChi, ChucVu, NgayTuyenDung, TrangThai, MaNguoiDung, MaCaLamViec, LuongCoBan1Ca, LuongTangCa1Gio
    )
    VALUES
    (
        @Ho, @Ten, @NgaySinh, @GioiTinh, @DiaChi, @ChucVu, @NgayTuyenDung, @TrangThai, @MaNguoiDung, @MaCaLamViec, @LuongCoBan1Ca, @LuongTangCa1Gio
    );
    
    -- Trả về thông báo thành công
    SELECT 'Thêm nhân viên thành công' AS ThongBao;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_ThemPhieuNhap]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ThemPhieuNhap]
    @NgayNhap DATE,
    @MaNhaCungCap INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO PhieuNhap (NgayNhap)
        VALUES (@NgayNhap);
        PRINT 'Thêm phiếu nhập thành công!';
    END TRY
    BEGIN CATCH
        PRINT 'Lỗi xảy ra: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ThemThuoc]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ThemThuoc]
    @TenThuoc NVARCHAR(255),
    @HanSuDung DATE,
    @DonGia DECIMAL(18, 0),
    @SoLuongTon INT,
    @MaLoaiSanPham INT
AS
BEGIN
    -- Kiểm tra điều kiện trước khi bắt đầu giao dịch
    IF EXISTS (SELECT 1 FROM Thuoc WHERE TenThuoc = @TenThuoc)
    BEGIN
        PRINT 'Thuốc đã tồn tại!';
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Thêm thuốc nếu không tồn tại
        INSERT INTO Thuoc (TenThuoc, HanSuDung, DonGia, SoLuongTon, MaLoaiSanPham)
        VALUES (@TenThuoc, @HanSuDung, @DonGia, @SoLuongTon, @MaLoaiSanPham);
        
        PRINT 'Thêm thuốc thành công!';

        COMMIT; -- Commit nếu không có lỗi
    END TRY
    BEGIN CATCH
        -- Rollback khi có lỗi
        ROLLBACK;
        PRINT 'Có lỗi xảy ra. Giao dịch bị hủy!';
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ThemTonKho]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ThemTonKho]
    @SoLuongTon INT,
    @SoLuongCanhBao INT,
    @SoLuongHienTai INT,
    @SoLuongToiDa INT,
    @TrangThai NVARCHAR(50),
    @MaThuoc INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO TonKho (SoLuongTon, SoLuongCanhBao, SoLuongHienTai, SoLuongToiDa, TrangThai, MaThuoc)
        VALUES (@SoLuongTon, @SoLuongCanhBao, @SoLuongHienTai, @SoLuongToiDa, @TrangThai, @MaThuoc);
        PRINT 'Thêm tồn kho thành công!';
    END TRY
    BEGIN CATCH
        PRINT 'Lỗi xảy ra: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_TimKiemThuoc]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_TimKiemThuoc]
    @TuKhoa NVARCHAR(255)
AS
BEGIN
    SELECT *
    FROM Thuoc
    WHERE TenThuoc LIKE '%' + @TuKhoa + '%';
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_XoaCaLamViec]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_XoaCaLamViec]
    @MaCaLam INT
AS
BEGIN
    DELETE FROM CaLamViec WHERE MaCaLam = @MaCaLam;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_XoaCauHoi]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_XoaCauHoi]
    @MaCauHoi INT
AS
BEGIN
    DELETE FROM FAQ WHERE MaCauHoi = @MaCauHoi;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_XoaHinhAnh]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_XoaHinhAnh]
    @MaHinh INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM HinhAnh WHERE MaHinh = @MaHinh)
        BEGIN
            DELETE FROM HinhAnh WHERE MaHinh = @MaHinh;
            PRINT 'Xoá hình ảnh thành công!';
        END
        ELSE
        BEGIN
            PRINT 'Hình ảnh không tồn tại!';
        END
    END TRY
    BEGIN CATCH
        PRINT 'Lỗi xảy ra: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_XoaLoaiSanPham]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_XoaLoaiSanPham]
    @MaLoaiSanPham INT
AS
BEGIN
    -- Kiểm tra xem loại sản phẩm có tồn tại hay không
    IF NOT EXISTS (SELECT 1 FROM LoaiSanPham WHERE MaLoaiSanPham = @MaLoaiSanPham)
    BEGIN
        PRINT 'Loại sản phẩm không tồn tại!';
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Xóa loại sản phẩm
        DELETE FROM LoaiSanPham WHERE MaLoaiSanPham = @MaLoaiSanPham;

        PRINT 'Xóa loại sản phẩm thành công!';

        COMMIT; -- Commit nếu không có lỗi
    END TRY
    BEGIN CATCH
        -- Rollback khi có lỗi
        ROLLBACK;
        PRINT 'Có lỗi xảy ra. Giao dịch bị hủy!';
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_XoaNhanVien]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_XoaNhanVien]
    @MaNhanVien INT
AS
BEGIN
    DECLARE @MaNguoiDung INT;

    SELECT @MaNguoiDung = MaNguoiDung FROM NhanVien WHERE MaNhanVien = @MaNhanVien;

    DELETE FROM NhanVien WHERE MaNhanVien = @MaNhanVien;

    -- Cập nhật trạng thái người dùng thành 'Inactive'
    UPDATE NguoiDung
    SET TrangThai = 'Inactive'
    WHERE MaNguoiDung = @MaNguoiDung;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_XoaThuoc]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_XoaThuoc]
    @MaThuoc INT
AS
BEGIN
    -- Kiểm tra xem thuốc có tồn tại hay không
    IF NOT EXISTS (SELECT 1 FROM Thuoc WHERE MaThuoc = @MaThuoc)
    BEGIN
        PRINT 'Thuốc không tồn tại!';
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Xóa thuốc
        DELETE FROM Thuoc WHERE MaThuoc = @MaThuoc;

        PRINT 'Xóa thuốc thành công!';

        COMMIT; -- Commit nếu không có lỗi
    END TRY
    BEGIN CATCH
        -- Rollback khi có lỗi
        ROLLBACK;
        PRINT 'Có lỗi xảy ra. Giao dịch bị hủy!';
    END CATCH;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_XoaTonKho]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_XoaTonKho]
    @MaTonKho INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM TonKho WHERE MaTonKho = @MaTonKho)
        BEGIN
            DELETE FROM TonKho WHERE MaTonKho = @MaTonKho;
            PRINT 'Xoá tồn kho thành công!';
        END
        ELSE
        BEGIN
            PRINT 'Tồn kho không tồn tại!';
        END
    END TRY
    BEGIN CATCH
        PRINT 'Lỗi xảy ra: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateDonHang]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateDonHang]
    @MaDonHang INT,
    @TongTien DECIMAL(10, 2),
    @GhiChu NVARCHAR(MAX),
    @DiaChi NVARCHAR(255),
    @TrangThai NVARCHAR(50)
AS
BEGIN
    UPDATE DonHang
    SET TongTien = @TongTien, GhiChu = @GhiChu, DiaChi = @DiaChi, TrangThai = @TrangThai, NgayCapNhat = GETDATE()
    WHERE MaDonHang = @MaDonHang;
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateGioHang]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateGioHang]
    @MaGioHang INT,
    @SoLuong INT,
    @DonGia DECIMAL(18, 0),
    @DonVi NVARCHAR(10)
AS
BEGIN
    UPDATE GioHang
    SET SoLuong = @SoLuong, DonGia = @DonGia, TongTien = @SoLuong * @DonGia, DonVi = @DonVi
    WHERE MaGioHang = @MaGioHang;
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateQuyenTruyCap]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateQuyenTruyCap]
    @MaQuyen INT,
    @TenQuyen NVARCHAR(50)
AS
BEGIN
    UPDATE QuyenTruyCap
    SET TenQuyen = @TenQuyen
    WHERE MaQuyen = @MaQuyen;
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateThanhToan]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateThanhToan]
    @MaThanhToan INT,
    @TrangThaiThanhToan NVARCHAR(50),
    @SoTien DECIMAL(15, 2),
    @MaQR NVARCHAR(255) = NULL,
    @GhiChu NVARCHAR(255) = NULL
AS
BEGIN
    UPDATE ThanhToan
    SET TrangThaiThanhToan = @TrangThaiThanhToan, SoTien = @SoTien, MaQR = @MaQR, GhiChu = @GhiChu
    WHERE MaThanhToan = @MaThanhToan;
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateVaiTro]    Script Date: 10/18/2024 11:41:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateVaiTro]
    @MaVaiTro INT,
    @TenVaiTro NVARCHAR(50)
AS
BEGIN
    UPDATE VaiTro
    SET TenVaiTro = @TenVaiTro
    WHERE MaVaiTro = @MaVaiTro;
END;
GO
