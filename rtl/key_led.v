module key_led(
    input               clk     ,
    input               rst_n   ,
    input       [3:0]   key     ,
    output  reg [3:0]   led         
);

    parameter TIME_500MS = 25_000_000;

    reg     [24:0]      cnt     ;
    wire                add_cnt ;
    wire                end_cnt ;

    reg     [3:0]       flag    ;
//实现按键自锁
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            flag <= 4'b0000;
        end
        else if(key == 4'b0001)begin
            flag <= 4'b0001;
        end
        else if(key == 4'b0100)begin
            flag <= 4'b0100;
        end
        else begin
            flag <= flag;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cnt <= 25'b0;
        end
        else if(add_cnt)begin
            if(end_cnt)begin
                cnt <= 25'b0;
            end
            else begin
                cnt <= cnt + 1'b1;
            end
        end
        else begin
            cnt <= cnt;
        end
    end

    assign add_cnt = 1'b1;
    assign end_cnt = add_cnt && cnt == TIME_500MS - 1;


    //第一个按键 自左向右流水单 第二个按键 自右向左流水灯 第三个按键 亮灭 第四个按键 跑马灯
    //若要实现按键自锁，将条件led换成flag
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            led <= 4'b0000;
        end
        else begin
            case(flag)
                4'b0001 :   if(end_cnt)
                                led <= 4'b0001;
                            else 
                                led <= led;
                4'b0100 :   if(end_cnt)
                                led <= 4'b0000;
                            else 
                                led <= led;
                default :   led <= led;
            endcase
        end     
    end


endmodule