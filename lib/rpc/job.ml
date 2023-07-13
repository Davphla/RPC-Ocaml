open Unix

(** A job is a promise of a distant work.
    It represent the exchange between the local actor, and the worker, the distant unit. *)
module Job = struct
  open Serialize

  type status =
  | Waiting 
  | Running 
  | Done
  | Failed of exn

  (** TODO : Modify id int by uuid *)
  type t = {
      id : int;
      data : Serialize.t;
      addr : sockaddr;
      mutable status : status;
    }

  let unique_id = ref 0

  let get_new_id addr = 
    let id = !unique_id in
    unique_id := id + 1;
    Hashtbl.hash (id, addr)

  let mutex = Mutex.create ()

  let waiting_jobs = Queue.create ()
  (** Protected with a mutex *)
  
  let running_jobs = Hashtbl.create 16

  let create_job data addr = 
    let id = get_new_id addr in
    let encoded_data = Serialize.to_msg id REQUEST data in
    { id = id;
      data = encoded_data; 
    addr = addr;
    status = Waiting}
  

  let add_new_job data addr = 
    let job = create_job data addr in
    Mutex.lock mutex;
    Queue.add job waiting_jobs;
    Mutex.unlock mutex;;
  

  let add_job job = 
    Hashtbl.add running_jobs job.id job

  let remove_job job = 
    Hashtbl.remove running_jobs job.id
    
end