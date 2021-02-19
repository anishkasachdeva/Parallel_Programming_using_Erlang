## Distributed Systems - Assignment 2
####  Parallel Programming in Erlang
---
##### Anishka Sachdeva (2018101112)
###### 21st February, 2021
---
## Description of Solutions
---
#### Question 1 :
##### Write a program to pass an integer token value around all processes in a ring-like fashion, and make sure that it does not have a deadlock.

#### Steps to run the code

1. erlc 2018101112_1.erl 
2. erl -noshell -s 2018101112_1 main <input_file> <output_file> -s init stop

#### Format of input file
Input contains two space-separated integers P and M denoting the number of processes and the token value respectively.
#### Implementation Approach

###### Basic Strategy :
1. The processes are spawned and each process sends a token to the process next to it in a ring like fashion and the last process eventually sends the token to the first process.
2. The above is done in the following manner : 
1. First the main program initiates message passing to the first process.
2. Then the entire ring like token passing is done in 'receive' until the process id list becomes empty. 
###### Implementation Strategy :
1. First the input file is read and broken into tokens.
2. The number of processes and token is extracted.
3. Now the processes are spawned using the "spawn" command/keyword and each process is sent to execute the loop.
4. A list of process ids is created and then the first pid is appended to the list to get the list in the ring form.
4. The message sending is done using '!' in the form : pid ! message where pid is the process id to which the message is being sent.
5. Erlang uses pattern matching for receiving messages (same as in function clause selection and the case statement). The receive statement is used to deliver messages from the message queue. It is explained below :
    1. The first message (head of the message queue) is pattern matched against the first receive clause. If match, execute the clause’s body, else go to the next step.
    2. The same message is pattern matched against the second (if any) receive clause. If match, execute the clause’s body, else go to the next step.
    3. The same message is pattern matched against the last clause. If match, execute the clause’s body, else go to the next step.
    4. The same iterative process starts again from step 1, but now with the next message from the message queue.
6. As soon as a process gets the token, it writes in the output file and then passes the token to the next process.
###### Major Erlang Commands Used :
1. spawn
2. receive
3. end
---
#### Question 2 :
##### Given a weighted graph and a source vertex in the graph, find the shortest paths from source to all vertices in the graph. You can use any algorithm to solve this problem.

#### Steps to run the code

1. erlc 2018101112_2.erl 
2. erl -noshell -s 2018101112_2 main <input_file> <output_file> -s init stop

#### Format of input file
The first line of input contains number of processes P. The second line of input contains N and M representing the number of vertices and edges in the graph
respectively. The vertices will be numbered from 1 to N. Each of next M lines contains the triplet X, Y and W that represents the two edge points and the weight
of an edge. Next line contains S, the source vertex.
#### Implementation Approach

###### Basic Strategy :
1. Algorithm used : Bellman Ford Algorithm for Shortest distance to all vertices from source.
2. The basic strategy involves dividing the edges amongst all the processes in such a manner that each process relaxes the edges independently in the outer iteration (Vertices -1 times) and after each iteration, all the respective distance arrays of each process are merged by broadcasting the distance arrays.
###### Implementation Strategy :
1. First the input file is read and broken into tokens.
2. The number of processes, vertices and edges are extracted.
3. Source of the graph is extracted.
4. Then the graph is constructed in the form of a list of lists : Every edge has three values (u, v, w) where the edge is from vertex u to v. And weight of the edge is w. And thus, each list is of size 3 consisting of u,v and w contained in the bigger list.
5. Now the processes are spawned using the "spawn" command/keyword and each process is sent to execute the bellman ford algorithm.
6. Now the BellmanFord function is called which sends the updated distance array to all the spawned processes and receives the final updated distance array from the root process.
7. All the processes after receiving the updated array execute the relaxation of edges assigned to the respectively.
8. Then all the individual distance arrays are sent to the root process for the final updation after each outer iteration.
9. After Vertices-1 iterations, we have the distance array containing the final shortest paths from source to all the vertices.
10. At last, the distance array is written in the Output_file.
###### Major Erlang Commands Used :
1. spawn
2. receive
3. end
---