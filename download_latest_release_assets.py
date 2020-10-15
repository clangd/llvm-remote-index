#!/usr/bin/env python3

import argparse
import os
import requests
import sys


# Returns True if the download was successful.
def download(repository, asset_prefix, output_dir, output_name):
    # Traverse releases in chronological order.
    request = requests.get(
        f'https://api.github.com/repos/{repository}/releases')
    for release in request.json():
        for asset in release.get('assets', []):
            if asset.get('name', '').startswith(asset_prefix):
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
                        help='Asset will be stored here.',
                        default=os.getcwd())
    parser.add_argument(
        '--output-name',
        type=str,
        help=
        'Asset will be stored with this name, will use asset name by default',
        default=None)
    parser.add_argument(
        '--asset-prefix',
        type=str,
        help='The required prefix to match for asset to download.',
        required=True)
    args = parser.parse_args()
    success = download(args.repository, args.asset_prefix, args.output_dir,
                       args.output_name)
    if not success:
        sys.exit(1)


if __name__ == '__main__':
    main()
