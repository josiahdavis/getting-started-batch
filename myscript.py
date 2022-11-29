#!/usr/bin/env python

import argparse
import os
import random

import pandas as pd

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--forecast_model", default="rf")
    parser.add_argument("--seed", type=int, default=1)
    args = parser.parse_args()
    random.seed(args.seed)
    d = pd.read_csv("/tmp/input.csv")
    print(f"Args recieved: {args}")
    d["model"] = args.forecast_model
    d["seed"] = args.seed
    print(d)
    os.mkdir("/tmp/output")
    d.to_csv(f"/tmp/output/result_{args.forecast_model}_{args.seed}.csv", index = False)
    print("lol!")