classdef macrocell
  properties
      ID = [];
      pos = [];      
      txpow = [];
      height = [];
      txAntGain = [];
      rxAntGain = [];
      Bandwidth = [];
      freq = [];
      shadowing = [];
      CQImeasure_period = [];
      tcp_data_tmp = [];
      tcp_data = [];
      tcp_data_dl = [];
      tcp_data_ul = [];       
      txpckts_dl = [];
      rxpckts_ul = [];      
      txbits_dl = [];
      rxbits_ul = [];
      nPRBs = [];
      numerology = [];
      freq_ul = [];
      freq_dl = [];
      slot_time = [];
      lastserveduser_dl = [];
  end
end