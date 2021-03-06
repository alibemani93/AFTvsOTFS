function x_est = especial_2d_AFT_mp_detector(M, N, c0, c1, taps,delay_taps,Doppler_taps,chan_coef, y_2d_especial_AFT, sigma_2, sig_energy_sqrt)
N_CP        = max(delay_taps);
V_n_l       = zeros(M*N + N_CP);
G_n_l       = zeros(M*N + N_CP);
G_mat       = zeros(M*N);
x_est       = zeros(1, M*N);
F_N = (1/sqrt(N))*dftmtx(N);
F_M = (1/sqrt(M))*dftmtx(M);
%H_Channel_eq   = zeros(N_AFT);
for n = -N_CP:M*N-1
    for l = 0:taps-1%Number of Cluster
        A_i_n                           = chan_coef(l+1);% It can be RV
        f_i_n                           = Doppler_taps(l+1);
        G_n_l(n+N_CP+1, delay_taps(l+1)+1)   = A_i_n*exp(-1i*2*pi*f_i_n*n);
        V_n_l(n+N_CP+1, delay_taps(l+1)+1) = G_n_l(n+N_CP+1, delay_taps(l+1)+1)*exp(1i*2*pi*c1*(delay_taps(l+1)^2 - 2*n*delay_taps(l+1)) + 1i*2*pi*(c0*n));
        if n >=0
            G_mat(n+1 , mod(n-delay_taps(l+1), M*N) + 1) = V_n_l(n+N_CP+1, delay_taps(l+1)+1);
            %Coeff  = 1;
            %if ((n <= (N_CP)) && (mod(n-delay(l+1), N) >= N - N_CP))
            %   Coeff  = exp(-1i*2*pi*c1*(N^2 - 2*N*(N - mod(n-delay(l+1), N))));
            %end
            %H_Channel_eq(n+1 , mod(n-delay(l+1), N) + 1) = G_n_l(n+N_CP+1, delay(l+1)+1)*Coeff;
        end
    end
end
H_total_eq = kron(F_N, F_M)*G_mat*kron(F_N', F_M');
for i= 0:N-1
    H = H_total_eq(i*N+1:(i+1)*N, i*N+1:(i+1)*N);
    x_est(i*N+1:(i+1)*N) = H'*(H*H' +sigma_2/sig_energy_sqrt^2*eye(M))^(-1)*y_2d_especial_AFT(:, i+1);
end