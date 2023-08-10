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

  let create_worker addr = 
    let fd = Transport.create_client addr in
    let w = {
    client_fd = fd;
    addr = addr;
    status = `Idle;
    } in 
    Hashtbl.add workers fd w;
    w;;

  let add_worker fd addr =
    let w = {
    client_fd = fd;
    addr = addr;
    status = `Idle;
    } in 
    Hashtbl.add workers fd w;; 

  let get_worker fd = Hashtbl.find workers fd;;

  let get_worker_from_addr addr = 
    let w = Hashtbl.fold (fun _ w acc -> 
      if w.addr = addr then
        Some w
      else
        acc
    ) workers None in
    match w with
    | Some w -> w
    | None -> create_worker addr;;

  let remove_worker fd = Hashtbl.remove workers fd;;

  let get_fds () = 
    let fds = Hashtbl.fold (fun _ w acc -> w.client_fd :: acc) workers [] in
    Transport.server :: fds


end


module Network = struct
  
  (** Poll the server and the workers for incoming messages *)
  let poll_server () =
    let receive_req fd =
      let msg = Bytes.create 128 in
      let (fd, addr) = Unix.accept fd in
        Workers.add_worker fd addr;
        let _ = Unix.recv fd msg 0 128 [] in
        (addr, msg)
    in
    let receive_res fd = 
      let msg = Bytes.create 128 in
      let _ = Unix.recv fd msg 0 128 [] in
      let addr = (Workers.get_worker fd).addr in
      (addr, msg)
    in
    let fds = Workers.get_fds () in
    
    let (r, _, _) = Unix.select fds [] [] 0. in
    List.map (fun fd -> 
      if fd = Transport.server then
        receive_req fd
      else
        receive_res fd
    ) r;;
  
  (** Use to send a message to a remote unit *)
  let send_msg_to_worker addr msg = 
    let w = Workers.get_worker_from_addr addr in
    Transport.send_msg w.client_fd msg;;
    
end