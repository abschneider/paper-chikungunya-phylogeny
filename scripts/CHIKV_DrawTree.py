#!/usr/bin/env python

import ete3
import pandas as pd
import argparse
from collections import Counter

p = argparse.ArgumentParser(description='Create colored Phylogenetic Tree of CHIKV lineages', formatter_class=argparse.ArgumentDefaultsHelpFormatter)
p.add_argument('-t', '--tree', help='Tree file (NEWICK)', default='CHIKV.all.partition.nex.colored.tree.newick')
p.add_argument('--loc', help='File mapping accession id -> country (Tab-separated)', default='CHIKV_origins.tsv')
p.add_argument('--lin', help='File Mapping accession id -> Lineage (Tab-separated)', default='CHIKV_lineages_all.tsv')
p.add_argument('--geo', help='File mapping country -> Geolocation (Tab-separated)', default='CHIKV_locationmap.tsv')
p.add_argument('-u', '--ultrametric', help='Draw Ultrametric Tree', default=False, action='store_true')
p.add_argument('-l', '--linewidth', help='Line width', default=8, type=int)
args = p.parse_args()

def main():
    #Parse Data
    origins = pd.read_csv(args.loc, sep='\s+', names=['id', 'origin'], comment='#')
    lineages = pd.read_csv(args.lin, sep='\s+', names=['id', 'lineage'], comment='#')

    #Merge into one Dataframe
    virdata = origins.merge(lineages, how='left').drop_duplicates(subset=['id'])
    virdata.lineage = virdata.lineage.fillna(value='Default')

    #Parse location 2 region mapping file
    loc = pd.read_csv(args.geo, sep='\s+', comment='#', names=['region', 'country'])

    location2region = {}
    for i, l in loc.iterrows():
        location2region[l.country] = l.region

    #Define lineage Colors
    lins_etecolors = {'asian_urban_lineage_americanlineage' : '#fee08b', 'asian_urban_lineage' : 'blue',
                        'asian_urban_lineage_asianonly' : '#fc8d59',
                        'western_african_lineage' : '#af8dc3',
                        'africanandasianlineages_sistergroupofmajorECSAclades' : '#005a32',
                        'sistertaxa_to_ECSA' : '#005a32',
                        'IOL_EasternAfricanLineage' : '#67a9cf',
                        'IOL_EasternAfricanlineage_EasternAfricanOnly' : '#2166ac',
                        'middleafrica_southamericanlineage_middleafricanonly' : '#41ab5d',
                        'middleafrica_southamericanlineage' : '#a1d99b',
                        'Default' : 'Grey'}
    #Define Georegion Colors
    region2color = { 'NAm': '#b10026', #American lineages
                     'SAm': '#e31a1c',
                     'CAm' : '#fd8d3c',
                     'CAR' : '#fed976',
                     'OC' : 'Black',    #Oceania
                     'AUSNZ' : '#7a0177', #Oceania-Australia/Nz
                     'MEL' : '#7a0177',   #Oceania-Melanesia
                     'POLY' : '#7a0177',  #Oceania-Polynesia
                     'MIC' : '#7a0177',   #Oceania-Micronesia
                     'EAf' : '#99d8c9',
                     'MAf' : '#66c2a4',
                     'SAf' : '#2ca25f',
                     'WAf' : '#006d2c',
                     'EU' : 'Black',
                     'AS' : 'yellow', #Asian lineages (legacy)
                     'EAs' : '#d0d1e6',
                     'SAs' : '#74a9cf',
                     'SEAs': '#0570b0',
                     'WAs' : '#bdc9e1'
                   }

    locs_etecolors = {location : region2color[location2region[location]] for location in location2region}


    #Create Tree
    tree = ete3.Tree(args.tree)

    #Add data into tree
    for n in tree:
        accid = n.name.replace('\'', '')
    #     n.name = accid + n.lineage    #DEBUG
        n.accid = accid.split('_')[0]
        n.name = accid.split('_')[0]
    #     n.name = '_'.join(accid.split('_')[1:])
        #lineage data
        n.lineage = virdata[virdata.id == n.accid].lineage.values
        if len(n.lineage) == 0:
            n.lineage = None
        else:
            n.lineage = n.lineage[0]
        #origin data
        n.origin = virdata[virdata.id == n.accid].origin.values[0]



    #Add color data to nodes
    for n in tree.iter_descendants('postorder'):
        #Feed data into leaf node
        if n.is_leaf() is True:
            n.locations = Counter()
            n.locations[n.origin] += 1
            n.lineages = Counter()
            n.lineages[n.lineage] += 1

        #Non-leaf node: collect information and decide on style
        else:
            if 'locations' in n.__dict__.keys():
                raise ValueError('Node visited twice')
            else:
                n.locations = Counter()
                for c in n.children:
                    n.locations += c.locations

            if 'lineages' in n.__dict__.keys():
                raise ValueError('Node visited twice')
            else:
                n.lineages = Counter()
                for c in n.children:
                    n.lineages += c.lineages


    #Color all nodes
    for n in tree.iter_descendants('postorder'):
        #based on LOCATION, decide color
        location, num_samples = n.locations.most_common()[0]
        color = locs_etecolors[location]
        #based on LINEAGE, decide color
    #     lineage, lin_samples = n.lineages.most_common()[0]
    #     color = lins_etecolors[lineage]

        nst = ete3.NodeStyle()
    #     nst['bgcolor'] = color
        nst["vt_line_color"] = color
        nst["hz_line_color"] = color
        nst['size'] = 0
        nst["vt_line_width"] = args.linewidth
        nst["hz_line_width"] = args.linewidth
        n.set_style(nst)


    #Add color faces to leafs
    leaves = [n for n in tree] #Collect first, since introducing proxy leaf nodes creates new leaves
    for n in leaves:
        #Nodesyle approach
        nst = ete3.NodeStyle()
        location, num_samples = n.locations.most_common()[0]
        loc_color = locs_etecolors[location]

        nst["vt_line_color"] = loc_color
        nst["hz_line_color"] = loc_color
        nst["vt_line_width"] = args.linewidth
        nst["hz_line_width"] = args.linewidth
        n.set_style(nst)

        proxy_leaf = n.add_child(name=n.name, dist=0)
        lineage, lin_samples = n.lineages.most_common()[0]
        lin_color = lins_etecolors[lineage]
        nst_proxy = ete3.NodeStyle()
        nst_proxy["vt_line_color"] = loc_color
        nst_proxy["hz_line_color"] = loc_color
        nst_proxy["vt_line_width"] = args.linewidth
        nst_proxy["hz_line_width"] = args.linewidth
        nst_proxy['bgcolor'] = lin_color
        proxy_leaf.set_style(nst_proxy)
        proxy_leaf.img_style['size'] = 0

    #Set final options and Show Tree
    sty_circ = Treestyle_circular(360)
    sty_circ.show_leaf_name = True
    sty_circ.show_scale = False
    #Check if ultrametric is set
    if args.ultrametric is True:
        tree = Ultrametric(tree, 0)
    tree.show(tree_style=sty_circ)


def Ultrametric(tree, leaf_size=4):
    ete3.Tree.convert_to_ultrametric(tree)
    #Set all node sizes to 0 (distorts ultrametric view)
    for t in tree.traverse():
        t.img_style['size'] = 0
    #Set leaf node sizes to standard value
    for t in tree:
        t.img_style['size'] = leaf_size
    return tree

def Treestyle_circular(degree):
    style_circ = ete3.TreeStyle()
    style_circ.draw_guiding_lines = True
    style_circ.show_leaf_name = True
    style_circ.mode = "c"
    style_circ.arc_start = -90 # 0 degrees = 3 o'clock
    style_circ.arc_span = degree
    return style_circ

if __name__ == '__main__':
    main()
