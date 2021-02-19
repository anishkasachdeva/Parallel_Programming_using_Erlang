%Given a weighted graph and a source vertex in the graph, find the shortest paths from source to all vertices in the graph. You can use any algorithm to solve this problem.
-module('2018101112_2'). 
-import(io,[fwrite/2]). 
-import(io,[format/2]). 
-import(lists,[nth/2]). 
-import(lists,[append/2]). 
-import(lists,[duplicate/2]). 
-export([main/1, make_graph/3, spawn_processes/10,bellmanFord/9, loop/0, send_dist_lists/3]). 

loop()->
    receive
        {Distance} ->
            format("Distance Array : ~p~n", [Distance])
    end.

send_dist_lists(_, _, 0)->
    ok;
send_dist_lists(Distance, Pids_List, Count)->
    Pid = nth(Count, Pids_List),
    Pid ! {Distance},
    send_dist_lists(Distance,Pids_List,Count-1).

bellmanFord(_ ,_,1, _, _, _, _, _, _)->
    ok;
bellmanFord(Output_File ,Adj_matrix, Vertices, Edges, Source,Edges_per_process, Pids_List, Distance, Count) -> 
    send_dist_lists(Distance, Pids_List, Count),
    bellmanFord(Output_File ,Adj_matrix, Vertices-1, Edges, Source, Edges_per_process, Pids_List, Distance, Count).

spawn_processes(Pids_List,_, _, _, _, 0, _, _, _,_) -> 
    Pids_List;
spawn_processes(Pids_List,Adj_matrix, Vertices, Edges, Source, Numprocs, Edges_per_process, Output_File, Count,Distance) ->
    Pid = spawn('2018101112_2', loop, []), 
    spawn_processes([Pid|Pids_List],Adj_matrix, Vertices, Edges, Source, Numprocs-1, Edges_per_process,Output_File, Count+1, Distance). 

make_graph(3,_, Graph)-> 
    Graph;
make_graph(Index, Tokens, Graph)-> 
    U = list_to_integer(nth(Index-2, Tokens)),
    V = list_to_integer(nth(Index-1, Tokens)),
    Weight = list_to_integer(nth(Index, Tokens)),
    New_Entry = [U,V,Weight],
    make_graph(Index-3, Tokens, [New_Entry|Graph]). 

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
    format("Tokens : ~p~n", [Tokens]),
    format("Length of Tokens : ~p~n", [length(Tokens)]),
    format("Numprocs : ~p~n", [Numprocs]),
    format("Vertices : ~p~n", [Vertices]),
    format("Edges : ~p~n", [Edges]),
    format("Source : ~p~n", [Source]),
    Graph = [],
    format("Graph : ~p~n", [Graph]),
    % file:delete(Output_File),
    Adj_matrix = make_graph(length(Tokens)-1, Tokens, Graph),
    Dist = duplicate(Vertices,99999999),
    Distance = lists:sublist(Dist, Source-1) ++ [0] ++ lists:nthtail(Source,Dist),
    format("Adj Matrix : ~p~n", [Adj_matrix]), 
    format("Distance : ~p~n", [Distance]), 
    Pids_List = [],
    ListOfPids = spawn_processes(Pids_List, Adj_matrix, Vertices, Edges, Source, Numprocs, Edges_per_process, Output_File, 1, Distance),
    bellmanFord(Output_File, Adj_matrix, Vertices, Edges, Source, Edges_per_process, ListOfPids, Distance, Numprocs).