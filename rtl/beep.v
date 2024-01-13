module beep#(parameter CLK_PRE = 50_000_000, TIME_300MS = 15_000_000)(
    input           clk     ,
    input           rst_n   ,
    input           en      ,
    output reg      pwm
);
    //频率控制音色 ，占空比控制音量 ，占空比越大，低电平越少，音量越小

    parameter   DO = CLK_PRE / 523,     // DO的周期所需要的系统时钟周期个数
                RE = CLK_PRE / 587,
                MI = CLK_PRE / 659,
                FA = CLK_PRE / 698,
                SO = CLK_PRE / 784,
                LA = CLK_PRE / 880,
                SI = CLK_PRE / 988;

    reg         [16:0]      cnt1    ;   //计数频率
    wire                    add_cnt1;
    wire                    end_cnt1;
    reg         [16:0]      X       ;   //cnt1最大值

    reg         [23:0]      cnt2    ;   //计数每个音符发声300ms
    wire                    add_cnt2;
    wire                    end_cnt2;

    reg         [5:0]       cnt3    ;   //计数乐谱48
    wire                    add_cnt3;
    wire                    end_cnt3;

    reg                     ctrl    ;   //后25%消音

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cnt1 <= 17'b0;
        end
        else if(end_cnt2)begin
            cnt1 <= 17'b0;
        end
        else if(add_cnt1)begin
            if(end_cnt1)begin
                cnt1 <= 17'b0;
            end
            else begin
                cnt1 <= cnt1 + 1'b1;
            end
        end
        else begin
            cnt1 <= cnt1;
        end 
    end

    assign add_cnt1 = en;
    assign end_cnt1 = add_cnt1 && cnt1 == X - 1;

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cnt2 <= 24'b0;
        end
        else if(add_cnt2)begin
            if(end_cnt2)begin
                cnt2 <= 24'b0;
            end
            else begin
                cnt2 <= cnt2 + 1'b1;
            end
        end
        else begin
            cnt2 <= cnt2;
        end
    end 

    assign add_cnt2 = en;
    assign end_cnt2 = add_cnt2 && cnt2 == TIME_300MS -1;

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cnt3 <= 6'b0;
        end
        else if(add_cnt3)begin
            if(end_cnt3)begin
                cnt3 <= 24'b0;
            end
            else begin
                cnt3 <= cnt3 + 1'b1;
            end
        end
        else begin
            cnt3 <= cnt3;
        end
    end 

    assign add_cnt3 = end_cnt2;
    assign end_cnt3 = add_cnt3 && cnt3 == 48 - 1;


    always @(*)begin
        case(cnt3)
        0   :   X = DO;       
        1   :   X = RE;  
        2   :   X = MI;  
        3   :   X = DO;  

        4   :   X = DO;  
        5   :   X = RE;  
        6   :   X = MI;  
        7   :   X = DO;  

        8   :   X = MI;    
        9   :   X = FA;    
        10  :   X = SO;
        11  :   X = SO;

        12  :   X = MI;
        13  :   X = FA;
        14  :   X = SO;
        15  :   X = SO;

        16  :   X = SO;
        17  :   X = LA;
        18  :   X = SO;
        19  :   X = FA;

        20  :   X = MI;
        21  :   X = MI;
        22  :   X = DO;
        23  :   X = DO;

        24  :   X = SO;
        25  :   X = LA;
        26  :   X = SO;
        27  :   X = FA;

        28  :   X = MI;
        29  :   X = MI;
        30  :   X = DO;
        31  :   X = DO;

        32  :   X = RE;
        33  :   X = RE;
        34  :   X = DO;
        35  :   X = DO;

        36  :   X = DO;
        37  :   X = DO;
        38  :   X = 1 ;
        39  :   X = 1 ;

        40  :   X = RE;
        41  :   X = RE;
        42  :   X = DO;
        43  :   X = DO;

        44  :   X = DO;
        45  :   X = DO;
        46  :   X = 1 ;
        47  :   X = 1 ;
        default : X = 1;
        endcase
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            ctrl <= 1'b0;
        end
        else if(cnt2 >= ((TIME_300MS >> 1) + (TIME_300MS >>2)))begin
            ctrl <= 1'b1;
        end
        else if(X == 1)begin
            ctrl <= 1'b1;
        end
        else begin
            ctrl <= 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            pwm <= 1'b1;
        end
        else if(ctrl)begin
            pwm <= 1'b1;
        end
        else if(en && (cnt1 < (X >> 4)))begin
            pwm <= 1'b0;
        end
        else begin
            pwm <= 1'b1;
        end
    end


endmodule