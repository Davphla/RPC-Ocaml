module Serialize = struct
  type t_packet = REQUEST | RESPONSE

  type t = {
    job_id : int;
    packet_type : t_packet;
    data : bytes;
  }

  let from_msg data =  {
    job_id = data.job_id;
    packet_type = data.packet_type;
    data = data.data;
  }
  
  let to_msg id ptype data = {
    job_id = id;
    packet_type = ptype;
    data = data;
  }


end