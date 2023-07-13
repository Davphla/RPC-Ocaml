open Dispatcher
open Network

module Rpc = struct
  open Serialize

  let run_dispatcher () =  
    while true do 
      Dispatcher.dispatch_jobs ()
    done


  (** Check if the job ID exist
    If not Create a job Send to scheduler and create a promise, and send
  otherwise just fill the job *)
  let run_server () =
    while true do
      let responses = Network.poll_server () in
      List.iter (fun (msg) -> Network.process_msg msg) responses;
    done


    let run () = 
      let d = Domain.spawn run_server in
    run_dispatcher ();
    Domain.join d

end