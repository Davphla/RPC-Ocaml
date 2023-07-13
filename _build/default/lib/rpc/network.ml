open Unix


(** Hardcoded for the moment *)
let c_ip_addr = "127.0.0.1";;

(** Transport module to send and receive messages between entities *)
module Transport = struct
  let create_socket () = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0;;
  
  (** Create a client and assign a random local port to it *)
  let create_client addr = let s = create_socket () in
    Unix.connect s addr;
    s

  let send_msg sock msg = let len = Bytes.length msg in
    send sock msg 0 len []

  let server = let s = create_socket () in 
    Unix.bind s (Unix.ADDR_INET (Unix.inet_addr_of_string c_ip_addr , 0));
    Unix.listen s 1;
    s
end


(** Remote entities *working* for the local executor.
    An executor may have an orphant worker. *) 
module Workers = struct

  (** Redo the memory structure to align client sock for a great select use. *)
  type t_worker = {
    client_fd : file_descr;
    addr : sockaddr;
    (** Wont be used for the moment *)
    mutable status : [`Idle | `Working | `Dead];
  }

  (** Keys are defined by socket address. Each workers are unique. *)
  let workers = Hashtbl.create 16

  let get_fds () = 
    let fds = Hashtbl.fold (fun _ w acc -> w.client_fd :: acc) workers [] in
    Transport.server :: fds;;
 
  let get_id addr = Hashtbl.hash addr;;

  let add_worker fd sockaddr =
    let create_worker = {
      client_fd = fd;
      addr = sockaddr;
      status = `Idle;
      }
    in

    let w = create_worker in
      Hashtbl.add workers w.addr w;;

  let remove_worker addr = Hashtbl.remove workers addr;;

  let get_worker addr = Hashtbl.find workers addr;;
end


module Network = struct
  open Serialize
  open Job
  
  (** Poll the server and the workers for incoming messages *)
  let poll_server () =
    let accept_new_client fd =
      let msg = Bytes.create 128 in
      let (fd, addr) = Unix.accept fd in
        Workers.add_worker fd addr;
        let _ = Unix.recv fd msg 0 128 [] in
        msg
    in
    let new_transfer fd = 
      let msg = Bytes.create 128 in
      let _ = Unix.recv fd msg 0 128 [] in
      msg
    in
    let fds = Workers.get_fds () in
    
    let (r, _, _) = Unix.select fds [] [] 0. in
    List.map (fun fd -> 
      if fd = Transport.server then
        accept_new_client fd
      else
        new_transfer fd
    ) r;;
  
  let process_msg msg = 
    let process_response msg = () in 
    let process_request msg = () in 

    let data = Serialize.from_msg msg in
    match Job.packet_type  with 
    | RESPONSE -> process_response data
    | REQUEST -> process_request data

  
  (** Use to send a message to a remote unit *)
  let send_msg_to_worker addr msg = 
    let w = Hashtbl.find Workers.workers addr in
    Transport.send_msg w.client_fd msg;;
    
end