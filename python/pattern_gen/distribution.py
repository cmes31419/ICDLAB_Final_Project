from __future__ import annotations

import argparse
import random
import sys
from collections import Counter
from pathlib import Path
import logging


# Configure simple logger for runtime progress
logger = logging.getLogger(__name__)
if not logger.handlers:
    handler = logging.StreamHandler()
    fmt = "%(asctime)s %(levelname)s: %(message)s"
    handler.setFormatter(logging.Formatter(fmt, datefmt="%H:%M:%S"))
    logger.addHandler(handler)
logger.setLevel(logging.INFO)


ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))


try:
    from gii_decoder import GIIDecoder
    from gen_pattern import gen_random_error_pos, gen_receive
except ImportError as exc:
    logger.exception("Import failed when initializing simulator")
    raise SystemExit(
        "Missing runtime dependency for the decoder stack. Install required packages (e.g. 'galois', 'numpy', 'matplotlib')."
    ) from exc


DEFAULT_Q = 6
DEFAULT_M = 4
DEFAULT_V = 2
DEFAULT_T_LIST = [2, 4, 6]
DEFAULT_P_STR = "x^6 + x + 1"


def classify_stage(round_logs):
    """
    Return the deepest stage reached by the decoder.

    stage 0: stage-1 BCH finishes with no failed sub-codewords
    stage 1: one nested recovery round was attempted
    stage 2: two nested recovery rounds were attempted
    """
    return min(len(round_logs), 2)


def simulate(trials, seed, min_err, max_err, q, m, v, t_list, p_str):
    random.seed(seed)

    decoder = GIIDecoder(q=q, m=m, v=v, t_list=t_list, p_str=p_str)
    n = 2 ** q - 1

    stage_counts = Counter()
    success_counts = Counter()

    log_interval = max(1, trials // 10)
    for i in range(trials):
        if (i + 1) % log_interval == 0 or trials <= 20:
            logger.info(f"Simulation progress: {i+1}/{trials} trials")

        # keep local index name for logging
        _ = i
        codewords = decoder.encode_random_data(n)
        error_pos = gen_random_error_pos(
            n=n,
            num_subcodewords=m,
            min_err=min_err,
            max_err=max_err,
        )

        received = [gen_receive(n, codewords[i], error_pos[i]) for i in range(m)]
        received_words = [decoder.bits_str_to_poly_list(word) for word in received]

        result = decoder.decode_multi_round_restart(received_words)
        stage = classify_stage(result["round_logs"])

        stage_counts[stage] += 1
        success_counts[(stage, bool(result["success"]))] += 1

    return stage_counts, success_counts


def format_probability(count, total):
    return count / total if total else 0.0


def main(argv=None):
    parser = argparse.ArgumentParser(
        description="Monte Carlo stage-distribution simulator for the GII-BCH decoder."
    )
    parser.add_argument("--trials", type=int, default=1000)
    parser.add_argument("--seed", type=int, default=0)
    parser.add_argument("--min-err", type=int, default=0)
    parser.add_argument("--max-err", type=int, default=6)
    parser.add_argument("--q", type=int, default=DEFAULT_Q)
    parser.add_argument("--m", type=int, default=DEFAULT_M)
    parser.add_argument("--v", type=int, default=DEFAULT_V)
    parser.add_argument(
        "--t-list",
        type=int,
        nargs="+",
        default=DEFAULT_T_LIST,
        help="Non-decreasing BCH capabilities, e.g. --t-list 2 4 6",
    )
    parser.add_argument("--p-str", type=str, default=DEFAULT_P_STR)
    args = parser.parse_args(argv)

    if len(args.t_list) != args.v + 1:
        raise SystemExit(f"--t-list must contain exactly v+1 values; got {len(args.t_list)}")

    if any(args.t_list[i] > args.t_list[i + 1] for i in range(len(args.t_list) - 1)):
        raise SystemExit("--t-list must be non-decreasing")

    stage_counts, success_counts = simulate(
        trials=args.trials,
        seed=args.seed,
        min_err=args.min_err,
        max_err=args.max_err,
        q=args.q,
        m=args.m,
        v=args.v,
        t_list=args.t_list,
        p_str=args.p_str,
    )

    total = args.trials
    print("stage distribution")
    for stage in range(0, 3):
        count = stage_counts.get(stage, 0)
        prob = format_probability(count, total)
        print(f"  stage {stage}: {count}/{total} = {prob:.6f}")

    print("success rate by stage")
    for stage in range(0, 3):
        ok = success_counts.get((stage, True), 0)
        fail = success_counts.get((stage, False), 0)
        stage_total = ok + fail
        prob = format_probability(ok, stage_total)
        print(f"  stage {stage}: success {ok}, fail {fail}, success_rate = {prob:.6f}")

    # Attempt to produce plots if matplotlib is available
    try:
        import matplotlib.pyplot as plt

        out_dir = Path(__file__).resolve().parent
        stages = [0, 1, 2]
        counts = [stage_counts.get(s, 0) for s in stages]

        plt.figure()
        plt.bar(stages, counts)
        plt.xticks(stages)
        plt.xlabel('Stage')
        plt.ylabel('Count')
        plt.title('Stage distribution')
        stage_file = out_dir / 'stage_distribution.png'
        plt.savefig(stage_file)
        logger.info(f"Saved stage distribution plot to {stage_file}")

        success_rates = []
        for s in stages:
            ok = success_counts.get((s, True), 0)
            fail = success_counts.get((s, False), 0)
            total_s = ok + fail
            success_rates.append(ok / total_s if total_s else 0.0)

        plt.figure()
        plt.bar(stages, success_rates)
        plt.xticks(stages)
        plt.ylim(0, 1)
        plt.xlabel('Stage')
        plt.ylabel('Success Rate')
        plt.title('Success rate by stage')
        success_file = out_dir / 'success_rate.png'
        plt.savefig(success_file)
        logger.info(f"Saved success rate plot to {success_file}")

    except Exception as e:
        logger.warning("matplotlib not available or failed to generate plots: %s", e)


if __name__ == "__main__":
    main()