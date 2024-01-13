module top(
    input           clk     ,
    input           rst_n   ,
    inout           dq      ,
    output          tx      ,
    output          pwm     ,
    output  [5:0]   sel     ,
    output  [7:0]   dig     ,
    input       [3:0]       key         ,
    output      [3:0]       led
);

    
    wire    [3:0]           key_out     ;
    wire    [15:0]          t_data      ;
    wire    [23:0]          dis_data    ;
    wire    [7:0]           t_data_uart ;       //通过串口模块发送到pc机

    parameter       time_1s =50_000_000;
    reg             [25:0]    cnt1;          //conter 计数50_000_000
    wire                      add_cnt1;     //计数器什么时候开始计数
    wire                      end_cnt1;     //计数器最大值
    //1s

    always @(posedge clk or negedge rst_n)begin 
        if(!rst_n)begin
            cnt1 <= 0;
        end 
        else if(add_cnt1)begin 
            if(end_cnt1)begin 
                cnt1 <= 26'b0;
            end
            else begin 
                cnt1 <= cnt1 + 1'b1;
            end 
        end
        else begin
            cnt1 <= cnt1 ;
        end
    end 
    assign add_cnt1 = 1'b1;
    assign end_cnt1 = add_cnt1 && cnt1 ==  time_1s - 1;

    assign  t_data_uart = end_cnt1 ? {1'b0,t_data[10:4]} : t_data_uart;  //当按键有效

    ds18b20_driver      inst_ds18b20_driver(
        .clk                (clk        ),
        .rst_n              (rst_n      ),
        .dq                 (dq         ),
        .t_data             (t_data     ) 
    );

    ctrl                inst_ctrl(
        .t_data             (t_data     ),
        .dis_data           (dis_data   ) ,
        .en                 (en)       
    );

    sel_driver          inst_sel_driver(
        .clk                (clk        ) ,
        .rst_n              (rst_n      ) ,
        .dis_data           (dis_data   ) ,
        .sel                (sel        ) ,
        .dig                (dig        )  
    );

    uart_tx             inst_uart_tx(

        .clk                (clk    ),
        .rst_n              (rst_n  ),
        .din                (t_data_uart    ),
        .din_vld            (end_cnt1),
        .dout               (tx   )
    );

    FSM_KEY             insr_FSM_KEY(
    
        .clk                (clk    ),
        .rst_n              (rst_n  ),
        .key_in             (key    ),
        .key_out            (key_out)        
    );

    key_led          inst_key_led(
        .clk                (clk       ),
        .rst_n              (rst_n     ),
        .key                (key_out   ),
        .led                (led       )
    );
    beep                inst_beep(

        .clk                (clk  ),
        .rst_n              (rst_n),
        .en                 (en   ),
        .pwm                (pwm  )
    );
endmodule