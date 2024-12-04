import Lean.Elab.Tactic.Conv
import SciLean.Tactic.DataSynth.Main

namespace SciLean.Tactic.DataSynth

open Lean Meta Elab Tactic

declare_config_elab elabDataSynthConfig Config

open Parser.Tactic in
/-- `date_synth` as conv tactic will fill in meta variables in generalized transformation -/
syntax (name:=data_synth_conv) "data_synth" optConfig : conv

/- syntax (name := simp) "simp" optConfig (discharger)? (&" only")?
  (" [" withoutPosition((simpStar <|> simpErase <|> simpLemma),*,?) "]")? (location)? : tactic
 -/

@[tactic data_synth_conv] unsafe def dataSynthConv : Tactic
| `(conv| data_synth $cfg:optConfig) => do
  let e ← Conv.getLhs

  let cfg ← elabDataSynthConfig cfg

  let some g ← isDataSynthGoal? e
    | throwError "{e} is not `data_synth` goal"

  let ((r?, _),_) ← dataSynth g |>.run {config := cfg} |>.run {}
    |>.run (← Simp.mkDefaultMethods).toMethodsRef
    |>.run {config := cfg.toConfig, simpTheorems := #[← getSimpTheorems]}
    |>.run {}

  -- let cacheRef : IO.Ref LSimp.Cache ← IO.mkRef {}
  -- let stateRef : IO.Ref Simp.State ← IO.mkRef {}

  -- let (((proof?,_), _),_) ← dataSynth e |>.run {} |>.run {}
  --  |>.run (← Simp.mkDefaultMethods)
  --  |>.run {config := cfg.toConfig, simpTheorems := #[← getSimpTheorems]}
  --  |>.run {cache := cacheRef, simpState := stateRef}
  --  |>.run {}

  match r? with
  | some r =>
    let e' := r.getSolvedGoal
    if ← isDefEq e e' then
      Conv.changeLhs e'
    else
      throwError "faield to assign data"
  | none =>
    throwError "`data_synth` failed"
| _ => throwUnsupportedSyntax