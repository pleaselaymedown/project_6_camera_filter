`timescale 1ns / 1ps

module rst_and (
    input  rstn,
    input  locked,
    input  init_done,
    output rstn_capture,   // rstn && locked && init_done → capture용
    output rstn_basic      // rstn && locked              → 나머지용
);
    assign rstn_basic   = rstn & locked;
    assign rstn_capture = rstn & locked & init_done;
endmodule
