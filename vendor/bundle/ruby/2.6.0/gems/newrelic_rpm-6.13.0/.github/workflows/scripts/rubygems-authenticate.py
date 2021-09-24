import os

import argparse
import onetimepass

if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description='Generate a one-time password from a key'
    )
    parser.add_argument('env_var', type=str, help='The name of the environment variable from which to load the MFA key from the service')
    args = parser.parse_args()
    print(onetimepass.get_totp(os.getenv(args.env_var)))
