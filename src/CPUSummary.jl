module CPUSummary

	using Static
	import IfElse: ifelse
	using Static: Zero, One, gt, lt
	using Hwloc

	export cache_size, cache_linesize, cache_associativity, cache_type, cache_inclusive, num_cache, num_cores

	include("topology.jl")

	num_cache(::Union{Val{1},StaticInt{1}}) = num_l1cache()
	num_cache(::Union{Val{2},StaticInt{2}}) = num_l2cache()
	num_cache(::Union{Val{3},StaticInt{3}}) = num_l3cache()
	num_cache(::Union{Val{4},StaticInt{4}}) = num_l4cache()

	const BASELINE_CORES = Int(num_cores()) * ((Sys.ARCH === :aarch64) && Sys.isapple() ? 2 : 1)

	cache_linesize() = cache_linesize(Val(1))

	function num_cache_levels()
	  numl4 = num_l4cache()
	  numl4 === nothing && return nothing
	  ifelse(
		eq(numl4, Zero()),
		ifelse(
		  eq(num_l3cache(), Zero()),
		  ifelse(
			eq(num_l2cache(), Zero()),
			ifelse(eq(num_l1cache(), Zero()), Zero(), One()),
			StaticInt{2}(),
		  ),
		  StaticInt{3}(),
		),
		StaticInt{4}(),
	  )
	end

end
