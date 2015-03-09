//Legal Notice: (C)2015 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

///** This Verilog HDL file is used for synthesis in chaining DMA design example
//*
//* This file provides the top level for synthesis
//*/
module pcie_c4_1x_example_chaining_top (
                                         // inputs:
                                          free_100MHz,
                                          local_rstn_ext,
                                          pcie_rstn,
                                          refclk,
                                          req_compliance_push_button_n,
                                          rx_in0,
                                          usr_sw,

                                         // outputs:
                                          L0_led,
                                          alive_led,
                                          comp_led,
                                          lane_active_led,
                                          tx_out0
                                       )
;

  output           L0_led;
  output           alive_led;
  output           comp_led;
  output  [  3: 0] lane_active_led;
  output           tx_out0;
  input            free_100MHz;
  input            local_rstn_ext;
  input            pcie_rstn;
  input            refclk;
  input            req_compliance_push_button_n;
  input            rx_in0;
  input   [  7: 0] usr_sw;

  reg              L0_led;
  reg     [ 24: 0] alive_cnt;
  reg              alive_led;
  wire             any_rstn;
  reg              any_rstn_r /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R102"  */;
  reg              any_rstn_rr /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R102"  */;
  wire             clk_out_buf;
  reg              comp_led;
  reg     [  3: 0] lane_active_led;
  wire             local_rstn;
  wire    [  3: 0] open_lane_width_code;
  wire    [  3: 0] open_phy_sel_code;
  wire    [  3: 0] open_ref_clk_sel_code;
  wire             phystatus_ext;
  wire    [  1: 0] powerdown_ext;
  wire             req_compliance_soft_ctrl;
  wire    [  7: 0] rxdata0_ext;
  wire             rxdatak0_ext;
  wire             rxelecidle0_ext;
  wire             rxpolarity0_ext;
  wire    [  2: 0] rxstatus0_ext;
  wire             rxvalid0_ext;
  wire             safe_mode;
  wire             set_compliance_mode;
  wire    [ 39: 0] test_in;
  wire             test_in_32_hip;
  wire             test_in_5_hip;
  wire    [  8: 0] test_out_icm;
  wire             tx_out0;
  wire             txcompl0_ext;
  wire    [  7: 0] txdata0_ext;
  wire             txdatak0_ext;
  wire             txdetectrx_ext;
  wire             txelecidle0_ext;
  assign safe_mode = 1;
  assign local_rstn = safe_mode | local_rstn_ext;
  assign any_rstn = pcie_rstn & local_rstn;
  assign test_in[39 : 33] = 0;
  assign set_compliance_mode = usr_sw[0];
  assign req_compliance_soft_ctrl = 0;
  assign test_in[32] = test_in_32_hip;
  assign test_in[31 : 9] = 0;
  assign test_in[8 : 6] = safe_mode ? 4'b010 : usr_sw[3 : 1];
  assign test_in[5] = test_in_5_hip;
  assign test_in[4 : 0] = 5'b01000;
  //reset Synchronizer
  always @(posedge clk_out_buf or negedge any_rstn)
    begin
      if (any_rstn == 0)
        begin
          any_rstn_r <= 0;
          any_rstn_rr <= 0;
        end
      else 
        begin
          any_rstn_r <= 1;
          any_rstn_rr <= any_rstn_r;
        end
    end


  //LED logic
  always @(posedge clk_out_buf or negedge any_rstn_rr)
    begin
      if (any_rstn_rr == 0)
        begin
          alive_cnt <= 0;
          alive_led <= 0;
          comp_led <= 0;
          L0_led <= 0;
          lane_active_led <= 0;
        end
      else 
        begin
          alive_cnt <= alive_cnt +1;
          alive_led <= alive_cnt[24];
          comp_led <= ~(test_out_icm[4 : 0] == 5'b00011);
          L0_led <= ~(test_out_icm[4 : 0] == 5'b01111);
          lane_active_led[3 : 0] <= ~(test_out_icm[8 : 5]);
        end
    end


  altpcierd_compliance_test pcie_compliance_test_enable
    (
      .local_rstn (local_rstn_ext),
      .pcie_rstn (pcie_rstn),
      .refclk (refclk),
      .req_compliance_push_button_n (req_compliance_push_button_n),
      .req_compliance_soft_ctrl (req_compliance_soft_ctrl),
      .set_compliance_mode (set_compliance_mode),
      .test_in_32_hip (test_in_32_hip),
      .test_in_5_hip (test_in_5_hip)
    );


  pcie_c4_1x_example_chaining_pipen1b core
    (
      .core_clk_out (clk_out_buf),
      .free_100MHz (free_100MHz),
      .lane_width_code (open_lane_width_code),
      .local_rstn (local_rstn),
      .pcie_rstn (pcie_rstn),
      .phy_sel_code (open_phy_sel_code),
      .phystatus_ext (phystatus_ext),
      .pipe_mode (1'b0),
      .pld_clk (clk_out_buf),
      .powerdown_ext (powerdown_ext),
      .ref_clk_sel_code (open_ref_clk_sel_code),
      .refclk (refclk),
      .rx_in0 (rx_in0),
      .rxdata0_ext (rxdata0_ext),
      .rxdatak0_ext (rxdatak0_ext),
      .rxelecidle0_ext (rxelecidle0_ext),
      .rxpolarity0_ext (rxpolarity0_ext),
      .rxstatus0_ext (rxstatus0_ext),
      .rxvalid0_ext (rxvalid0_ext),
      .test_in (test_in),
      .test_out_icm (test_out_icm),
      .tx_out0 (tx_out0),
      .txcompl0_ext (txcompl0_ext),
      .txdata0_ext (txdata0_ext),
      .txdatak0_ext (txdatak0_ext),
      .txdetectrx_ext (txdetectrx_ext),
      .txelecidle0_ext (txelecidle0_ext)
    );



endmodule

