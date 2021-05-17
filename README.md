# 5G-Flow-RAN

We present a 5G multi-RAT system level simulator, developed in MATLAB (v2020a). This simulator is designed for investigating the performance of dataflow management across multiple RATs.

The simulator has been developed at IIT Bombay and is shared under MIT license.

The simulator supports multiple RATs, i.e., gNB-NR and Wi-Fi, and we describe the implementation of physical and MAC layers of these RATs. We also discuss the implementation of the application and transport layer, which both the RATs share. Moreover, a centralized controller has been implemented that manages these RATs. The simulator supports downlink as well as the uplink communication channel.

Initialization: This step involves initializing all the necessary parameters for both gNB-NR and Wi-Fi RATs. Based on the initialized parameters, network nodes comprising gNB-NR, Wi-Fi APs, and UEs are generated. Geographic locations are assigned to these network nodes, which determines the network layout. The network nodes remain stationary for the entire simulation. We aim to enhance the simulator to support mobility in future.

Preprocessing: Before simulation starts, a UE must be associated with a RAT(s). For this, we run a RAT selection algorithm. The RAT selected for a user remains constant for the entire simulation. 

Simulation Loop: We have developed a time slot based simulator, wherein the simulation timeline is divided into time slots. We use Time Division Duplex (TDD) that allows uplink and downlink transmission over the same frequency band but over different time slots. The uplink and downlink channels are quite similar, with minor differences in physical layer implementation. We have implemented a transmitter and a receiver process at the network side as well as at every UE. To transmit data at the network side on the downlink communication channel, the send data() process is invoked. Similarly, send data() process runs at every UE to send data on the uplink channel. The send data() process implements the application, transport, MAC, and physical layers of both the RATs. The network stack implementation is explained in detail in the following subsection. In parallel, receive data() function, at the network side and every UE, processes the data that has been successfully
received.

Postprocessing: Once the simulation is complete, all the key attributes such as TCP throughput of individual RATs, total TCP throughput, and packet delay are analyzed. We define packet delay as the total time it takes for a packet to reach its destination node from the source node.


For more details please refer to our paper. 

Meghna Khaturia, Pranav Jha, and Abhay Karandikar. “5G-Flow: Flexible and Efficient 5G RAN Architecture Using OpenFlow,” https://arxiv.org/abs/2010.07528.
