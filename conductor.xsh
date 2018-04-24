import yaml

# Registry of installers
installers = ${...}.get('INSTALLERS',
                        {'conda': 'conda install', 'pip': 'pip install'})
installer_order = ${...}.get('INSTALLERS_ORDER',
                        ['conda', 'pip'])

# Read the actual configuration
with open('score.yaml', 'r') as f:
    config = yaml.load(f)

$PRECEDENCE = 'default bleeding'
precidence = ${...}.get('PRECEDENCE', ['default'])
# Bash hack, bash doesn't support array values, so we split strings
if isinstance(precidence, str):
    precidence = precidence.split()


deps = {}
# Go through the keys in precidence order
for p in precidence:
    for k, v in config.items():
        vg = v.get(p)
        if vg:
            deps[k] = vg
print(deps)

installs = {}
for k, v in deps.items():
    installer = list(v.keys())[0]
    if installer in installs:
        installs[installer].append(v[installer])
    else:
        installs[installer] = [v[installer]]

print(installs)
# execute the installs for each
for i in installer_order:
    if i in installers:
        x = [installers[i]] + installs[i]
        print(x)
        @([installers[i]] + installs[i])
    else:
        raise KeyError('That installer is not currently in the installation '
                       'registry. Please add it by updating the $INSTALLERS'
                       'env var.')
