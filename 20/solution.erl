-module(solution).

-compile(export_all).

-record(module, {name, type, dests, state}).

solution(Filename) ->
    {ok,F} = file:read_file(Filename),
    Lines = lists:droplast(binary:split(F, <<$\n>>, [global])),
    (catch ets:delete(state)),
    State = ets:new(state, [{keypos, #module.name}, named_table]),
    Modules = lists:map(fun parse_line/1, Lines),
    {_, Srcs} = lists:foldl(fun input_module/2, {State, #{}}, Modules),
    init_conjs(ets:tab2list(State), Srcs, State),
    io:format("~p~n", [ets:tab2list(State)]),
    {L, H} = push_button_n(State, {0, 0}, 1000),
    {L, H, L * H}.

init_conjs([], _, _State) -> ok;
init_conjs([#module{name=Name, type=conjunction}|Rest], Srcs, State) ->
    ets:update_element(State, Name, {#module.state, maps:from_list([{X, low} || X <- maps:get(Name, Srcs)])}),
    init_conjs(Rest, Srcs, State);
init_conjs([_|Rest], Srcs, State) ->
    init_conjs(Rest, Srcs, State).

push_button_n(_State, Counter, 0) -> Counter;
push_button_n(State, Counter, X) ->
    NewCounter = push_button(State, Counter),
    io:format("~n"),
    push_button_n(State, NewCounter, X - 1).

push_button(State, Counter) ->
    InitPulses = queue:from_list([{button, <<"broadcaster">>, low}]),
    process_pulses(InitPulses, State, Counter).

process_pulses(Queue0, State, Counter) ->
    case queue:out(Queue0) of
        {{value, {Src, Dest, Pulse}}, Queue1} ->
            io:format("~s -~s-> ~s~n", [Src, Pulse, Dest]),
            case ets:lookup(State, Dest) of
                [] -> NewQueue = Queue1;
                [Module] ->
                    {NewState, Out} = execute(Module, Src, Pulse),
                    case NewState =:= Module#module.state of
                        true -> ok;
                        false -> ets:insert(State, Module#module{state=NewState})
                    end,
                    NewQueue = lists:foldl(fun queue:in/2, Queue1, Out)
            end,
            process_pulses(NewQueue, State, update_counter(Pulse, Counter));
        {empty, _} ->
            Counter
    end.

update_counter(low, {L, H}) -> {L + 1, H};
update_counter(high, {L, H}) -> {L, H + 1}.

execute(Module, Src, InPulse) ->
    {NewState, Effect} = execute_(Module, Src, InPulse),
    Out = case Effect of
        ignore -> [];
        OutPulse -> [{Module#module.name, Dest, OutPulse} || Dest <- Module#module.dests]
    end,
    {NewState, Out}.

execute_(#module{type=broadcaster, state=State}, _Src, Pulse) ->
    {State, Pulse};
execute_(#module{type=flipflop, state=State}, _Src, high) ->
    {State, ignore};
execute_(#module{type=flipflop, state=State}, _Src, low) ->
    NewState = flip(State),
    io:format("flipflip ~p~n", [NewState]),
    {NewState, flipflop_pulse(NewState)};
execute_(#module{type=conjunction, state=State}, Src, Pulse) ->
    NewState = State#{Src => Pulse},
    io:format("conjunction ~p~n", [NewState]),
    {NewState, conjunction_pulse(NewState)}.

flip(off) -> on;
flip(on) -> off.

flipflop_pulse(on) -> high;
flipflop_pulse(off) -> low.

conjunction_pulse(State) ->
    case lists:all(fun (X) -> X =:= high end, maps:values(State)) of
        true -> low;
        false -> high
    end.

input_module(Module, {State, Srcs}) ->
    ets:insert(State, Module),
    NewSrcs = init_srcs(Srcs, Module),
    {State, NewSrcs}.

init_srcs(Srcs0, #module{name=N, dests=Ds}) ->
    lists:foldl(fun (D, Srcs) -> maps:update_with(D, fun (X) -> [N|X] end, [N], Srcs) end, Srcs0, Ds).

parse_line(<<"broadcaster -> ", L/binary>>) ->
    #module{name= <<"broadcaster">>, type=broadcaster, dests=split_dests(L)};
parse_line(<<C, Rest/binary>>) ->
    [Name, Dests] = binary:split(Rest, <<" -> ">>),
    #module{type=type(C), name=Name, dests=split_dests(Dests), state=init_state(type(C))}.

type($%) -> flipflop;
type($&) -> conjunction.

init_state(flipflop) -> off;
init_state(conjunction) -> #{}.

split_dests(B) -> binary:split(B, <<", ">>, [global]).
