%% End-to-End IEEE 802.15.4 PHY Simulation
% This example shows how to generate waveforms, decode waveforms and
% compute BER curves for different PHY specifications of the IEEE(R)
% 802.15.4(TM) standard [ <#5 1>], using the Communications Toolbox(TM)
% Library for the ZigBee(R) Protocol.

% Copyright 2017-2018 The MathWorks, Inc.

%% Background
% The *IEEE 802.15.4* standard specifies the *PHY* and *MAC* layers of Low-Rate
% Wireless Personal Area Networks (*LR-WPANs*) [ <#5 1> ]. The IEEE 802.15.4
% PHY and MAC layers provide the basis of other higher-layer standards,
% such as *ZigBee*, WirelessHart(R), 6LoWPAN and MiWi. Such standards find
% application in home automation and sensor networking and are highly
% relevant to the Internet of Things (IoT) trend.

%% Physical Layer Implementations of IEEE 802.15.4
% The original IEEE 802.15.4 standard and its amendments specify multiple
% PHY layers, which use different modulation schemes and support different
% data rates. These physical layers were devised for specific frequency
% bands and, to a certain extent, for specific countries. This example
% provides functions that generate and decode waveforms for the physical
% layers proposed in the original IEEE 802.15.4 specification (OQPSK in 2.4
% GHz, BPSK in 868/915 MHz), IEEE 802.15.4b (OQPSK and ASK in 868/915 MHz),
% IEEE 802.15.4c (OQPSK in 780 MHz) and IEEE 802.15.4d (GFSK and BPSK in
% 950 MHz).
%
% These physical layers specify a format for the PHY protocol data unit
% (PPDU) that includes a preamble, a start-of-frame delimiter (SFD), and
% the length and contents of the MAC protocol data unit (MPDU). The
% preamble and SFD are used for frame-level synchronization. In the
% following description, the term symbol denotes the integer index of a
% chip sequence (as per the IEEE 802.15.4 standard), not a modulation
% symbol (i.e., a complex number).
%
% * *OQPSK PHY*: All OQPSK PHYs map every 4 PPDU bits to one symbol. The
% 2.4 GHz OQPSK PHY spreads each symbol to a 32-chip sequence, while the
% other OQPSK PHYs spread it to a 16-chip sequence. Then, the chip
% sequences are OQPSK modulated and passed to a half-sine pulse shaping
% filter (or a normal raised cosine filter, in the 780 MHz band). For a
% detailed description, see Clause 10 in [ <#5 1> ].
%

%% Waveform Generation, Decoding and BER Curve Calculation
% This code illustrates how to use the waveform generation and
% decoding functions for different frequency bands and compares the
% corresponding BER curves.

EcNo = -25:2.5:17.5;                % Ec/No range of BER curves
spc = 4;                            % samples per chip
msgLen = 8*120;                     % length in bits
message = randi([0 1], msgLen, 1);  % transmitted message

% Preallocate vectors to store BER results:
[berOQPSK2450] = deal(zeros(1, length(EcNo)));

for idx = 1:length(EcNo) % loop over the EcNo range
  
  % O-QPSK PHY, 2450 MHz  
  waveform = lrwpan.PHYGeneratorOQPSK(message, spc, '2450 MHz');
  K = 2;      % information bits per symbol
  SNR = EcNo(idx) - 10*log10(spc) + 10*log10(K);
  received = awgn(waveform, SNR);
  bits     = lrwpan.PHYDecoderOQPSKNoSync(received,  spc, '2450 MHz');
  [~, berOQPSK2450(idx)] = biterr(message, bits);

 
end

% plot BER curve
figure
semilogy(EcNo, berOQPSK2450, '-o')
legend('OQPSK, 2450 MHz', 'Location', 'southwest')
title('IEEE 802.15.4 PHY BER Curves')
xlabel('Chip Energy to Noise Spectral Density, Ec/No (dB)')
ylabel('BER')
axis([min(EcNo) max(EcNo) 10^-2 1])
grid on

