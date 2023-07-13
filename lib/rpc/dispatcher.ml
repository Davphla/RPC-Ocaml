open Unix

open Network
open Job

(** Dispatch request between Workers and Executors *)
module Dispatcher = 
  struct

  (** Send request to workers from all unprocessed jobs *)
  let dispatch_jobs () =
    let dispatch_job job =
      ignore @@ Network.send_msg_to_worker job.addr job.data
    in 

    ignore @@ Queue.iter dispatch_job waiting_jobs
end
  
