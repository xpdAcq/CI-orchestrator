import yaml

installers = {'conda': conda install, 'pip': pip install}

with open('score.yaml', 'r') as f:
    d = yaml.load(f)

keys = set([v.keys() for k, v in d])
precidence = ${...}.get('PRECIDENCE', ['default'])

# Find the packages to install from sources
deps = {}
for k in precidence:
    for p, pv in d.items():
        if k in pv:
            deps[p] = pv[k]

req_installers = {list(v.keys())[0] for k, v in deps.items()}
installs = {i: [] for i in req_installers}
for k in deps:
    for i in req_installers:
        if list(deps[k].keys())[0] == i:
            installs[i].append(deps[k][i])

for installer in installers:
    installers[installer] installs[installer]

