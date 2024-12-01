-module(solution).

-compile(export_all).

-record(module, {name, type, dests, state}).

-record(counter, {low=0, high=0, cnts=#{}}).

parse(Filename) ->
    {ok,F} = file:read_file(Filename),
    Lines = lists:droplast(binary:split(F, <<$\n>>, [global])),
    Modules = lists:map(fun parse_line/1, Lines),
    Srcs = lists:foldl(fun init_srcs/2, #{}, Modules),
    InitModules = [init_conjs(Module, Srcs) || Module <- Modules],
    {
        Srcs,
        lists:foldl(
            fun (Module=#module{name=Name}, Map) -> Map#{Name=>Module} end,
            #{},
            InitModules
        )
    }.

part1(Filename) ->
    {_Srcs, Modules} = parse(Filename),
    #counter{low=L, high=H} = push_button_n(Modules, #counter{}, 1000),
    L*H.

part2(Filename) ->
    {Srcs, Modules} = parse(Filename),
    TreeBreak = break_tree(Modules, Srcs, <<"rx">>, low),
    solve_tree(TreeBreak).

solve_tree({lcm, L}) ->
    lists:foldl(fun (X, Y) -> lcm(solve_tree(X), Y) end, 1, L);
solve_tree({compute, Name, Want, Modules}) ->
    push_button_until(Modules, Name, Want).

gcd(A,B) when A == 0; B == 0 -> 0;
gcd(A,B) when A == B -> A;
gcd(A,B) when A > B -> gcd(A-B, B);
gcd(A,B) -> gcd(A, B-A).

lcm(A,B) -> (A*B) div gcd(A, B).

break_tree(Modules, Srcs, Name, WantPulse) ->
    Type = case maps:find(Name, Modules) of
        error ->
            output;
       {ok, #module{type = Type1}} ->
            Type1
    end,
    case Type of
        flipflip ->
            {compute, Name, WantPulse};
        _ ->
            L = maps:get(Name, Srcs),
            Ascendants = [{Src, parents([Src], Srcs, #{Src => init}) -- [<<"broadcaster">>]} || Src <- L],
            NewWant = need_pulse(Type, WantPulse),
            case lists:all(fun (X) -> X end, [X -- Y == X || {NX, X} <- Ascendants, {NY, Y} <- Ascendants, NX /= NY]) andalso lists:all(fun ({NX, X}) -> not lists:member(NX, X) end, Ascendants) of
                true ->
                    case [break_tree(filter(AscNames, Modules), Srcs, Src, NewWant) || {Src, AscNames} <- Ascendants] of
                        [A] -> A;
                        Other -> {lcm, Other}
                    end;
                false ->
                    {compute, Name, WantPulse, Modules}
            end
    end.

filter(L, Modules) ->
    maps:filter(fun (Name, _) -> Name =:= <<"broadcaster">> orelse lists:member(Name, L) end, Modules).

parents([N|Rest], Srcs, Seen) ->
    case maps:find(N, Seen) of
        error ->
            parents(maps:get(N, Srcs, []) ++ Rest, Srcs, Seen#{N => 1});
        {ok, init} ->
            parents(maps:get(N, Srcs, []) ++ Rest, Srcs, maps:remove(N, Seen));
        {ok, _} ->
            parents(Rest, Srcs, Seen)
    end;
parents([], _Srcs, Seen) ->
    maps:keys(Seen).

need_pulse(conjunction, low) -> high;
need_pulse(conjunction, high) -> low;
need_pulse(output, Pulse) -> Pulse.


push_button_until(State, N, X) ->
    push_button_until(State, State, N, X, 1).
push_button_until(_, _, _, _, 10000) -> nope;
push_button_until(IState, State, Name, Want, Count) ->
    {NewState, #counter{cnts=Cnts}} = push_button(State, #counter{}),
    case lists:reverse(maps:get(Name, Cnts, [])) of
        [Want|Rest] ->
            [_] = lists:usort(Rest),
            NewState = IState,
            Count;
        L ->
            true = L =:= error orelse length(lists:usort(L)) < 2,
            push_button_until(IState, NewState, Name, Want, Count + 1)
    end.

init_conjs(Module=#module{name=Name, type=conjunction}, Srcs) ->
    Module#module{
        state=maps:from_list([{X, low} || X <- maps:get(Name, Srcs)])
    };
init_conjs(Module, _Srcs) -> Module.

push_button_n(_State, Counter, 0) -> Counter;
push_button_n(State, Counter, X) ->
    {NewState, NewCounter} = push_button(State, Counter),
    push_button_n(NewState, NewCounter, X - 1).

push_button(State, Counter) ->
    InitPulses = queue:from_list([{button, <<"broadcaster">>, low}]),
    process_pulses(InitPulses, State, Counter).

process_pulses(Queue0, State, Counter) ->
    case queue:out(Queue0) of
        {{value, {Src, Dest, Pulse}}, Queue1} ->
            case maps:find(Dest, State) of
                error ->
                    NewQueue = Queue1,
                    NewState = State;
                {ok, Module=#module{state=MState}} ->
                    {NewMState, Out} = execute(Module, Src, Pulse),
                    NewState = case NewMState =:= MState of
                        true -> State;
                        false -> State#{Dest => Module#module{state=NewMState}}
                    end,
                    NewQueue = lists:foldl(fun queue:in/2, Queue1, Out)
            end,
            NewCounter = update_counter(Pulse, Dest, Counter),
            process_pulses(NewQueue, NewState, NewCounter);
        {empty, _} ->
            {State, Counter}
    end.

update_counter(Pulse, Dest, Counter) ->
    update_counter2(Pulse, Dest, update_counter1(Pulse, Counter)).

update_counter1(low, Counter=#counter{low=Low}) ->
    Counter#counter{low=Low+1};
update_counter1(high, Counter=#counter{high=High}) ->
    Counter#counter{high=High+1}.

update_counter2(Pulse, Dest, Counter=#counter{cnts=Cnts}) ->
    Counter#counter{cnts=maps:update_with(Dest, fun (L=[P|_]) when P =:= Pulse -> L; (L) -> [Pulse|L] end, [Pulse], Cnts)}.

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
    {NewState, flipflop_pulse(NewState)};
execute_(#module{type=conjunction, state=State}, Src, Pulse) ->
    NewState = State#{Src => Pulse},
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

init_srcs(#module{name=N, dests=Ds}, Srcs0) ->
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
