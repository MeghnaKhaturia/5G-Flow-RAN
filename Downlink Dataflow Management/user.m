classdef user
  properties
      ID = [];
      attach = [];
      pos = [];  
      txpow = [];
      txpow_wifi = [];
      registered = [];
      rxsensitivity = [];
      snr_ul = -20;
      snr_dl = -20;
      mobility = [];
      height = [];
      txAntGain = [];
      rxAntGain = [];
      rat = [];
      service_type = [];
         
      tcp_data_dl = [];
      txbits_dl = [];
      rxbits_dl = [];
      rxpckts_dl = [];
      txpckts_dl = [];
      
     
      tcp_data_ul = [];      
      txbits_ul = [];
      rxbits_ul = [];
      rxpckts_ul = [];
      txpckts_ul = [];
      packet_loss = 0;
      delay_dl = [];
      count = 0;
      
      
  end
end