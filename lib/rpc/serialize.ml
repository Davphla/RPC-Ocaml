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

  let to_bytes _msg =
    ()

  let from_bytes _buf =
    ()


end