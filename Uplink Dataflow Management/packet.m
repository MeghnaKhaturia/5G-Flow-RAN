classdef packet
  properties
      org_size = [];
      size = [];
      payload_size = [];
      source = [];
      destination = [];
      seq_no = [];
      ack = 0;
      lost = 0;
      type = 0;
      gen_time = 0;
  end  
end