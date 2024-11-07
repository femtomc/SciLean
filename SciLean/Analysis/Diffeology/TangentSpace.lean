import SciLean.Tactic.Autodiff
import SciLean.Data.ArrayN

import SciLean.Analysis.Diffeology.Basic


/-!

# Tangent space of diffeological space and derivative map

Tangent space of diffeological space. It allows us to talk about derivative as a function between
two tangent spaces.


NOTE: We also define separete notion of `TangentBundle` which should be equivalent to `TangentSpace`
      - for `TX : X → Type` and `TangentSpace X TX` we have `TangentBundle X (Σ x, TX x)`
      - for `TX : Type` and `TangentBundle X TX` we have `TangentSpace X (fun x => {dx : TX // π dx = x})`
      We have both definitions to figure out which one is easier to work with.


TODO: The paper 'Tangent spaces and tangent bundles for diffeological spaces'[1]  defines internal
      and external notion of tangent space. Figure out if our definition relates to theirs.

      [1] https://arxiv.org/abs/1411.5425
-/


namespace SciLean

open Diffeology Util

local notation:max "ℝ^" n:max => (Fin n) → ℝ


/-- Tangent space `TX x` of `X` at point `x`. Generalization of tangent space for manifolds to
general diffeological spaces which gives us the minimal structure to talk about derivatives.
-/
class TangentSpace (X : Type v) [Diffeology X] (TX : outParam (X → Type w))
      [∀ x, AddCommGroup (TX x)] [∀ x, outParam <| Module ℝ (TX x)] where
  /-- Map assigning tangent vectors to plots. -/
  tangentMap {n : ℕ} (c : ℝ^n → X) (x dx : ℝ^n) : TX (c x)

  -- NOTE: This does not seems to be necessary at it is included in the definition of differentiable
  --       function
  -- /-- Chain rule for composing with smooth function. -/
  -- tangentMap_comp {n m} {p} {f : ℝ^n → ℝ^m}
  --   (hp : p ∈ plots m) (hf : ContDiff ℝ ⊤ f) (x dx) :
  --   tangentMap (p∘f) x dx = tangentMap p (f x) (fderiv ℝ f x dx)

  /-- Tangent of constant function is zero. -/
  tangentMap_const {n} (x : X) (t dt) : tangentMap (fun _ : ℝ^n => x) t dt = 0

  /-- Tangent map is linear map -/
  tangentMap_linear {n : ℕ} (p : ℝ^n → X) (hp : p ∈ plots n (X:=X)) (x : ℝ^n) :
    IsLinearMap ℝ (tangentMap p x)

  /-- Canonical curve going through `x` in direction `dx`. -/
  exp (x : X) (dx : TX x) : ℝ^1 → X
  /-- Canonical curve going through `x` does go through `x` -/
  exp_at_zero (x : X) (dx : TX x) : exp x dx 0 = x
  /-- Canonical curve is a plot. -/
  exp_is_plot (x : X) (dx : TX x) : exp x dx ∈ plots 1
  /-- Canonical curve going through `x` in direction `dx` does do in direction `dx` -/
  tangentMap_exp_at_zero (x : X) (dx : TX x) dt :
    tangentMap (exp x dx) 0 dt = dt 0 • cast (by rw[exp_at_zero]) dx


attribute [simp]
  TangentSpace.exp_at_zero
  TangentSpace.tangentMap_exp_at_zero
  TangentSpace.tangentMap_const

variable
  {X : Type*} {TX : outParam (X → Type*)} [Diffeology X]
  [∀ x, AddCommGroup (TX x)] [∀ x, Module ℝ (TX x)] [TangentSpace X TX]
  {Y : Type*} {TY : outParam (Y → Type*)} [Diffeology Y]
  [∀ y, AddCommGroup (TY y)] [∀ y, Module ℝ (TY y)] [TangentSpace Y TY]
  {Z : Type*} {TZ : outParam (Z → Type*)} [Diffeology Z]
  [∀ z, AddCommGroup (TZ z)] [∀ z, Module ℝ (TZ z)] [TangentSpace Z TZ]



open Diffeology TangentSpace in
/-- Smooth function between diffeological spaces equiped with tangent spaces.

Smooth function maps plots to plots and tangent depends only on the plot's point and tangent

NOTE: There is also `TBSmooth` which is a smooth function between diffological spaces with
      tangent bundle. It should be more or less equivalent definition. We have both to see
      which one is easier to work with.
