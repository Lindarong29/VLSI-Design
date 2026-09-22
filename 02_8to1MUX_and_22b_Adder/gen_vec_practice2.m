clear;
clc;

N = 100;           % the number of inputs and outputs
input_bit = 22;    % input  vector bitwidth
output_bit = 23;   % output vector bitwidth

% generate random numbers and quantize them
q_A = floor(rand(1, N)*power(2, input_bit))/power(2, input_bit);
q_B = floor(rand(1, N)*power(2, input_bit))/power(2, input_bit);

% make text files and write the vectors
int_A = q_A*power(2,input_bit);
A_in_hex = fopen('./a_input.txt', 'w');
for k = 1:N
    pr_A = int_A(k);
    fprintf(A_in_hex,'%x \n', pr_A);
end

int_B = q_B*power(2,input_bit);
B_in_hex = fopen('./b_input.txt', 'w');
for l = 1:N
    pr_B = int_B(l);
    fprintf(B_in_hex,'%x \n', pr_B);
end

int_Out = int_A + int_B;
Out_in_hex = fopen('./sum_output.txt', 'w');
for m = 1:N
    pr_Out = int_Out(m);
    fprintf(Out_in_hex,'%x \n', pr_Out);
end



