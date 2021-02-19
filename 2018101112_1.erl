%Write a program to pass an integer token value around all processes in a ring-like fashion, and make sure that it does not have a deadlock.
-module('2018101112_1'). 
-import(io,[fwrite/2]). 
-import(io,[format/2]). 
-import(lists,[nth/2]). 
-import(lists,[append/2]). 
-export([main/1, start/3, convert_type/2, spawn_processes/4, loop/3, initiate_message_passing/2]). 

convert_type(N, Msg)->
    Numprocs = list_to_integer(N),
    Token = list_to_integer(Msg),
    [Numprocs, Token].

spawn_processes(Pids_List, 0, _, _) -> 
    Pids_List;
spawn_processes(Pids_List, Numprocs, Output_File, Total_Processes) ->
    Pid = spawn('2018101112_1', loop, [Output_File,Numprocs,Total_Processes]), 
    spawn_processes([Pid|Pids_List], Numprocs-1, Output_File, Total_Processes). 

start(Numprocs, Token, Output_File) -> 
    Pids_List = [],
    UnlinkedPids = spawn_processes(Pids_List ,Numprocs, Output_File, Numprocs), %List of Pids
    First_pid = [nth(1,UnlinkedPids)], %To extract the pid at index 1
    LinkedPids = append(UnlinkedPids, First_pid), %Added the first pid at the end of the list of PIDs
    % io:format("~p~n", [LinkedPids]),
    initiate_message_passing(Token, LinkedPids). 

initiate_message_passing(Token, [Next_Process_Id|Pids]) ->
    % io:format("~p~n", [Next_Process_Id]),
    Next_Process_Id ! {Token, Pids}. 

loop(Output_File, Numprocs, Total_Processes) -> 
    receive
        {Token, [Next_Process_Id|Pids]} ->
            % format("Numprocs : ~p~n", [Numprocs]),
            % format("Total Processes : ~p~n", [Total_Processes]),
            Receiver = Numprocs rem Total_Processes,
            Sender = Numprocs - 1,
            file:write_file(Output_File,io_lib:fwrite("Process ~p received token ~p from process ~p ~n",[Receiver, Token, Sender]),[append]),
            Next_Process_Id ! {Token, Pids},
            loop(Output_File, Numprocs, Total_Processes)
    end.

main(Args) -> 
    Input_File = nth(1, Args),
    Output_File = nth(2, Args),
    {ok, File} = file:open(Input_File, [read]),
    Text = file:read(File, 1024 * 1024),
    % format("Text : ~p~n", [Text]),
    E = element(2, Text),
    Tokens = string:tokens(E, " "),
    % format("Tokens : ~p~n", [Tokens]),
    N = nth(1, Tokens),
    Msg = nth(2, Tokens),
    Numprocs = nth(1,convert_type(N, Msg)),
    Token = nth(2,convert_type(N, Msg)),
    file:delete(Output_File),
    start(Numprocs, Token, Output_File).