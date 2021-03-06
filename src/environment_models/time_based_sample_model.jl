import StatsBase:sample

mutable struct TimeBasedSampleModel <: AbstractSampleModel
    experiences::Dict{Any, Dict{Any, NamedTuple{(:reward, :isdone, :nextstate), Tuple{Float64, Bool, Any}}}}
    nactions::Int
    κ::Float64
    t::Int
    last_visit::Dict{Tuple{Any, Any}, Int}
    TimeBasedSampleModel(nactions::Int, κ::Float64=1e-4) = new(Dict{Any, Dict{Any, NamedTuple{(:reward, :isdone, :nextstate), Tuple{Float64, Bool, Any}}}}(), nactions, κ, 0, Dict{Tuple{Any, Any}, Int}())
end

update!(m::TimeBasedSampleModel, buffer, learner) = update!(m, buffer)

function update!(m::TimeBasedSampleModel, buffer::EpisodeSARDBuffer)
   s, a, r, d, s′ = buffer.state[end-1], buffer.action[end-1], buffer.reward[end], buffer.isdone[end], buffer.state[end]
   if haskey(m.experiences, s)
         m.experiences[s][a] = (reward=r, isdone=d, nextstate=s′)
   else
         m.experiences[s] = Dict{Any, NamedTuple{(:reward, :isdone, :nextstate), Tuple{Float64, Bool, Any}}}(a => (reward=r, isdone=d, nextstate=s′))
   end
   m.t += 1
   m.last_visit[(s,a)] = m.t
end

function sample(m::TimeBasedSampleModel)
   s = rand(keys(m.experiences))
   a = rand(1:m.nactions)
   r, d, s′ = get(m.experiences[s], a, (0., false, s))
   r += m.κ * sqrt(m.t - get(m.last_visit, (s, a), 0))
   s, a, r, d, s′
end