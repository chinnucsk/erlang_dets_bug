%% Copyright
-module(dets_test_server).
-author("mdaguete").

-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([save/1]).
-export([read/0]).
-export([delete_all/0]).
-export([info/1]).

%% gen_server callbacks
-record(state, {queue}).

-define(DQUEUE,dqueue).

%% gen_server
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).

%% API
start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

save(Item) ->
  gen_server:call(?MODULE,{save,Item},infinity).

read() ->
  gen_server:call(?MODULE,{read},infinity).

info(Text) ->
  gen_server:call(?MODULE,{info,Text},infinity).


delete_all() ->
  gen_server:call(?MODULE,{delete_all},infinity).

init(_Args) ->
  {ok,Name} = ?DQUEUE:open("dets_test.q"),
  {ok, #state{queue=Name}}.

handle_call({delete_all},_From,#state{queue=Q} = State) ->
  NQ = ?DQUEUE:delete_all(Q),
  {reply,ok,State#state{queue=NQ}};
handle_call({save,Item},_From,#state{queue=Q} = State) ->
  NQ = ?DQUEUE:in(Item,Q),
  {reply,ok,State#state{queue=NQ}};
handle_call({read},_From, #state{queue=Q} = State) ->
  {Elem,NQ} = ?DQUEUE:out(Q),
  {reply,Elem,State#state{queue=NQ}};
handle_call({info,Text},_From, #state{queue={_,_,Tab}} = State) ->
  io:format("DETS info for ~p after ~p:\n",[Tab,Text]),
  io:format("\tFile Size: ~p~n",[dets:info(Tab,file_size)]),
  io:format("\tNumber Objects Stored: ~p~n",[dets:info(Tab,no_objects)]),
  %io:format("\tProcess dict ~p~n",[erlang:get()]),
  {reply,ok,State};
handle_call(_Request, _From, State) ->
  {noreply, State}.



handle_cast({info,Text}, #state{queue={_,_,Tab}} = State) ->
  io:format("DETS info for ~p after ~p:\n",[Tab,Text]),
  io:format("\tFile Size: ~p~n",[dets:info(Tab,file_size)]),
  io:format("\tNumber Objects Stored: ~p~n",[dets:info(Tab,no_objects)]),
  %io:format("\tProcess dict ~p~n",[erlang:get()]),
  {noreply, State}.


handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
