module Serialize = struct
  type t_packet = REQUEST | RESPONSE

  type t = {
    job_id : int;
    packet_type : t_packet;
    data : bytes;
  }

  let from_msg msg = {
    job_id = msg.job_id;
    packet_type = msg.packet_type;
    data = msg.data;
  }
  
  let to_msg id ptype data = {
    job_id = id;
    packet_type = ptype;
    data = data;
  }

  (** Transform packet into sendable network bytes message *)
  let to_bytes msg = Marshal.to_bytes msg []


  (** Transform bytes from network into readable structure *)
  let from_bytes buf = Marshal.from_bytes buf 0
    


end