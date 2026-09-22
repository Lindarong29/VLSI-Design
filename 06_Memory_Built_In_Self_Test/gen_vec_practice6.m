clear;
clc;

N = 1024;           % the number of inputs and outputs
input_bit = 22;    % input  vector bitwidth
output_bit = 44;   % output vector bitwidth

% generate random numbers and quantize them
q_A = floor(rand(1, N)*power(2, input_bit))/power(2, input_bit);
q_B = floor(rand(1, N)*power(2, input_bit))/power(2, input_bit);

% make text files and write the vectors
int_A = uint64(q_A*power(2,input_bit));
int_B = uint64(q_B*power(2,input_bit));

int_A_temp = int_A * power(2, input_bit);
input_set = int_A_temp + int_B;

in_hex = fopen('./input.txt', 'w');
for k = 1:N
    pr_A = input_set(k);
    fprintf(in_hex,'%x \n', pr_A);
end


int_Out = int_A .* int_B;
Out_in_hex = fopen('./output.txt', 'w');
for m = 1:N
    pr_Out = int_Out(m);
    fprintf(Out_in_hex,'%x \n', pr_Out);
end

%clear