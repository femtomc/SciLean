import SciLean.Categories.Lin.Core

namespace SciLean.Lin

variable {α β γ : Type} 
variable {X Y Z : Type} [Vec X] [Vec Y] [Vec Z]
variable {U V W : Type} [Hilbert U] [Hilbert V] [Hilbert W] 

--- Arithmetic operations
instance : IsLin (λ x : X×X => x.1+x.2) := sorry
instance : IsLin (λ x : X×X => Add.add x.1 x.2) := sorry
instance : IsLin (λ x : X×X => x.1-x.2) := sorry
instance : IsLin (λ x : X×X => Sub.sub x.1 x.2) := sorry

-- instance : IsLin (λ (r : ℝ) (x : X) => r*x) := sorry
-- instance (r : ℝ) : IsLin (λ (x : X) => r*x) := sorry
instance : IsLin (HMul.hMul : ℝ → X → X) := sorry
instance (r : ℝ) : IsLin (HMul.hMul r : X → X) := sorry

instance : IsLin (λ x : X => -x) := sorry

instance : IsLin (SemiInner.semi_inner : U → U → _ → ℝ) := sorry
instance (u : U) : IsLin (SemiInner.semi_inner u) := sorry