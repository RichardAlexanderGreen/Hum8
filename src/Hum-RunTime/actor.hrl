%% Copyright: Richard Alexander Green 2011
%% Created: Jan 6, 2011
%% Description: actor.hrl provides the Erlang general server wrapper
%%  that every business process actor will need.
%%  The actor definition adds do/2 and answer/1 functions 
%%  to handle asynchronous requests and synchronous queries.

-behaviour( gen_server ).
-define( SERVER, ?MODULE ).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


-ifdef( DEBUG ).
-compile( export_all ).
-endif.


%% --------------------------------------------------------------------
%% External exports
-export([start_server/0]).

%% gen_server callbacks
-export( [init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3] ).

-record( state, { }   ).
%-include_lib("log.hrl").

%% ====================================================================
%% External functions
%% ====================================================================
%%% Queries:


%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% @doc Starts the server.
%%
%% @spec start_server() -> {ok, Pid}
%% where
%% Pid = pid()
%% @end
%%--------------------------------------------------------------------
start_server() ->
		?debugVal( {start_server, enter} ),
		
		Result = gen_server:start_link(              % Start server instance.
                           { local, ?SERVER }    % Give it a LOCAL name -- enable use of !
													 ,?MODULE              % The module containing init/1
												   , [ { host, node() } ]  % parameters for init/1.
													 , []                  % options
                           ),
		?debugVal( { start_link_result, Result } ),
		Result.
		
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init(ArgList) ->
		
		process_flag( trap_exit, true ),            % Enable custom_shutdown -- So actor can clean-up 
		global:register_name( ?MODULE, self() ),    % Enable remote nodes to use global:send( quad, {Action} )
		log_open( atom_to_list(?MODULE)++"_log.txt" ),
		% Call actor's initialization routine.
		State = custom_init( ArgList ),
		
    {ok, State }.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
		
handle_call( Request, From, State) ->     % Synchronous -- Caller is waiting for reply.
		log( trace, { handle_call, Request, From} ),	
    Reply = answer( Request, From, State ),
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast( Action, State ) ->           % Asynchronous -- No value is returned.
		log( trace, { handle_cast, Action } ),	
		ok = do( Action, State ),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info( Action, State ) ->
		?debugVal( { handle_info, Action }  ),
    log( trace, { handle_info, Action }  ),	
		State2 = do( Action, State ),   % Pass State because it has Table ID in it.
		{noreply, State2}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate( shutdown, State ) ->
		log_close(),
		custom_shutdown( State ),
		ok;

terminate( _Reason, _State) ->
    log( info, { terminate_reason, _Reason } ),
		ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change( _OldVsn, State, _Extra) ->
    {ok, State}.

%% -----------------------------------------------------------------------------------
%% Log events for debug.

% Reports below the current LOGLEVEL are ignoared.
% ALL=0 < TRACE=1 < DEBUG=2 < INFO=3 < WARN=4 < ERROR=5 < FATAL=6 < OFF=7
log( trace, _Report ) when ?LOGLEVEL > 1 -> ok;   % Ignore info level.
log( debug, _Report ) when ?LOGLEVEL > 2 -> ok;   % Ignore info level.
log(  info, _Report ) when ?LOGLEVEL > 3 -> ok;   % Ignore debug level.
log(  warn, _Report ) when ?LOGLEVEL > 4 -> ok;   % Ignore debug level.
log(warning,_Report ) when ?LOGLEVEL > 4 -> ok;   % Ignore debug level.
log( error, _Report ) when ?LOGLEVEL > 5 -> ok;   % Ignore debug level.
log( fatal, _Report ) when ?LOGLEVEL > 6 -> ok;   % Ignore debug level.

log(_Level, _Report ) when ?LOGLEVEL > 7 -> ok;   % Ignore specialized debug level.

log( Level, Report ) ->
		%io:format("~w.~n", [{ Level, Report }] ),
		?debugVal( { log, Level, Report }),
		
    Result = file:write( get(log), io_lib:format("~w,~n", [{ udt(), Level, ?MODULE, Report }] )  ),
		%?debugVal( {self(), get(log), 'file:write Result:', Result}),
		
		ok.

% Thinking out loud: I prefer file:write/2 (above) because it can be read outside of erlang.
% If necessary, the log file can be formatted to enable some external log scanner.
% ets enables qlc queries, which can be useful when scanning a large log.
% ets may also require a large memory space if the log is large.
% With both systems, you have to deal with the fact that the io is buffered.

log_open( LogName ) ->
		%?debugVal( { log_open, LogName } ),
		
		{ ok, IO_Device } = file:open( LogName, [append] ),
		put( log, IO_Device ),
		%?debugVal( { self(), log_open, IO_Device }),
		
		ok.

log_close() ->
		%flush_each_table(  [ get( log ) ]  ),
		?debugVal( {self(), log_close, get(log) }),
		
		file:close( get( log )  ),
		ok.

% Utility to make my code more concise.
udt() ->
		calendar:universal_time().



%% -----------------------------------------------------------------------------------


