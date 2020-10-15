#!/usr/bin/env python3

import argparse
import os
import requests
import sys


# Returns True if the download was successful.
def download(repository, output_dir, target_os, output_name):
    # Traverse releases in chronological order.
    request = requests.get(
        f'https://api.github.com/repos/{repository}/releases')
    for release in request.json():
        for asset in release.get('assets', []):
            if asset.get('name', '').startswith(f'clangd-{target_os}'):
                download_url = asset['browser_download_url']
                downloaded_file = requests.get(download_url)
                if output_name is None:
                    output_name = asset['name']
                with open(os.path.join(output_dir, output_name), 'wb') as f:
                    f.write(downloaded_file.content)
                # The latest release is downloaded, there is nothing else to
                # do.
                return True
    return False


def main():
    parser = argparse.ArgumentParser(
        description='Download Clangd binaries (clangd itself, indexer, etc).')
    parser.add_argument(
        '--repository',
        type=str,
        help='GitHub repository to download latest release from.',
        default='clangd/clangd')
    parser.add_argument('--output-dir',
                        type=str,
                        help='Tools will be stored here.',
                        default=os.getcwd())
    parser.add_argument(
        '--target-os',
        type=str,
        help='Operating system to download tools for. [default: linux]',
        choices=['linux', 'mac', 'windows'],
        default='linux')
    parser.add_argument('--output-name',
                        type=str,
                        help=('Tools will be stored with this name, will use '
                              'asset name by default'),
                        default=None)
    args = parser.parse_args()
    success = download(args.repository, args.output_dir, args.target_os,
                       args.output_name)
    if not success:
        sys.exit(1)


if __name__ == '__main__':
    main()
