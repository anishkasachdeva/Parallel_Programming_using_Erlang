%Given a weighted graph and a source vertex in the graph, find the shortest paths from source to all vertices in the graph. You can use any algorithm to solve this problem.
-module('2018101112_2'). 
-import(io,[fwrite/2]). 
-import(io,[format/2]). 
-import(lists,[nth/2]). 
-import(lists,[append/2]). 
-import(lists,[duplicate/2]). 
-import(lists,[min/1]).
-export([main/1, make_graph/3, spawn_processes/10,bellmanFord/9, loop/1, send_dist_lists/5, calc/2, merge/2, write_file/3]). 


calc(Distance,[]) ->
    Distance;
calc(Distance, [H|T]) -> 
    % format("Edge : ~p~n", [H]),
    U = nth(1,H),
    V = nth(2,H),
    W = nth(3,H),
    MIN = min([nth(U,Distance) + W,nth(V,Distance)]),
    % format("MIn val : ~p~n", [MIN]),
    Dist = lists:sublist(Distance, V-1) ++ [MIN] ++ lists:nthtail(V,Distance),
    % format("lala : ~p~n", [Dist]),
    calc(Dist,T).

loop(Main_pid)->
    receive
        {Distance, Edges} ->
            % format("Distance Array : ~p~n", [Distance]),
            Distance2 = calc(Distance,Edges),
            % format("Distance Array : ~p~n", [Distance2]),
            Main_pid ! {Distance2}
    end,
    loop(Main_pid).

send_dist_lists(_, _, 0, _, _)->
    ok;
send_dist_lists(Distance, Pids_List, Count, Adj_matrix, Edges_per_process)->
    Pid = nth(Count, Pids_List),
    if 
        Count == 1 -> 
            Edges = Adj_matrix;
        true ->
            Edges = lists:sublist(Adj_matrix, Edges_per_process)
    end,
    Pid ! {Distance, Edges},
    send_dist_lists(Distance,Pids_List,Count-1, lists:nthtail(Edges_per_process,Adj_matrix),Edges_per_process).

merge(Distance, 0) -> 
    Distance;
merge(Dist1, Count) -> 
    receive 
        {Distance} ->
            Dist2 = [min([nth(X,Dist1),nth(X,Distance)]) || X <- lists:seq(1,length(Distance))]
            % format("Distance Array : ~p~n", [Dist2])
    end,
    merge(Dist2,Count-1).


bellmanFord(_ ,_,1, _, _, _, _, Distance, _)->
    Distance;
bellmanFord(Output_File ,Adj_matrix, Vertices, Edges, Source,Edges_per_process, Pids_List, Distance, Count) -> 
    send_dist_lists(Distance, Pids_List, Count, Adj_matrix,Edges_per_process),
    New_Dist = merge(Distance,Count), 
    bellmanFord(Output_File ,Adj_matrix, Vertices-1, Edges, Source, Edges_per_process, Pids_List, New_Dist, Count).

spawn_processes(Pids_List,_, _, _, _, 0, _, _, _,_) -> 
    Pids_List;
spawn_processes(Pids_List,Adj_matrix, Vertices, Edges, Source, Numprocs, Edges_per_process, Output_File, Count,Distance) ->
    Pid = spawn('2018101112_2', loop, [self()]), 
    spawn_processes([Pid|Pids_List],Adj_matrix, Vertices, Edges, Source, Numprocs-1, Edges_per_process,Output_File, Count+1, Distance). 

make_graph(3,_, Graph)-> 
    Graph;
make_graph(Index, Tokens, Graph)-> 
    U = list_to_integer(nth(Index-2, Tokens)),
    V = list_to_integer(nth(Index-1, Tokens)),
    Weight = list_to_integer(nth(Index, Tokens)),
    New_Entry = [U,V,Weight],
    New_Entry2 = [V,U,Weight],
    EE = [New_Entry | Graph],
    make_graph(Index-3, Tokens, [New_Entry2|EE]). 

write_file([],_,_) -> ok;

write_file([H|T], N, Output_File) -> 
    file:write_file(Output_File,io_lib:fwrite("~p ~p ~n",[N, H]),[append]),
    write_file(T,N+1,Output_File).


main(Args) -> 
    Input_File = nth(1, Args),
    Output_File = nth(2, Args),
    {ok, File} = file:open(Input_File, [read]),
    Text = file:read(File, 1024 * 1024), 
    E = element(2, Text),
    Tokens = string:tokens(E, "\n "),
    Numprocs = list_to_integer(nth(1, Tokens)),
    Vertices = list_to_integer(nth(2, Tokens)),
    Edges = list_to_integer(nth(3, Tokens)),
    Source = list_to_integer(nth(length(Tokens), Tokens)),
    Edges_per_process = Edges div Numprocs,
    % Edges_per_last_process = Edges_per_process + Edges rem Numprocs,
    % format("Edges per last process : ~p~n", [Edges_per_last_process]),
    % format("Tokens : ~p~n", [Tokens]),
    % format("Length of Tokens : ~p~n", [length(Tokens)]),
    % format("Numprocs : ~p~n", [Numprocs]),
    % format("Vertices : ~p~n", [Vertices]),
    % format("Edges : ~p~n", [Edges]),
    % format("Source : ~p~n", [Source]),
    Graph = [],
    % format("Graph : ~p~n", [Graph]),
    file:delete(Output_File),
    Adj_matrix = make_graph(length(Tokens)-1, Tokens, Graph),
    Dist = duplicate(Vertices,99999999),
    % format("Dist : ~p~n", [Dist]),
    Distance = lists:sublist(Dist, Source-1) ++ [0] ++ lists:nthtail(Source,Dist),
    % funn(Adj_matrix),
    % format("Adj Matrix : ~p~n", [Adj_matrix]), 
    % format("Distance : ~p~n", [Distance]), 
    Pids_List = [],
    ListOfPids = spawn_processes(Pids_List, Adj_matrix, Vertices, Edges, Source, Numprocs, Edges_per_process, Output_File, 1, Distance),
    New_Dist = bellmanFord(Output_File, Adj_matrix, Vertices, Edges, Source, Edges_per_process, ListOfPids, Distance, Numprocs),
    % format("Distance : ~p~n", [New_Dist]),
    write_file(New_Dist, 1, Output_File).