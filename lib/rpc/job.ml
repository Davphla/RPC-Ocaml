open Unix

open Serialize.Serialize
open Serialize

(** A job is a promise of a distant work.
    It represent the exchange between the local actor, and the worker, the distant unit. *)
module Job = struct
  type status =
  | Waiting 
  | Running 
  | Done
  | Failed of exn

  (** TODO : Modify id int by uuid *)
  type t = {
      id : int;
      (** Data representing the procedure. *)
      data : bytes;
      addr : sockaddr;
      mutable status : status;
    }

  let unique_id = ref 0

  let mutex = Mutex.create ()
  let condition = Condition.create ()

  let waiting_jobs = Queue.create ()
  (** Protected with a mutex *)
  
  let running_jobs = Hashtbl.create 16

  let get_new_id addr = 
    let id = !unique_id in
    unique_id := id + 1;
    Hashtbl.hash (id, addr)

  let create_job data addr = 
    let id = get_new_id addr in
    { id = id;
      data = data; 
    addr = addr;
    status = Waiting}
  

  let add_new_job data addr = 
    let job = create_job data addr in
    Mutex.lock mutex;
    Queue.add job waiting_jobs;
    Condition.signal condition;
    Mutex.unlock mutex;;
  

  let add_running_job job = 
    Hashtbl.add running_jobs job.id job

  let remove_running_job job = 
    Hashtbl.remove running_jobs job.id
  
  let finish_job data = 
    let job = Hashtbl.find running_jobs data.id in
    job.status <- Done;
    remove_running_job job

  let process_msg (addr, msg) = 
    let process_response _ data = 
      finish_job data

    in 
    let process_request addr data = 
      let job = create_job data addr in
      add_running_job job
    in 
    let data = Serialize.from_bytes msg in

    match data.packet_type with 
    | RESPONSE -> process_response addr data
    | REQUEST -> process_request addr data.data
  
    
end