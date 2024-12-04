import SciLean.Analysis.Calculus.FwdFDeriv
import SciLean.Tactic.DataSynth.Attr
import SciLean.Tactic.DataSynth.Elab

namespace SciLean

variable {R} [RCLike R]
  {X} [NormedAddCommGroup X] [NormedSpace R X]
  {Y} [NormedAddCommGroup Y] [NormedSpace R Y]
  {Z} [NormedAddCommGroup Z] [NormedSpace R Z]

variable (R)
@[data_synth out f' in f]
structure HasFwdFDerivAt (f : X → Y) (f' : X → X → Y×Y) (x : X) where
  val : ∀ dx, f' x dx = (f x, fderiv R f x dx)
  prop : DifferentiableAt R f x
variable {R}


namespace HasFwdFDerivAt

@[data_synth]
theorem id_rule (x : X) : HasFwdFDerivAt R (fun x : X => x) (fun x dx => (x, dx)) x := by
  constructor
  · fun_trans
  · fun_prop

set_option linter.unusedVariables false in
@[data_synth]
theorem const_rule (x : X) (y : Y) :  HasFwdFDerivAt R (fun x : X => y) (fun x dx => (y, 0)) x := by
  constructor
  · fun_trans
  · fun_prop

@[data_synth]
theorem comp_rule (f : Y → Z) (g : X → Y) (x : X) (f' g')
    (hf : HasFwdFDerivAt R f f' (g x)) (hg : HasFwdFDerivAt R g g' x) :
    HasFwdFDerivAt R
      (fun x : X => f (g x))
      (fun x dx =>
        let ydy := g' x dx
        f' ydy.1 ydy.2) x := by

  cases hf; cases hg
  constructor
  · intro dx; fun_trans only; simp_all
  · fun_prop

@[data_synth]
theorem let_rule (f : Y → X → Z) (g : X → Y) (x : X) (f' g')
    (hf : HasFwdFDerivAt R (↿f) f' (g x, x)) (hg : HasFwdFDerivAt R g g' x) :
    HasFwdFDerivAt R
      (fun x : X => let y := g x; f y x)
      (fun x dx =>
        let ydy := g' x dx
        f' (ydy.1,x) (ydy.2,dx)) x := by

  cases hf; cases hg
  constructor
  · intro dx; fun_trans only; simp_all[Function.HasUncurry.uncurry]
  · fun_prop


end HasFwdFDerivAt


theorem Prod.mk.arg_a0a1.HasFwdFDerivAt_rule
  (f : X → Y) (g : X → Z) (x) (f' g')
  (hf : HasFwdFDerivAt R f f' x) (hg : HasFwdFDerivAt R g g' x) :
  HasFwdFDerivAt R
    (fun x => (f x, g x))
    (fun x dx =>
      let ydy := f' x dx
      let zdz := g' x dx
      ((ydy.1,zdz.1), (ydy.2, zdz.2))) x := by

  cases hf; cases hg
  constructor
  · intro dx; fun_trans only; simp_all
  · fun_prop


theorem Prod.fst.arg_self.HasFwdFDerivAt_rule
  (f : X → Y×Z) (x) (f')
  (hf : HasFwdFDerivAt R f f' x) :
  HasFwdFDerivAt R
    (fun x => (f x).1)
    (fun x dx =>
      let ydy := f' x dx
      (ydy.1.1, ydy.2.1)) x := by
  cases hf
  constructor
  · intro dx; fun_trans only; simp_all
  · fun_prop

theorem Prod.snd.arg_self.HasFwdFDerivAt_rule
  (f : X → Y×Z) (x) (f')
  (hf : HasFwdFDerivAt R f f' x) :
  HasFwdFDerivAt R
    (fun x => (f x).2)
    (fun x dx =>
      let ydy := f' x dx
      (ydy.1.2, ydy.2.2)) x := by
  cases hf
  constructor
  · intro dx; fun_trans only; simp_all
  · fun_prop