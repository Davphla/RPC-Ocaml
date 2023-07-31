open Unix

open Network
open Job
open Serialize

(** Dispatch request between Workers and Executors *)
module Dispatcher = 
  struct
  

    (** Send request to workers from all unprocessed jobs *)
    (** TODO Repair race condition (not using mutex) *)
    let dispatch_jobs () = 
      Condition.wait Job.condition Job.mutex;

      ignore @@ Queue.iter (fun job -> 
        let data = Serialize.to_msg job.id REQUEST job.data in
        ignore @@ Network.send_msg_to_worker job.addr data
      ) Job.waiting_jobs

end
  
