"""
    struct ContinuousSpace{T<:Number} <: AbstractContinuousSpace
        low::T
        high::T
    end

The lower bound and upper bound are specifed by `low` and `high`.
"""
struct ContinuousSpace{T<:Number} <: AbstractContinuousSpace
    low::T
    high::T
end

eltype(s::ContinuousSpace{T}) where T = T
sample(s::ContinuousSpace) = s.low + rand() * (s.high - s.low)
in(x, s::ContinuousSpace) = s.low ≤ x ≤ s.high