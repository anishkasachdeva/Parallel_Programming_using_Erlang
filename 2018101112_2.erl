-module('2018101112_2'). 
-import(io,[fwrite/2]). 
-import(io,[format/2]). 
-import(lists,[nth/2]). 
-import(lists,[append/2]). 
-export([main/1, make_graph/3, spawn_processes/5,bellmanFord/4]). 


bellmanFord(Adj_matrix, Vertices, Edges, Source) -> 



spawn_processes(_, _, _, _, _,0,_) -> 
    ok;
spawn_processes(Adj_matrix, Vertices, Edges, Source, Numprocs, Output_File) ->
    Pid = spawn('2018101112_2', bellmanFord, [Output_File,Adj_matrix, Vertices, Edges, Source]), 
    spawn_processes(Adj_matrix, Vertices, Edges, Source, Numprocs-1, Output_File). 


make_graph(28,_, Graph)-> 
    Graph;
make_graph(Index, Tokens, Graph)-> 
    % if Index == length(Tokens)-> Graph,
    U = list_to_integer(nth(Index, Tokens)),
    V = list_to_integer(nth(Index+1, Tokens)),
    Weight = list_to_integer(nth(Index+2, Tokens)),
    New_Entry = [U,V,Weight],
    make_graph(Index+3, Tokens, [New_Entry|Graph]). 


main(Args) -> 
    Input_File = nth(1, Args),
    Output_File = nth(2, Args),
    {ok, File} = file:open(Input_File, [read]),
    Text = file:read(File, 1024 * 1024), 
    % format("Text : ~p~n", [Text]),
    E = element(2, Text),
    % format("E : ~p~n", [E]),
    Tokens = string:tokens(E, "\n "),
    Numprocs = list_to_integer(nth(1, Tokens)),
    Vertices = list_to_integer(nth(2, Tokens)),
    Edges = list_to_integer(nth(3, Tokens)),
    Source = list_to_integer(nth(length(Tokens), Tokens)),
    format("Tokens : ~p~n", [Tokens]),
    format("Length of Tokens : ~p~n", [length(Tokens)]),
    format("Numprocs : ~p~n", [Numprocs]),
    format("Vertices : ~p~n", [Vertices]),
    format("Edges : ~p~n", [Edges]),
    format("Source : ~p~n", [Source]),
    Graph = [],
    format("Graph : ~p~n", [Graph]),
    file:delete(Output_File),
    Adj_matrix = make_graph(4, Tokens, Graph),
    format("Adj Matrix : ~p~n", [Adj_matrix]). 
    spawn_processes(Adj_matrix, Vertices, Edges, Source, Numprocs, Output_File).