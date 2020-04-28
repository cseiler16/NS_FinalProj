%Calculates BER(Bit Error Rate) for QPSK 2.4 Ghz through the toolbox for a
%variety of different energy per bit to noise power(normalized SNR)
clear;
close all;
%Referncing Zigbee Throughput Analysis paper
symbol_rate = 62500; %symbols/sec
app_payload = 101; %bytes/packet

%time required to transverse CSMA-CA algorithm
symbols_CSMA_CA = 97.31; %Calculations for this referenced in paper, based
%channel access timings

length_PPDU = 133; %bytes
length_symbol = 4; %bits/symbol
symbols_tx = (length_PPDU * 8)/length_symbol; %symbols transmission time

%ACK Timing
symbols_ackturn = 12; %symbols, defined as time to transmit an ack

%ACK transmission time
symbols_tx_ack = 11*8/4; %5 bytes MAC header, 6 bytes PHY header

%IFS timing
symbols_IFS = 40; %symbols

%total transmission time

symbols_total = symbols_CSMA_CA + symbols_tx + symbols_ackturn + symbols_tx_ack + symbols_IFS;
symbols_total_noack = symbols_CSMA_CA + symbols_tx + symbols_IFS;
symbols_resend = symbols_tx_ack + symbols_tx_ack;
packets_sec = symbol_rate/symbols_total; %packets per second
packets_sec_noack = symbol_rate/symbols_total_noack;
packets_sec_resend = symbol_rate/symbols_resend;

throughput_kbps = app_payload * 8 * packets_sec; %App payload * 8 bits/byte * packets_second;
throughput_kbps_noack = app_payload * 8 * packets_sec_noack;
throughput_kbps_resend = app_payload*8*packets_sec_resend;

%maximum throughput for single hop transmission in a lightly loaded, non-beacon enabled PAN
%is approximately 115.5kbps

%This does not include any errors

BERCalc
%berOQPSK2450 is variable that contains values

%We will use BER where EC/N0 is close to -1.95 dB
%This is a reasonable EC/N0 for maximizing 
BER = berOQPSK2450(10);

throughput_BER = throughput_kbps*(1-BER); %Throughput with bit errors and no resending
throughput_BER_noack = throughput_kbps_noack*(1-BER);

packets_sec_lost = ceil((packets_sec*BER)); %Packets lost per second, rounded up
%assumption that 1 bit error is a failed packet

%assumption that we resend packets
throughput_BER_resend = (throughput_kbps*.99) - (throughput_kbps_resend*.01);

throughputs = [throughput_kbps, throughput_kbps_noack, throughput_BER, throughput_BER_noack, throughput_BER_resend];
figure(2)


bar(throughputs);
ylabel('Throughput (Kbps)');
xlabel('Options');
options = {'Throughput','Throughput no ack','w/ BER','Throughput w/ BER w/ No Ack','Throughput w/ BER w/ Resend' };
legend(options,'location','northeast');