-/
@[fun_prop]
structure TSSmooth (f : X → Y) extends DSmooth f : Prop where
  plot_independence {n : ℕ} {p q : ℝ^n → X} {x : ℝ^n}
    (hp : p ∈ plots n) (hq : q ∈ plots n)
    (hx : p x = q x) (hdx : tangentMap p x = cast (by rw[hx]) (tangentMap q x)) :
    tangentMap (fun x => f (p x)) x
    =
    cast (by simp[hx]) (tangentMap (f∘q) x)

namespace TSSmooth

@[fun_prop]
theorem dsmooth_rule (f : X → Y) (hf : TSSmooth f) : DSmooth f := hf.toDSmooth

@[fun_prop]
theorem id_rule : TSSmooth (fun x : X => x) := by
  constructor
  · fun_prop
  · intros; unfold Function.comp; simp_all


@[fun_prop]
theorem const_rule (y : Y) : TSSmooth (fun _ : X => y) := by
  constructor
  · fun_prop
  · intros; simp only [Function.comp_apply, Function.comp_def, cast_eq]

@[fun_prop]
theorem comp_rule (f : Y → Z) (g : X → Y)
    (hf : TSSmooth f) (hg : TSSmooth g) :
    TSSmooth (fun x => f (g x)) := by

  constructor
  case toDSmooth => fun_prop
  case plot_independence =>
    intros n p q x hp hq hx hdx
    let hp' := hg.plot_preserving _ hp
    let hq' := hg.plot_preserving _ hq
    exact hf.plot_independence hp' hq' (by simp_all) (hg.plot_independence hp hq hx hdx)

end TSSmooth


open Classical Diffeology TangentSpace in
/-- Derivative of a function between two difeological spaces equiped with tangent space. -/
@[fun_trans]
noncomputable
def tsderiv (f : X → Y) (x : X) (dx : TX x) : TY (f x) :=
  if TSSmooth f then
    let p := f∘exp x dx
    let dy := tangentMap p 0 1
    cast (by simp_all[p]) dy
  else
    (0 : TY (f x))


namespace tsderiv

@[fun_trans]
theorem id_rule :
    tsderiv (fun x : X => x) = fun _ dx => dx := by

  have h : TSSmooth (fun x : X => x) := by fun_prop
  unfold tsderiv; simp[h, Function.comp_def]

@[fun_trans]
theorem const_rule :
    tsderiv (fun _ : X => y) = fun _ _ => (0 : TY y) := by

  have h : TSSmooth (fun _ : X => y) := by fun_prop
  unfold tsderiv; simp[h, Function.comp_def]


open TangentSpace in
@[fun_trans]
theorem comp_rule (f : Y → Z) (g : X → Y)
    (hf : TSSmooth f) (hg : TSSmooth g) :
    tsderiv (fun x => f (g x))
    =
    fun x dx =>
      let y  := g x
      let dy := tsderiv g x dx
      let dz := tsderiv f y dy
      dz  := by

  funext x dx
  have h : TSSmooth fun x => f (g x) := by fun_prop -- TSSmooth.comp_rule _ _ hf hg

  -- set up arguments to use `plot_independence`
  let y  := g x
  let dy := tsderiv g x dx
  let p := g ∘ exp x dx
  let hp : p ∈ plots 1 := hg.plot_preserving _ (exp_is_plot x dx)
  let q  := exp y dy
  let hq : q ∈ plots 1 := exp_is_plot y dy
  have hx : p 0 = q 0 := by simp[p,q]
  have hdx : tangentMap p 0 = cast (by simp[hx]) (tangentMap q 0) := by
    funext dt
    simp [p,q,tangentMap_exp_at_zero,dy,tsderiv,hg]
    have h := (tangentMap_linear p hp 0).map_smul (dt 0) 1 |>.symm
    simp[h]; congr; funext x; simp; congr; ext; simp only [Fin.val_eq_zero, Fin.isValue]

  -- use `plot_independence`
  have h' := hf.plot_independence hp hq hx hdx

  -- now just unfold definitions, use `h'` and we are done
  simp [p] at h'
  conv => lhs; simp[h, hf, hg, Function.comp_def, tsderiv]; rw[h']
  simp (config:={zetaDelta:=true}) [q,y,dy,Function.comp_def,hf,hg,tsderiv]

end tsderiv