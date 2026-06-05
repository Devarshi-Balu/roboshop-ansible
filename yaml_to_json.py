import yaml, json
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("--input", "-i", type=str, help="input file of yaml type")
parser.add_argument("--output", "-o", type=str, default="output.json", help="output file")
args = parser.parse_args()

with open(args.input, "r") as yaml_file: 
    data = yaml.safe_load(yaml_file)

with open(args.output, "w") as json_file: 
    json.dump(data, json_file, indent=4)

