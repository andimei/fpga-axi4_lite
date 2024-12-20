`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.11.2024 09:53:38
// Design Name: 
// Module Name: tb_axi_slave
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_axi_slave;

  // Parameter
  parameter C_S00_AXI_ADDR_WIDTH = 5;
  parameter C_S00_AXI_DATA_WIDTH = 32;

  // Inputs
  reg s00_axi_aclk;
  reg s00_axi_aresetn;
  reg [C_S00_AXI_ADDR_WIDTH-1:0] s00_axi_awaddr;
  reg [2:0] s00_axi_awprot;
  reg s00_axi_awvalid;
  reg [C_S00_AXI_DATA_WIDTH-1:0] s00_axi_wdata;
  reg [(C_S00_AXI_DATA_WIDTH/8)-1:0] s00_axi_wstrb;
  reg s00_axi_wvalid;
  reg s00_axi_bready;
  reg [C_S00_AXI_ADDR_WIDTH-1:0] s00_axi_araddr;
  reg [2:0] s00_axi_arprot;
  reg s00_axi_arvalid;
  reg s00_axi_rready;

  // Outputs
  wire s00_axi_awready;
  wire s00_axi_wready;
  wire [1:0] s00_axi_bresp;
  wire s00_axi_bvalid;
  wire s00_axi_arready;
  wire [C_S00_AXI_DATA_WIDTH-1:0] s00_axi_rdata;
  wire [1:0] s00_axi_rresp;
  wire s00_axi_rvalid;

  wire [C_S00_AXI_DATA_WIDTH-1:0] slv_reg0;
  wire [C_S00_AXI_DATA_WIDTH-1:0] slv_reg1;
  wire [C_S00_AXI_DATA_WIDTH-1:0] slv_reg2;
  wire [C_S00_AXI_DATA_WIDTH-1:0] slv_reg3;
  wire [C_S00_AXI_DATA_WIDTH-1:0] slv_reg4;
  wire [C_S00_AXI_DATA_WIDTH-1:0] slv_reg5;
  wire [C_S00_AXI_DATA_WIDTH-1:0] slv_reg6;
  reg [31:0] read_data;  // Variabel untuk menyimpan hasil pembacaan

  // Instantiate DUT (Device Under Test)
  axi_lite_slave #(
      .C_S00_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH),
      .C_S00_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH)
  ) dut (
      .s00_axi_aclk(s00_axi_aclk),
      .s00_axi_aresetn(s00_axi_aresetn),
      .s00_axi_awaddr(s00_axi_awaddr),
      .s00_axi_awprot(s00_axi_awprot),
      .s00_axi_awvalid(s00_axi_awvalid),
      .s00_axi_awready(s00_axi_awready),
      .s00_axi_wdata(s00_axi_wdata),
      .s00_axi_wstrb(s00_axi_wstrb),
      .s00_axi_wvalid(s00_axi_wvalid),
      .s00_axi_wready(s00_axi_wready),
      .s00_axi_bresp(s00_axi_bresp),
      .s00_axi_bvalid(s00_axi_bvalid),
      .s00_axi_bready(s00_axi_bready),
      .s00_axi_araddr(s00_axi_araddr),
      .s00_axi_arprot(s00_axi_arprot),
      .s00_axi_arvalid(s00_axi_arvalid),
      .s00_axi_arready(s00_axi_arready),
      .s00_axi_rdata(s00_axi_rdata),
      .s00_axi_rresp(s00_axi_rresp),
      .s00_axi_rvalid(s00_axi_rvalid),
      .s00_axi_rready(s00_axi_rready),
      .slv_reg0(slv_reg0),
      .slv_reg1(slv_reg1),
      .slv_reg2(slv_reg2),
      .slv_reg3(slv_reg3),
      .slv_reg4(slv_reg4),
      .slv_reg5(slv_reg5),
      .slv_reg6(slv_reg6)
  );

  // Clock Generation
  initial begin
    s00_axi_aclk = 0;
    forever #5 s00_axi_aclk = ~s00_axi_aclk;
  end

  // Reset Initialization
  initial begin
    s00_axi_aresetn = 0;
    #20 s00_axi_aresetn = 1;
  end

  // Task untuk operasi write pada AXI Lite
  // Task ini mengatur alamat, data, dan kontrol validitas pada sinyal AXI Lite,
  // kemudian menunggu respon dari slave untuk menyelesaikan transaksi.
  task axi_write;
    input [31:0] write_address;  // Alamat write
    input [31:0] write_data;  // Data yang akan ditulis
    input [3:0] write_strobe;  // Byte strobe (menentukan byte yang valid)

    begin
      // Step 1: Set alamat dan data pada saat yang sama
      @(posedge s00_axi_aclk);
      s00_axi_awaddr  = write_address;  // Mengatur alamat tujuan penulisan
      s00_axi_awvalid = 1;  // Menyatakan alamat valid
      s00_axi_wdata   = write_data;  // Mengatur data yang akan ditulis
      s00_axi_wvalid  = 1;  // Menyatakan data valid
      s00_axi_wstrb   = write_strobe;  // Mengatur byte strobe

      // Step 2: Tunggu hingga slave siap menerima alamat dan data
      @(posedge s00_axi_aclk);
      while (!(s00_axi_awready && s00_axi_wready))
        @(posedge s00_axi_aclk);  // Loop hingga awready dan wready aktif

      // Step 3: Tunggu respon tulis (bvalid dari slave)
      @(posedge s00_axi_aclk);
      wait (s00_axi_bvalid);  // Menunggu slave menyatakan respon valid
      s00_axi_awvalid = 0;  // Reset sinyal awvalid setelah diterima
      s00_axi_wvalid  = 0;  // Reset sinyal wvalid setelah diterima
      s00_axi_bready  = 1;  // Menyatakan master siap menerima respon
      #10;
      s00_axi_bready = 0;  // Reset bready untuk mengakhiri transaksi
    end
  endtask
  
  // Task untuk operasi read pada AXI Lite
  task axi_read;
    input [31:0] read_address;    // Alamat yang akan dibaca
    output [31:0] read_data;      // Data hasil pembacaan

    begin
        // Step 1: Set alamat read
        @(posedge s00_axi_aclk);
        s00_axi_araddr  = read_address;  // Mengatur alamat tujuan pembacaan
        s00_axi_arvalid = 1;            // Menyatakan alamat valid

        // Step 2: Tunggu hingga slave siap menerima alamat
        @(posedge s00_axi_aclk);
        while (!s00_axi_arready)
            @(posedge s00_axi_aclk);  // Loop hingga arready aktif

        // Step 3: Tunggu data valid dari slave
        @(posedge s00_axi_aclk);
        s00_axi_arvalid = 0;  // Reset sinyal arvalid setelah diterima
        wait (s00_axi_rvalid);  // Menunggu slave menyatakan data valid

        // Step 4: Ambil data dari bus
        read_data = s00_axi_rdata;  // Mengambil data dari slave
        s00_axi_rready = 1;        // Menyatakan master siap menerima data
        #10;
        s00_axi_rready = 0;        // Reset rready untuk mengakhiri transaksi
    end
endtask


  // Test Scenarios
  initial begin
    // Initialize inputs
    s00_axi_awaddr  = 0;
    s00_axi_awprot  = 0;
    s00_axi_awvalid = 0;
    s00_axi_wdata   = 0;
    s00_axi_wstrb   = 0;
    s00_axi_wvalid  = 0;
    s00_axi_bready  = 0;
    s00_axi_araddr  = 0;
    s00_axi_arprot  = 0;
    s00_axi_arvalid = 0;
    s00_axi_rready  = 0;

    #50;  // Wait for reset

    // Operasi Write
    axi_write(32'h00000000, 32'hCABECABE, 4'b1111);
    axi_write(32'h00000004, 32'hCAFEBABE, 4'b1111);
    axi_write(32'h00000008, 32'hDEADBEEF, 4'b1111);
    axi_write(32'h00000008, 32'h12345678, 4'b1010);

    // Operasi Read
    axi_read(32'h00000000, read_data);
    $display("Read Data from 0x00000000: 0x%08X", read_data);

    axi_read(32'h00000004, read_data);
    $display("Read Data from 0x00000004: 0x%08X", read_data);

    axi_read(32'h00000008, read_data);
    $display("Read Data from 0x00000008: 0x%08X", read_data);

    // Finish simulation
    #20;
    $stop;
  end
endmodule
