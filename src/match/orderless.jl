using Combinatorics
using Compat.Iterators

isol(ex) = any(isolarg.(ex.args))
isolarg(ex) = isexpr(ex, :call) && ex.args[1] in (:tilde_, :~)

function olnew(ex::Expr)
  olinds = findall([Iterators.flatten([isolarg(arg) ? map(arg -> true, arg.args[2:end]) : (false,) for arg in ex.args])...])
  args = [Iterators.flatten([isolarg(arg) ? arg.args[2:end] : (arg,) for arg in ex.args])...]
  olargs = args[olinds]
  or_((Expr(ex.head, (args′ = copy(args); args′[perm] = olargs; args′)...) for perm in permutations(olinds))...)
end

subol(s) = s
subol(s::Symbol) = s
subol(s::Expr) = isol(s) ? subol(olnew(s)) : Expr(s.head, map(subol, s.args)...)
subol(s::OrBind) = OrBind(subol(s.pat1), subol(s.pat2))
