# RPC-Ocaml

This is an attempt for a contribution to the Ocaml library [Actors](https://github.com/Marsupilami1/actors-ocaml) by making a RPC module.
The goal was to create distributed actors that can communicate with each other using a remote procedure call (RPC) mechanism.

This was my first time working with Ocaml (Which was not easy task) in the goal for a contribution.
It was made during the context of my internship in the Laboratory of Informatics and Parallelism.

It is not complete, but still interesting to share as it is.

# Terminology

    Dispatcher: All messages go through the dispatcher. Dispatcher receives requests from Executors, chooses a Worker and sends the request to the worker, receives the answer from the worker and replies back to the Executor.

    Transport: Transports are a collection of Clients and Servers who make it possible for Workers and Executors to communicate with a Dispatcher using a specific protocol.

    Worker: Workers are in charge of processing the requests, calling functions and returning the results to the dispatcher.

    Executor: Executors are in charge of sending requests from user to the dispatcher and returning the results to the user.
