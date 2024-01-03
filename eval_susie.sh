export DIFFUSION_MODEL_CHECKPOINT=/proj/vondrick4/neil/workspace/susie-calvin-checkpoints/diffusion_model/
export GC_POLICY_CHECKPOINT=/proj/vondrick4/neil/workspace/susie-calvin-checkpoints/gc_policy/
export NUM_EVAL_SEQUENCES=30

# /proj/vondrick4/datasets/CALVIN/goal_conditioned_processed/validation/D

python calvin_models/calvin_agent/evaluation/evaluate_policy_subgoal_diffusion.py --dataset_path /proj/vondrick4/datasets/CALVIN/lang_conditioned_processed/ --custom_model
