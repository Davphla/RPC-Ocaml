open Dispatcher
open Network
open Job

module Rpc = struct
  open Serialize

  let run_dispatcher () =  
    while true do 
      (** Wait until change in the job queue. *)
      Dispatcher.dispatch_jobs ()
    done


  (** Check if the job ID exist
    If not Create a job Send to scheduler and create a promise, and send
  otherwise just fill the job *)
  let run_server () =
    while true do
      let responses = Network.poll_server () in
      List.iter Job.process_msg responses;
    done


    let run () = 
      let d = Domain.spawn run_server in
    run_dispatcher ();
    Domain.join d

end