#!/usr/bin/env python3

import argparse
import os
import subprocess


def index(clangd_indexer, compile_commands, output_path):
    '''
    Generates index at the requested location using the following command:

    $ clangd-indexer --executor=all-TUs compile_commands.json > ${OUTPUT}
    '''
    clangd_indexer = os.path.abspath(clangd_indexer)
    compile_commands = os.path.abspath(compile_commands)
    output_path = os.path.abspath(output_path)
    with open(output_path, "wb") as output:
        subprocess.run([clangd_indexer, "--executor=all-TUs", compile_commands],
                       stdout=output)


def main():
    parser = argparse.ArgumentParser(description='Build Clangd index.')
    parser.add_argument('compile_commands',
                        type=str,
                        help='Path to project\'s compile_commands.json')
    parser.add_argument('output_path',
                        type=str,
                        help='Generated index will be stored here')
    parser.add_argument(
        '--clangd-indexer-bin',
        type=str,
        default="clangd-indexer",
        help='Path to the clangd-indexer binary (default: clangd-indexer)')
    args = parser.parse_args()
    index(args.clangd_indexer_bin, args.compile_commands, args.output_path)


if __name__ == '__main__':
    main()
