#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
Script to provide OceanSITES compliance report for files in the GDAC

Mike McCann
30 April 2016
'''

import argparse
import asyncio
import logging
import re
import requests
import sys
import xarray
from bs4 import BeautifulSoup
from compliance_checker.runner import ComplianceChecker, CheckSuite

# Load all available checker classes
check_suite = CheckSuite()
check_suite.load_all_available_checkers()

def get_opendap_urls(catalog_url):
    '''Generates opendap urls for the datasets in catalog.
    The `catalog_url` is the .xml link for a directory on a 
    THREDDS Data Server.
    '''
    req = requests.get(catalog_url)
    soup = BeautifulSoup(req.text, 'html.parser')

    # Expect that this is a standard TDS with dodsC used for OPeNDAP
    base_url = '/'.join(catalog_url.split('/')[:4]) + '/dodsC/'

    # Search only for files ending in 'nc' and for pattern, if specified
    search_str = '(?=.*nc$)'
    if args.pattern:
        search_str += ('(?=.*{}.*)').format(args.pattern)

    # Site level catalog has dataset elements
    for e in soup.findAll('dataset', attrs={'urlpath': re.compile(search_str)}):
        yield base_url + e['urlpath']

    # Top (GDAC) level catalog specified, look for 'catalogref's and drill down
    for e in soup.findAll('catalogref', attrs={'id': re.compile("DATA")}):
        req = requests.get(('{}{}/catalog.xml').format(base_url, e['id']))
        soup = BeautifulSoup(req.text, 'html.parser')
        for e in soup.findAll('dataset', attrs={'urlpath': re.compile(search_str)}):
            yield base_url + e['urlpath']

async def cc_report(args):

    if args.verbose > 1:
        print(f'Checking OPeNDAP URL: {url}')

    if args.format == 'summary':
        cs = CheckSuite()
        if args.criteria == 'normal':
            limit = 2
        elif args.criteria == 'strict':
            limit = 1
        elif args.criteria == 'lenient':
            limit = 3


        ds = cs.load_dataset(url)
        skip_checks = ()
        score_groups = cs.run(ds, skip_checks, *args.test)

        # Always use sorted test (groups) so they print in correct order
        reports = {}
        for checker, rpair in sorted(score_groups.items()):
            groups, _ = rpair
            _, points, out_of = cs.get_points(groups, limit)
            reports[checker] = (100 * float(points) / float(out_of))

        print((report_fmt).format(url, *[reports[t] for t in sorted(args.test)]))
        sys.stdout.flush()
    else:
        # Send the compliance report to stdout
        ComplianceChecker.run_checker(url, args.test, args.verbose, args.criteria,
                                        args.output, args.format)

def main_async(args):
    if args.format == 'summary':
        hdr_fmt = '{},' * len(args.test)
        rpt_fmt = '{:.1f},' * len(args.test)
        report_fmt = '{},' + rpt_fmt[:-1]
        print(('{},' + hdr_fmt[:-1]).format('url', *sorted(args.test)))

    for cat in args.catalog_urls:
        if args.verbose > 1:
            print(f'Opening catalog_url: {cat}')

        loop = asyncio.get_event_loop()
        for url in get_opendap_urls(cat):

                future = asyncio.ensure_future(cc_report(args))
                loop.run_until_complete(future)




def main(args):
    if args.format == 'summary':
        hdr_fmt = '{},' * len(args.test)
        rpt_fmt = '{:.1f},' * len(args.test)
        report_fmt = '{},' + rpt_fmt[:-1]
        print(('{},' + hdr_fmt[:-1]).format('url', *sorted(args.test)))

    for cat in args.catalog_urls:
        if args.verbose > 1:
            print(f'Opening catalog_url: {cat}')
        for url in get_opendap_urls(cat):

            if args.verbose > 1:
                print(f'Checking OPeNDAP URL: {url}')

            if args.format == 'summary':
                cs = CheckSuite()
                if args.criteria == 'normal':
                    limit = 2
                elif args.criteria == 'strict':
                    limit = 1
                elif args.criteria == 'lenient':
                    limit = 3

                try:
                    ds = cs.load_dataset(url)
                except ValueError as e:
                    print(f'Failed to get report for {url}')
                    print(str(e))
                    continue
                    
                skip_checks = ()
                score_groups = cs.run(ds, skip_checks, *args.test)
                

                # Always use sorted test (groups) so they print in correct order
                reports = {}
                for checker, rpair in sorted(score_groups.items()):
                    groups, _ = rpair
                    _, points, out_of = cs.get_points(groups, limit)
                    reports[checker] = (100 * float(points) / float(out_of))

                print((report_fmt).format(url, *[reports[t] for t in sorted(args.test)]))
                sys.stdout.flush()

            else:
                # Send the compliance report to stdout
                ComplianceChecker.run_checker(url, args.test, args.verbose, args.criteria,
                                              args.output, args.format)
def parse_command_line():

    parser = argparse.ArgumentParser()
    parser.add_argument('--pattern', '-p', '--pattern=', '-p=', 
                        help="String to restrict filename matching to.")
    parser.add_argument('--test', '-t', '--test=', '-t=', default=('acdd',),
                        nargs='+',
                        choices=sorted(check_suite.checkers.keys()),
                        help="Select the Checks you want to perform.  Defaults to 'acdd' if unspecified")

    parser.add_argument('--criteria', '-c',
                        help="Define the criteria for the checks.  Either Strict, Normal, or Lenient.  Defaults to Normal.",
                        nargs='?', default='normal',
                        choices = ['lenient', 'normal', 'strict'])

    parser.add_argument('--verbose', '-v', choices=[1,2,3], type=int, 
                        help='Turn on verbose output. Higher number = more output.', default=0)

    parser.add_argument('-f', '--format', default='text',
                        choices=['text', 'html', 'json', 'summary'], help='Output format')
    parser.add_argument('-o', '--output', default='-', action='store',
                        help='Output filename')
    parser.add_argument('--async', action='store_true', help='Parallelize processing with xarray and asyncio')
    parser.add_argument('-V', '--version', action='store_true',
                        help='Display the IOOS Compliance Checker version information.')
    parser.add_argument('catalog_urls', nargs='*',
                        help="The THREDDS Catalog URLs ending in '.xml' (one or more).")

    args = parser.parse_args()
    return args


if __name__ == '__main__':
    args = parse_command_line()
    if args.async:
        main_async(args)
    else:
        main(args)

