open Network
open Job.Job
open Job
open Serialize

(** Dispatch request between Workers and Executors *)
module Dispatcher = 
  struct
  

  (** TODO Repair race condition (not using mutex) 
   Send request to workers from all unprocessed jobs *)
    let dispatch_jobs () = 
      Condition.wait Job.condition Job.mutex;

      ignore @@ Queue.iter (fun job -> 
        let data = Serialize.to_msg job.id REQUEST job.data in
        ignore @@ Network.send_msg_to_worker job.addr data.data
      ) Job.waiting_jobs

end
  
