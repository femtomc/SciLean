import SciLean.Core.FunctionTransformations.CDeriv

--------------------------------------------------------------------------------
-- Notation  -------------------------------------------------------------------
--------------------------------------------------------------------------------

namespace SciLean.NotationOverField

syntax diffBinderType  := " : " term
syntax diffBinderValue := ":=" term (";" term)?
syntax diffBinder := ident (diffBinderType <|> diffBinderValue)?

scoped syntax "∂ " term:66 : term
scoped syntax "∂ " diffBinder ", " term:66 : term
scoped syntax "∂ " "(" diffBinder ")" ", " term:66 : term

open Lean Elab Term Meta in
elab_rules : term
| `(∂ $f) => do
  let K := mkIdent (← currentFieldName.get)
  let KExpr ← elabTerm (← `($K)) none
  let fExpr ← withoutPostponing <| elabTermEnsuringType f none false
  if let .some (X,_) := (← inferType fExpr).arrow? then
    if (← isDefEq KExpr X) then
      elabTerm (← `(scalarCDeriv $K $f)) none false
    else
      elabTerm (← `(cderiv $K $f)) none false
  else
    throwUnsupportedSyntax

-- in this case we do not want to call scalarCDeriv
| `(∂ $x:ident := $val:term ; $dir:term, $b) => do
  let K := mkIdent (← currentFieldName.get)
  elabTerm (← `(cderiv $K (fun $x => $b) $val $dir)) none


macro_rules
| `(∂ $f $xs*) => `((∂ $f) $xs*)
| `(∂ $x:ident, $b) => `(∂ (fun $x => $b))
| `(∂ $x:ident := $val:term, $b) => `(∂ (fun $x => $b) $val)
| `(∂ $x:ident : $type:term, $b) => `(∂ fun $x : $type => $b)
| `(∂ ($b:diffBinder), $f)       => `(∂ $b, $f)


@[app_unexpander cderiv] def unexpandCDeriv : Lean.PrettyPrinter.Unexpander

  | `($(_) $_ $f:term $x $dx $y $ys*) =>
    match f with
    | `(fun $x':ident => $b:term) => `((∂ $x':ident:=$x;$dx, $b) $y $ys*)
    | _  => `(∂ $f:term $x:term $dx $y $ys*)


  | `($(_) $K $f:term $x $dx) =>
    match f with
    | `(fun $x':ident => $b:term) => `(∂ ($x':ident:=$x;$dx), $b)
    | `(fun ($x':ident : $_) => $b:term) => `(∂ ($x':ident:=$x;$dx), $b)
    | _  => `(∂ $f:term $x $dx)

  | `($(_) $K $f:term $x) =>
    match f with
    | `(fun $x':ident => $b:term) => `(∂ ($x':ident:=$x), $b)
    | `(fun ($x':ident : $_) => $b:term) => `(∂ ($x':ident:=$x), $b)
    | _  => `(∂ $f:term $x)

  | `($(_) $K $f:term) =>
    match f with
    | `(fun $x':ident => $b:term) => `(∂ $x':ident, $b)
    | `(fun ($x':ident : $ty) => $b:term) => `(∂ ($x' : $ty), $b)
    | _  => `(∂ $f)

  | _  => throw ()

@[app_unexpander scalarCDeriv] def unexpandScalarCDeriv : Lean.PrettyPrinter.Unexpander

  | `($(_) $_ $f:term $x $y $ys*) =>
    match f with
    | `(fun $x':ident => $b:term) => `((∂ $x':ident:=$x, $b) $y $ys*)
    | _  => `(∂ $f:term $x:term $y $ys*)


  | `($(_) $K $f:term $x) =>
    match f with
    | `(fun $x':ident => $b:term) => `(∂ ($x':ident:=$x), $b)
    | `(fun ($x':ident : $_) => $b:term) => `(∂ ($x':ident:=$x), $b)
    | _  => `(∂ $f:term $x)

  | `($(_) $K $f:term) =>
    match f with
    | `(fun $x':ident => $b:term) => `(∂ $x':ident, $b)
    | `(fun ($x':ident : $ty) => $b:term) => `(∂ ($x' : $ty), $b)
    | _  => `(∂ $f)

  | _  => throw ()


end NotationOverField