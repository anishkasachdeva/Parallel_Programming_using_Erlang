-module('2018101112_2'). 
-import(io,[fwrite/2]). 
-import(io,[format/2]). 
-import(lists,[nth/2]). 
-import(lists,[append/2]). 
-export([main/1]). 

main(Args) -> 
    Input_File = nth(1, Args),
    Output_File = nth(2, Args). 
    % {ok, File} = file:open(Input_File, [read]),
    % Txt = file:read(File, 1024 * 1024),
    % E = element(2, Txt),
    % Tokens = string:tokens(E, " ").
    % format("~p~n", Tokens).
    % P = nth(1, Tokens),
    % N = nth(2, Tokens),
    % M = nth(3, Tokens). 
    % Numprocs = nth(1,convert_type(N, Msg)),
    % Token = nth(2,convert_type(N, Msg)),
    % file:delete(Output_File),
    % start(Numprocs, Token, Output_File).